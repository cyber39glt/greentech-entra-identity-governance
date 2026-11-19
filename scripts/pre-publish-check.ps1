<#
.SYNOPSIS
    Run before uploading to GitHub. Scans the project for things that must not be published:
    your real tenant domain, GUIDs (tenant/object IDs), real email addresses, unredacted
    evidence folders, and unfinished placeholders. Read-only.

.EXAMPLE
    .\pre-publish-check.ps1 -TenantDomain yourtenant.onmicrosoft.com
#>
param(
    [Parameter(Mandatory)][string]$TenantDomain,
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..'))
)

$problems = [System.Collections.Generic.List[object]]::new()
function Add-Problem($File, $Line, $Issue) { $problems.Add([pscustomobject]@{ File = $File; Line = $Line; Issue = $Issue }) }

foreach ($bad in 'raw-evidence', 'secrets') {
    if (Test-Path (Join-Path $Root $bad)) {
        Add-Problem $bad '' "Folder exists. Do NOT upload it (GitHub web upload ignores .gitignore)."
    }
}

$allowedEmail = 'greentech\.example|partner\.example|<tenant>|yourtenant\.onmicrosoft|noreply|example\.com'
$textFiles = Get-ChildItem $Root -Recurse -File -Include *.md, *.csv, *.ps1, *.txt, *.json |
    Where-Object { $_.FullName -notmatch '\\raw-evidence\\|/raw-evidence/' }

foreach ($f in $textFiles) {
    $rel = $f.FullName.Substring($Root.ToString().Length).TrimStart('\', '/')
    $n = 0
    foreach ($line in Get-Content $f.FullName) {
        $n++
        if ($line -match [regex]::Escape($TenantDomain)) { Add-Problem $rel $n 'Real tenant domain' }
        if ($line -match '\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b') { Add-Problem $rel $n 'GUID (possible tenant or object ID)' }
        foreach ($m in [regex]::Matches($line, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')) {
            if ($m.Value -notmatch $allowedEmail) { Add-Problem $rel $n "Email address: $($m.Value)" }
        }
        if ($rel -notmatch 'pre-publish-check' -and $line -match '⬜|_{6,}') { Add-Problem $rel $n 'Unfinished placeholder (⬜ or ______)' }
    }
}

$images = Get-ChildItem (Join-Path $Root '09-evidence') -Recurse -File -Include *.png, *.jpg, *.jpeg -ErrorAction SilentlyContinue
Write-Host "`n$($images.Count) screenshots in 09-evidence - open each one and confirm your domain, tenant ID and email are blacked out." -ForegroundColor Yellow

if ($problems.Count -eq 0) {
    Write-Host 'No problems found. Safe to publish (after checking screenshots).' -ForegroundColor Green
}
else {
    $problems | Format-Table -AutoSize -Wrap
    Write-Host "$($problems.Count) item(s) to fix before publishing." -ForegroundColor Red
}
