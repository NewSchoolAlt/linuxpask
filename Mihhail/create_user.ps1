# Küsib kasutaja eesnime
$firstName = Read-Host "Enter the user's first name"
# Küsib kasutaja perekonnanime
$lastName = Read-Host "Enter the user's last name"

# Koostab kasutajanime (eesnime esimene täht + perekonnanimi)
$username = ($firstName.Substring(0,1) + $lastName).ToLower()

# Kontrollib, kas kasutaja juba eksisteerib
if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
    # Kuvab veateate, kui kasutajanimi on juba olemas
    Write-Host "Error: A user with the username '$username' already exists."
} else {
    # Loob turvalise parooli
    $password = Read-Host "Enter a password for the new user" -AsSecureString

    # Loob uue kohaliku kasutaja
    New-LocalUser -Name $username -FullName "$firstName $lastName" -Password $password -PasswordNeverExpires:$true

    # Kuvab teate, et kasutaja on edukalt loodud
    Write-Host "User '$username' has been created successfully."
}
