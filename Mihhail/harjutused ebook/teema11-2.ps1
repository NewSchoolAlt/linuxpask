for($i = 1 ; $i -le 10 ; $i++)
{
$colors = @("Green", "Cyan", "Magenta", "Yellow", "Red", "Blue", "White", "Gray", "DarkGreen", "DarkCyan")
Write-Host "Current value : "$i -ForegroundColor $colors[$i - 1]
}