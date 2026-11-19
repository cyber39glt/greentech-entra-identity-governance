<#
.SYNOPSIS
    Records everything a user can access at this moment: account status, attributes,
    manager, groups, admin roles, owned objects and MFA methods. Read-only.

.DESCRIPTION
    Used as evidence in the joiner, mover, leaver and contractor procedures:
    take a "Before" snapshot, make the change, take an "After" snapshot, compare.
    Saves a Markdown file to 09-evidence\snapshots with your tenant domain redacted.

.EXAMPLE
    .\get-user-access-snapshot.ps1 -UserPrincipalName adaeze.lindqvist@yourtenant.onmicrosoft.com -Ticket JML-2026-001 -Label After

.NOTES
    Connect first (one time per PowerShell window):
      Connect-MgGraph -TenantId yourtenant.onmicrosoft.com -Scopes "Directory.Read.All","UserAuthenticationMethod.Read.All"
    MFA methods need the module Microsoft.Graph.Identity.SignIns (optional).
#>
param(
    [Parameter(Mandatory)][string]$UserPrincipalName,
    [Parameter(Mandatory)][string]$Ticket,
    [Parameter(Mandatory)][ValidateSet('Before', 'After', 'Check')][string]$Label,
    [string]$OutDir = (Join-Path $PSScriptRoot '..\09-evidence\snapshots')
)

$ErrorActionPreference = 'Stop'
if (-not (Get-MgContext)) {
    throw 'Not connected. Run Connect-MgGraph first (see the NOTES section at the top of this script).'
}

$domain = ($UserPrincipalName -split '@')[1]
function Hide-Domain([string]$Text) { if ($Text) { $Text -replace [regex]::Escape($domain), '<tenant>.onmicrosoft.com' } else { $Text } }

$u = Get-MgUser -UserId $UserPrincipalName -Property Id, DisplayName, UserPrincipalName, AccountEnabled, Department, JobTitle, `
    EmployeeId, EmployeeType, EmployeeHireDate, UserType, CompanyName, CreatedDateTime

$mgr = $null
try { $mgr = Get-MgUserManager -UserId $u.Id -ErrorAction Stop } catch { }
$mgrName = if ($mgr) { $mgr.AdditionalProperties['displayName'] } else { '(none)' }

$memberOf = @(Get-MgUserMemberOf -UserId $u.Id -All)
$groups = @($memberOf | Where-Object { $_.AdditionalProperties['@odata.type'] -eq '#microsoft.graph.group' } |
    ForEach-Object { $_.AdditionalProperties['displayName'] } | Sort-Object)
$roles = @($memberOf | Where-Object { $_.AdditionalProperties['@odata.type'] -eq '#microsoft.graph.directoryRole' } |
    ForEach-Object { $_.AdditionalProperties['displayName'] } | Sort-Object)
$owned = @(Get-MgUserOwnedObject -UserId $u.Id -All | ForEach-Object { $_.AdditionalProperties['displayName'] } | Sort-Object)

$methods = 'not checked (install module Microsoft.Graph.Identity.SignIns)'
if (Get-Command Get-MgUserAuthenticationMethod -ErrorAction SilentlyContinue) {
    try {
        $methods = (@(Get-MgUserAuthenticationMethod -UserId $u.Id | ForEach-Object {
            $_.AdditionalProperties['@odata.type'] -replace '#microsoft.graph.', '' -replace 'AuthenticationMethod', ''
        }) | Sort-Object) -join ', '
    }
    catch { $methods = 'unavailable (connect with UserAuthenticationMethod.Read.All)' }
}

$now = Get-Date
$lines = @(
    "# Access snapshot - $Ticket - $Label"
    ''
    "| Field | Value |"
    "|---|---|"
    "| Taken | $($now.ToString('yyyy-MM-dd HH:mm')) (local time) |"
    "| Taken by | $(Hide-Domain (Get-MgContext).Account) |"
    "| User | $($u.DisplayName) |"
    "| UPN | $(Hide-Domain $u.UserPrincipalName) |"
    "| Account enabled | $($u.AccountEnabled) |"
    "| User type | $($u.UserType) |"
    "| Employee ID | $($u.EmployeeId) |"
    "| Employee type | $($u.EmployeeType) |"
    "| Department | $($u.Department) |"
    "| Job title | $($u.JobTitle) |"
    "| Company | $($u.CompanyName) |"
    "| Hire date | $(if ($u.EmployeeHireDate) { $u.EmployeeHireDate.ToString('yyyy-MM-dd') }) |"
    "| Manager | $mgrName |"
    "| MFA / sign-in methods | $methods |"
    ''
    "## Group memberships ($($groups.Count))"
    ''
) + $(if ($groups) { $groups | ForEach-Object { "- $_" } } else { '- (none)' }) + @(
    ''
    "## Admin roles ($($roles.Count))"
    ''
) + $(if ($roles) { $roles | ForEach-Object { "- $_" } } else { '- (none)' }) + @(
    ''
    "## Objects owned ($($owned.Count))"
    ''
) + $(if ($owned) { $owned | ForEach-Object { "- $_" } } else { '- (none)' })

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$prefix = ($UserPrincipalName -split '@')[0]
$file = Join-Path $OutDir ("{0}-{1}-{2}-{3}.md" -f $Ticket, $prefix, $Label.ToLower(), $now.ToString('yyyyMMdd-HHmm'))
$lines | Set-Content -Path $file -Encoding utf8

$lines | ForEach-Object { Write-Host $_ }
Write-Host "`nSaved to $file" -ForegroundColor Green
