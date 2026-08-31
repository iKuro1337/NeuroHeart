# sync_to_github.ps1
# Wysyla na GitHub (repo iKuro1337/NeuroHeart, przez SSH) biezacy stan
# plikow z GLOWNEGO folderu NeuroHeart. Podfoldery sa pomijane (.gitignore).
#
# Dodatkowo: przed wyslaniem, kopiuje NAJNOWIEJ ZMODYFIKOWANY plik .html
# z glownego folderu (pomijajac index.html i Plomien_Track.html) do
# index.html - to on jest "aktualna karta postaci" pokazywana przez
# GitHub Pages. Dzieki temu nie trzeba pamietac o recznym kopiowaniu przy
# kazdej zmianie nazwy/wersji pliku karty.
#
# Uzycie: uruchom ten skrypt z folderu NeuroHeart (albo dwuklik w sync_to_github.bat).

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

# --- Krok 1: znajdz "aktualna karte postaci" i skopiuj ja do index.html ---
$excluded = @("index.html", "Plomien_Track.html")

$candidate = Get-ChildItem -Path $PSScriptRoot -Filter *.html -File |
    Where-Object { $excluded -notcontains $_.Name } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if ($candidate) {
    $indexPath = Join-Path $PSScriptRoot "index.html"
    $needsCopy = $true
    if (Test-Path $indexPath) {
        $existingHash = (Get-FileHash -Path $indexPath -Algorithm SHA256).Hash
        $candidateHash = (Get-FileHash -Path $candidate.FullName -Algorithm SHA256).Hash
        $needsCopy = ($existingHash -ne $candidateHash)
    }
    if ($needsCopy) {
        Copy-Item -Path $candidate.FullName -Destination $indexPath -Force
        Write-Host "Skopiowano '$($candidate.Name)' do index.html (nowa aktualna karta postaci)."
    } else {
        Write-Host "index.html juz odpowiada '$($candidate.Name)' - bez zmian."
    }
} else {
    Write-Host "UWAGA: nie znaleziono zadnego pliku .html z karta postaci w glownym folderze - index.html NIE zostal zaktualizowany."
}

# --- Krok 2: standardowy add / commit / push ---
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
