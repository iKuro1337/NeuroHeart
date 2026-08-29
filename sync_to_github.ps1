# sync_to_github.ps1
# Wysyla na GitHub (repo iKuro1337/NeuroHeart, przez SSH) biezacy stan
# plikow z GLOWNEGO folderu NeuroHeart. Podfoldery sa pomijane (.gitignore).
#
# Uzycie: uruchom ten skrypt z folderu NeuroHeart (albo dwuklik w Eksploratorze).

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

git add -A

$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Host "Brak zmian do wyslania - repo jest juz aktualne."
    exit 0
}

$msg = "Aktualizacja plikow - " + (Get-Date -Format "yyyy-MM-dd HH:mm")
git commit -m $msg

git push origin main

Write-Host "Gotowe - zmiany wyslane na GitHub (iKuro1337/NeuroHeart)."
