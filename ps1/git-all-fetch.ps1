param()
function Get-AllRepos () {
    Get-ChildItem -Recurse -Depth 2 -Force |
    Where-Object { $_.Mode -match "h" -and $_.FullName -like "*\.git" } |
    ForEach-Object {
        $dir = Get-Item (Join-Path $_.FullName "../")
        Push-Location $dir
        "Fetching $($dir.Name)"
        git fetch -p
        Pop-Location
    }
}
Get-AllRepos