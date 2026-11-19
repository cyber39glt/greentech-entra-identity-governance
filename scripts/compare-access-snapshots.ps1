<#
.SYNOPSIS
    Compares the latest "Before" and "After" access snapshots for a ticket and
    shows exactly what changed: groups removed/added, roles removed/added, fields changed.
    Read-only: it only reads files in 09-evidence\snapshots.

.EXAMPLE
    .\compare-access-snapshots.ps1 -Ticket JML-2026-002
#>
param(
    [Parameter(Mandatory)][string]$Ticket,
    [string]$SnapshotDir = (Join-Path $PSScriptRoot '..\09-evidence\snapshots')
)
$ErrorActionPreference = 'Stop'

function Get-Latest([string]$Label) {
    $f = Get-ChildItem $SnapshotDir -Filter "$Ticket-*-$Label-*.md" | Sort-Object Name | Select-Object -Last 1
    if (-not $f) { throw "No '$Label' snapshot found for $Ticket in $SnapshotDir. Run get-user-access-snapshot.ps1 with -Label $((Get-Culture).TextInfo.ToTitleCase($Label)) first." }
    $f
}

function Read-Snapshot($File) {
    $fields = [ordered]@{}; $lists = @{}; $section = $null
    foreach ($line in Get-Content $File.FullName) {
        if ($line -match '^\| (.+?) \| (.*) \|$' -and $Matches[1] -notin 'Field', '---', 'Taken', 'Taken by') {
            $fields[$Matches[1]] = $Matches[2]
        }
        elseif ($line -match '^## (.+?) \(\d+\)') { $section = $Matches[1]; $lists[$section] = @() }
        elseif ($section -and $line -match '^- (.+)$' -and $Matches[1] -ne '(none)') { $lists[$section] += $Matches[1] }
    }
    [pscustomobject]@{ Fields = $fields; Lists = $lists }
}

$bFile = Get-Latest 'before'; $aFile = Get-Latest 'after'
$b = Read-Snapshot $bFile; $a = Read-Snapshot $aFile

$out = @("# Access change report - $Ticket", '', "Before: ``$($bFile.Name)``  ", "After: ``$($aFile.Name)``", '', '## Attribute changes', '', '| Field | Before | After |', '|---|---|---|')
$changed = 0
foreach ($k in $b.Fields.Keys) {
    if ($b.Fields[$k] -ne $a.Fields[$k]) { $out += "| $k | $($b.Fields[$k]) | $($a.Fields[$k]) |"; $changed++ }
}
if ($changed -eq 0) { $out += '| (no changes) | | |' }

foreach ($section in 'Group memberships', 'Admin roles', 'Objects owned') {
    $before = @($b.Lists[$section]); $after = @($a.Lists[$section])
    $removed = @($before | Where-Object { $_ -notin $after })
    $added = @($after | Where-Object { $_ -notin $before })
    $kept = @($before | Where-Object { $_ -in $after })
    $out += '', "## $section", ''
    $out += "- **Removed ($($removed.Count)):** $(if ($removed) { $removed -join ', ' } else { 'none' })"
    $out += "- **Added ($($added.Count)):** $(if ($added) { $added -join ', ' } else { 'none' })"
    $out += "- **Unchanged ($($kept.Count)):** $(if ($kept) { $kept -join ', ' } else { 'none' })"
}

$report = Join-Path $SnapshotDir "$Ticket-change-report.md"
$out | Set-Content $report -Encoding utf8
$out | ForEach-Object { Write-Host $_ }
Write-Host "`nSaved to $report" -ForegroundColor Green
