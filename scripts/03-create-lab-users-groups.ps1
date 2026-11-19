<#
.SYNOPSIS
    Step 3 - Creates the GreenTech lab users, security groups, owners, memberships
    and manager links in a TEST Microsoft Entra tenant.

.DESCRIPTION
    Reads three CSV files from .\data:
        lab-users.csv        17 fictional employees
        lab-groups.csv       20 security groups (name, description, owner)
        lab-memberships.csv  group -> member (EmployeeID, or UPN prefix such as bg-emergency01)

    Safe to re-run: existing users, groups, owners and memberships are skipped.
    Works on Microsoft Entra ID Free (assigned security groups only, no premium features).

    No passwords are displayed or written to disk. Each user gets a random password
    and must change it at first sign-in. To sign in as a test user later, reset the
    password in the Entra admin center (Users > user > Reset password).

.PARAMETER TenantDomain
    Your lab tenant's initial domain, e.g. contosolab.onmicrosoft.com

.EXAMPLE
    .\03-create-lab-users-groups.ps1 -TenantDomain contosolab.onmicrosoft.com -WhatIf
    .\03-create-lab-users-groups.ps1 -TenantDomain contosolab.onmicrosoft.com

.NOTES
    Requires PowerShell 7 and the modules:
        Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Groups
    Sign in as the lab admin account (adm-...), not a break-glass account.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9-]+\.onmicrosoft\.com$')]
    [string]$TenantDomain,

    [string]$DataPath = (Join-Path $PSScriptRoot 'data')
)

$ErrorActionPreference = 'Stop'
$script:Log = [System.Collections.Generic.List[object]]::new()

function Write-Step {
    param([string]$Object, [string]$Action, [string]$Result, [string]$Detail = '')
    $entry = [pscustomobject]@{
        Time   = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Object = $Object
        Action = $Action
        Result = $Result
        Detail = $Detail
    }
    $script:Log.Add($entry)
    $colour = switch ($Result) { 'Created' { 'Green' } 'Added' { 'Green' } 'Skipped' { 'DarkGray' } 'WhatIf' { 'Cyan' } default { 'Red' } }
    Write-Host ("{0,-9} {1,-14} {2}  {3}" -f $Result, $Action, $Object, $Detail) -ForegroundColor $colour
}

function New-RandomPassword {
    # 24 random characters from a cryptographic RNG, plus a suffix that guarantees complexity rules.
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#%*-_=+'.ToCharArray()
    $bytes = [byte[]]::new(24)
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
    (-join ($bytes | ForEach-Object { $chars[$_ % $chars.Length] })) + 'Aa7!'
}

# ---------- Pre-flight ----------
foreach ($m in 'Microsoft.Graph.Authentication', 'Microsoft.Graph.Users', 'Microsoft.Graph.Groups') {
    if (-not (Get-Module -ListAvailable -Name $m)) {
        throw "Module $m is missing. Run: Install-Module $m -Scope CurrentUser"
    }
}
foreach ($f in 'lab-users.csv', 'lab-groups.csv', 'lab-memberships.csv') {
    if (-not (Test-Path (Join-Path $DataPath $f))) { throw "Missing data file: $(Join-Path $DataPath $f)" }
}

$users       = Import-Csv (Join-Path $DataPath 'lab-users.csv')
$groups      = Import-Csv (Join-Path $DataPath 'lab-groups.csv')
$memberships = Import-Csv (Join-Path $DataPath 'lab-memberships.csv')

Connect-MgGraph -TenantId $TenantDomain -Scopes 'User.ReadWrite.All', 'Group.ReadWrite.All' -NoWelcome
$ctx = Get-MgContext
Write-Host "`nConnected as $($ctx.Account) to $TenantDomain`n" -ForegroundColor Yellow

# Safety check: refuse to run against a tenant that has many users (i.e. probably not a lab).
$existingCount = (Get-MgUser -All -Property Id).Count
if ($existingCount -gt 60) {
    throw "Tenant already has $existingCount users. This script is for an empty TEST tenant only. Stopping."
}

