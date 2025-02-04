# Palume kasutajal sisestada eesnimi ja perenimi
$eesnimi = Read-Host "Sisestage eesnimi"
$perenimi = Read-Host "Sisestage perenimi"

# Loome kasutajanime formaadis ees.perenimi ja teisendame selle väikesteks tähtedeks
$kasutajanimi = "$($eesnimi).$($perenimi)".ToLower()

# Määrame kasutaja täisnime ja kirjelduse
$fullname = "$eesnimi $perenimi"
$kirjeldus = "Kasutaja $fullname"

# Kontrollime, kas kasutaja juba eksisteerib
if (Get-LocalUser -Name $kasutajanimi -ErrorAction SilentlyContinue) {
    Write-Host "Kasutaja '$kasutajanimi' juba eksisteerib. Skript katkestatakse."
    exit
}

# Püüame luua uue kohaliku kasutaja
try {
    New-LocalUser -Name $kasutajanimi -FullName $fullname -Description $kirjeldus -Password (ConvertTo-SecureString "Parool1!" -AsPlainText -Force) -PasswordNeverExpires
    Write-Host "Kasutaja '$kasutajanimi' on edukalt loodud."
} catch {
    Write-Host "Kasutaja loomine ebaõnnestus järgmise veateatega: $_"
}
