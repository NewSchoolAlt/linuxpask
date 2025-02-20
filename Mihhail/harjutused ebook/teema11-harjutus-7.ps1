
# Define the colors
$colors = @("Red", "Green", "Yellow", "Blue")

# Initialize the random number generator
$random = New-Object System.Random

# Create a table for the output
$table = @()

# Assign a random color to each student
for ($i = 1; $i -le 20; $i++) {
    $color = $colors[$random.Next(0, $colors.Length)]
    $table += [PSCustomObject]@{
        RollNumber = $i
        Group = $color
    }
}

# Output the table
$table | Format-Table -AutoSize
