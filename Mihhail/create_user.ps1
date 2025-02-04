# Promptime jama
$firstName = Read-Host "Enter first name (Latin characters only)"
$lastName = Read-Host "Enter last name (Latin characters only)"

#  loome uue kasutaja
$username = "$($firstName.ToLower()).$($lastName.ToLower())"
$fullName = "$firstName $lastName"
$description = "User: $fullName"

# Create local user
$password = ConvertTo-SecureString "Parool1!" -AsPlainText -Force
$userParams = @{
    Name = $username
    FullName = $fullName
    Description = $description
    Password = $password
    PasswordNeverExpires = $true
}

try {
    New-LocalUser @userParams
    Write-Host "User $username created successfully."
} catch {
    Write-Host "Failed to create user $username. Error: $_"
}

# Check if the user was created successfully
if ($?) {
    Write-Host "User creation succeeded."
} else {
    Write-Host "kasutaja ei loodud, asi on kaput."
}