$idByEmployeeId = @{}   # EmployeeID -> object id
$idByGroupName  = @{}   # GroupName  -> object id

function Resolve-Member {
    param([string]$Member)
    if ($Member -match '^(GT|CT)\d+$') { return $idByEmployeeId[$Member] }
    $u = Get-MgUser -Filter "userPrincipalName eq '$Member@$TenantDomain'" -Property Id -ErrorAction SilentlyContinue
    return $u.Id
}

# ---------- 1. Users ----------
Write-Host '--- Users ---' -ForegroundColor Yellow
foreach ($u in $users) {
    $upn = "$($u.UpnPrefix)@$TenantDomain"
    try {
        $existing = Get-MgUser -Filter "userPrincipalName eq '$upn'" -Property Id
        if ($existing) {
            $idByEmployeeId[$u.EmployeeID] = $existing.Id
            Write-Step $upn 'CreateUser' 'Skipped' 'already exists'
            continue
        }
        if (-not $PSCmdlet.ShouldProcess($upn, 'Create user')) { Write-Step $upn 'CreateUser' 'WhatIf'; continue }

        $body = @{
            accountEnabled    = $true
            displayName       = $u.DisplayName
            givenName         = $u.GivenName
            surname           = $u.Surname
            userPrincipalName = $upn
            mailNickname      = ($u.UpnPrefix -replace '[^A-Za-z0-9]', '')
            jobTitle          = $u.JobTitle
            department        = $u.Department
            employeeId        = $u.EmployeeID
            employeeType      = $u.EmployeeType
            employeeHireDate  = ([datetime]$u.HireDate).ToString('yyyy-MM-ddT00:00:00Z')
            officeLocation    = $u.OfficeLocation
            companyName       = 'GreenTech Solutions Ltd.'
            usageLocation     = 'CA'
            passwordProfile   = @{
                password                      = (New-RandomPassword)
                forceChangePasswordNextSignIn = $true
            }
        }
        $new = New-MgUser -BodyParameter $body
        $idByEmployeeId[$u.EmployeeID] = $new.Id
        Write-Step $upn 'CreateUser' 'Created' $u.JobTitle
    }
    catch { Write-Step $upn 'CreateUser' 'Error' $_.Exception.Message }
}

# ---------- 2. Manager links ----------
Write-Host "`n--- Managers ---" -ForegroundColor Yellow
foreach ($u in $users | Where-Object ManagerEmployeeID) {
    $uid = $idByEmployeeId[$u.EmployeeID]; $mid = $idByEmployeeId[$u.ManagerEmployeeID]
    if (-not $uid -or -not $mid) { Write-Step $u.DisplayName 'SetManager' 'Skipped' 'user or manager not created'; continue }
    try {
        $current = $null
        try { $current = Get-MgUserManager -UserId $uid -ErrorAction Stop } catch { }
        if ($current.Id -eq $mid) { Write-Step $u.DisplayName 'SetManager' 'Skipped' 'already set'; continue }
        if (-not $PSCmdlet.ShouldProcess($u.DisplayName, 'Set manager')) { Write-Step $u.DisplayName 'SetManager' 'WhatIf'; continue }
        Set-MgUserManagerByRef -UserId $uid -BodyParameter @{ '@odata.id' = "https://graph.microsoft.com/v1.0/users/$mid" }
        Write-Step $u.DisplayName 'SetManager' 'Added' "manager = $($u.ManagerEmployeeID)"
    }
    catch { Write-Step $u.DisplayName 'SetManager' 'Error' $_.Exception.Message }
}

