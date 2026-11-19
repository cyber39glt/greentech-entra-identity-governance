<#
.SYNOPSIS
    Step 3 verification - compares the tenant against the design CSVs and reports PASS/FAIL.
    Read-only: makes no changes.

.EXAMPLE
    .\03-verify-lab-users-groups.ps1 -TenantDomain contosolab.onmicrosoft.com
#>
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9-]+\.onmicrosoft\.com$')]
    [string]$TenantDomain,

    [string]$DataPath = (Join-Path $PSScriptRoot 'data')
)

$ErrorActionPreference = 'Stop'
Connect-MgGraph -TenantId $TenantDomain -Scopes 'User.Read.All', 'GroupMember.Read.All' -NoWelcome

$users       = Import-Csv (Join-Path $DataPath 'lab-users.csv')
$groups      = Import-Csv (Join-Path $DataPath 'lab-groups.csv')
$memberships = Import-Csv (Join-Path $DataPath 'lab-memberships.csv')
$results = [System.Collections.Generic.List[object]]::new()

function Add-Result($Test, $Expected, $Actual) {
    $results.Add([pscustomobject]@{
        Test     = $Test
        Expected = $Expected
        Actual   = $Actual
        Result   = if ("$Expected" -eq "$Actual") { 'PASS' } else { 'FAIL' }
    })
}

$idByEmployeeId = @{}; $empByObjectId = @{}
foreach ($u in $users) {
    $upn = "$($u.UpnPrefix)@$TenantDomain"
    $x = Get-MgUser -Filter "userPrincipalName eq '$upn'" -Property Id, Department, JobTitle, EmployeeId, AccountEnabled -ErrorAction SilentlyContinue
    Add-Result "User exists: $($u.EmployeeID)" 'True' ([bool]$x)
    if (-not $x) { continue }
    $idByEmployeeId[$u.EmployeeID] = $x.Id; $empByObjectId[$x.Id] = $u.EmployeeID
    Add-Result "Department: $($u.EmployeeID)" $u.Department $x.Department
    Add-Result "Job title: $($u.EmployeeID)" $u.JobTitle $x.JobTitle
    Add-Result "Enabled: $($u.EmployeeID)" 'True' $x.AccountEnabled
}

foreach ($u in $users | Where-Object ManagerEmployeeID) {
    if (-not $idByEmployeeId[$u.EmployeeID]) { continue }
    $mgr = $null
    try { $mgr = Get-MgUserManager -UserId $idByEmployeeId[$u.EmployeeID] -ErrorAction Stop } catch { }
    Add-Result "Manager: $($u.EmployeeID)" $u.ManagerEmployeeID $(if ($mgr) { $empByObjectId[$mgr.Id] } else { '(none)' })
}

foreach ($g in $groups) {
    $x = @(Get-MgGroup -Filter "displayName eq '$($g.GroupName)'" -Property Id, SecurityEnabled)[0]
    Add-Result "Group exists: $($g.GroupName)" 'True' ([bool]$x)
    if (-not $x) { continue }
    $owners = @((Get-MgGroupOwner -GroupId $x.Id -All).Id | ForEach-Object { $empByObjectId[$_] })
    Add-Result "Owner: $($g.GroupName)" $g.OwnerEmployeeID ($owners -join ';')

    $expected = @($memberships | Where-Object GroupName -eq $g.GroupName | ForEach-Object Member | Sort-Object)
    $actual = @(Get-MgGroupMember -GroupId $x.Id -All | ForEach-Object {
        if ($empByObjectId[$_.Id]) { $empByObjectId[$_.Id] }
        else { ($_.AdditionalProperties['userPrincipalName'] -split '@')[0] }
    } | Sort-Object)
    Add-Result "Members: $($g.GroupName)" ($expected -join ';') ($actual -join ';')
}

$out = Join-Path $PSScriptRoot ("..\08-testing\results\step03-verification-{0}.csv" -f (Get-Date -Format 'yyyyMMdd-HHmm'))
New-Item -ItemType Directory -Force -Path (Split-Path $out) | Out-Null
$results | Export-Csv $out -NoTypeInformation

$results | Where-Object Result -eq 'FAIL' | Format-Table -AutoSize
$pass = @($results | Where-Object Result -eq 'PASS').Count
Write-Host ("{0} of {1} checks passed. Results saved to {2}" -f $pass, $results.Count, $out) -ForegroundColor $(if ($pass -eq $results.Count) { 'Green' } else { 'Red' })
