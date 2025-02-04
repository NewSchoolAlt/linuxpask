# Küsib kasutaja eesnime
$firstName = Read-Host "Enter the user's esi nimi"
# Küsib kasutaja perekonnanime
$lastName = Read-Host "Enter the user's perekonna nimi"

# Koostab kasutajanime (eesnime esimene täht + perekonnanimi)
$username = ($firstName.Substring(0,1) + $lastName).ToLower()

# Kontrollib, kas kasutaja juba eksisteerib
if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
    # Kuvab veateate, kui kasutajanimi on juba olemas
    Write-Host "Error: A user with the kasutajanimi '$username' juba on, ehk siis on kaput."
} else {
    # Loob turvalise parooli
    $password = Read-Host "Enter a password for uus user" -AsSecureString

    # Loob uue kohaliku kasutaja
    New-LocalUser -Name $username -FullName "$firstName $lastName" -Password $password -PasswordNeverExpires:$true

    # Kuvab teate, et kasutaja on edukalt loodud
    Write-Host "User '$username' has been loodud successfully noh, mihhail oled happy  v?."
}