# ---------- 3. Groups and owners ----------
Write-Host "`n--- Groups ---" -ForegroundColor Yellow
foreach ($g in $groups) {
    try {
        $existing = Get-MgGroup -Filter "displayName eq '$($g.GroupName)'" -Property Id
        if ($existing) {
            $idByGroupName[$g.GroupName] = @($existing)[0].Id
            Write-Step $g.GroupName 'CreateGroup' 'Skipped' 'already exists'
        }
        elseif ($PSCmdlet.ShouldProcess($g.GroupName, 'Create security group')) {
            $new = New-MgGroup -DisplayName $g.GroupName -Description $g.Description `
                -MailEnabled:$false -SecurityEnabled -MailNickname ($g.GroupName.ToLower() -replace '[^a-z0-9]', '')
            $idByGroupName[$g.GroupName] = $new.Id
            Write-Step $g.GroupName 'CreateGroup' 'Created' $g.Category
        }
        else { Write-Step $g.GroupName 'CreateGroup' 'WhatIf'; continue }

        $gid = $idByGroupName[$g.GroupName]; $oid = $idByEmployeeId[$g.OwnerEmployeeID]
        if (-not $oid) { Write-Step $g.GroupName 'AddOwner' 'Skipped' "owner $($g.OwnerEmployeeID) not found"; continue }
        $owners = Get-MgGroupOwner -GroupId $gid -All
        if ($owners.Id -contains $oid) { Write-Step $g.GroupName 'AddOwner' 'Skipped' 'already owner'; continue }
        if ($PSCmdlet.ShouldProcess($g.GroupName, "Add owner $($g.OwnerEmployeeID)")) {
            New-MgGroupOwnerByRef -GroupId $gid -BodyParameter @{ '@odata.id' = "https://graph.microsoft.com/v1.0/directoryObjects/$oid" }
            Write-Step $g.GroupName 'AddOwner' 'Added' $g.OwnerEmployeeID
        }
    }
    catch { Write-Step $g.GroupName 'CreateGroup' 'Error' $_.Exception.Message }
}

# ---------- 4. Memberships ----------
Write-Host "`n--- Memberships ---" -ForegroundColor Yellow
$cache = @{}
foreach ($m in $memberships) {
    $label = "$($m.Member) -> $($m.GroupName)"
    try {
        $gid = $idByGroupName[$m.GroupName]
        $mid = Resolve-Member $m.Member
        if (-not $gid -or -not $mid) { Write-Step $label 'AddMember' 'Skipped' 'group or member not found'; continue }
        if (-not $cache.ContainsKey($gid)) { $cache[$gid] = @((Get-MgGroupMember -GroupId $gid -All).Id) }
        if ($cache[$gid] -contains $mid) { Write-Step $label 'AddMember' 'Skipped' 'already member'; continue }
        if (-not $PSCmdlet.ShouldProcess($label, 'Add group member')) { Write-Step $label 'AddMember' 'WhatIf'; continue }
        New-MgGroupMember -GroupId $gid -DirectoryObjectId $mid
        $cache[$gid] += $mid
        Write-Step $label 'AddMember' 'Added'
    }
    catch { Write-Step $label 'AddMember' 'Error' $_.Exception.Message }
}

# ---------- Run log (domain redacted) ----------
$logDir = Join-Path $PSScriptRoot '..\08-testing\results'
New-Item -ItemType Directory -Force -Path $logDir -WhatIf:$false | Out-Null
$logFile = Join-Path $logDir ("step03-run-log-{0}.csv" -f (Get-Date -Format 'yyyyMMdd-HHmm'))
$script:Log | ForEach-Object { $_.Object = $_.Object -replace [regex]::Escape($TenantDomain), '<tenant>.onmicrosoft.com'; $_ } |
    Export-Csv $logFile -NoTypeInformation -WhatIf:$false

$summary = $script:Log | Group-Object Result | ForEach-Object { "$($_.Name)=$($_.Count)" }
Write-Host "`nSummary: $($summary -join '  ')" -ForegroundColor Yellow
Write-Host "Run log saved to $logFile"
if ($script:Log.Result -contains 'Error') { Write-Host 'Some actions failed - read the Error lines above.' -ForegroundColor Red }
