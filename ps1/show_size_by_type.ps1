# /*
# * Project: ps1
# * Created: 2024-04-15 19:52:18
# * Modified: 2024-04-15 19:52:18
# * Author: mcxiaoke (github@mcxiaoke.com)
# * License: Apache License 2.0
# */

param (
    [string]$Path,
    [string[]]$Extensions = @("avi", "mp4", "mkv", "mp3", "m4a", "wav", "ape", "flac", "7z", "zip", "rar")
)

function Get-FilesByExtension {
    param (
        [string]$Path,
        [string[]]$Extensions
    )

    Get-ChildItem -Path $Path -Recurse |
    Where-Object { !$_.PSIsContainer -and $Extensions -contains $_.Extension.Substring(1) } |
    Where-Object { $_.Length -gt 20kb } |
    Select-Object FullName, @{Name = "Size(MB)"; Expression = { [math]::Round($_.Length / 1MB, 2) } }
}

$Result = @{}

foreach ($Extension in $Extensions) {
    $Files = Get-FilesByExtension -Path $Path -Extensions $Extension
    if ($Files) {
        $Result[$Extension] = $Files | Measure-Object -Property "Size(MB)" -Sum | Select-Object -ExpandProperty Sum
    }
}

if ($Result.Count -gt 0) {
    Write-Host "Extension | Total Size (MB)"
    Write-Host "----------|----------------"
    foreach ($Extension in $Result.Keys) {
        Write-Host "$Extension | $($Result[$Extension].ToString("0.00"))"
    }
}
else {
    Write-Host "No files found."
}