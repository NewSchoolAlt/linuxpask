# Funktsioon kõigi kohalike kasutajakontode loetlemiseks
function List-LocalUsers {
    $users = Get-LocalUser
    if ($users.Count -eq 0) {
        Write-Host "Kohalikke kasutajakontosid ei leitud."
    } else {
        Write-Host "Kohalikud kasutajakontod:"
        $users | ForEach-Object { Write-Host $_.Name }
    }
}

# Küsib, kas loetleda kõik kasutajad
$listUsers = Read-Host "Kas soovite loetleda kõik kohalikud kasutajakontod? (Y/N)"
if ($listUsers -eq 'Y') {
    List-LocalUsers
}

# Küsib kasutaja eesnime
$firstName = Read-Host "Sisestage kasutaja eesnimi"
# Küsib kasutaja perekonnanime
$lastName = Read-Host "Sisestage kasutaja perekonnanimi"

# Koostab kasutajanime (eesnime esimene täht + perekonnanimi)
$username = ($firstName.Substring(0,1) + $lastName).ToLower()

# Kontrollib, kas kasutaja eksisteerib
$user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if ($null -eq $user) {
    Write-Host "Viga: Kasutajanimega '$username' kasutajat ei eksisteeri."
} else {
    # Kinnitab kustutamise
    $confirm = Read-Host "Kas olete kindel, et soovite kasutaja '$username' kustutada? (Y/N)"
    if ($confirm -eq 'Y') {
        # Kustutab kasutaja
        Remove-LocalUser -Name $username
        Write-Host "Kasutaja '$username' on edukalt kustutatud."
    } else {
        Write-Host "Kasutaja kustutamine tühistatud."
    }
}
