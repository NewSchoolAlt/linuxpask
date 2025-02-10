$value1 = Read-Host "Enter the first value"
$value2 = Read-Host "Enter the second value"
if([int]$value1 -gt [int]$value2)
{
    Write-Host "The higher number is : " -NoNewline
    Write-Host $value1 -ForegroundColor Green
}
else
{
    Write-Host "The higher number is : " -NoNewline
    Write-Host $value2 -ForegroundColor Green
}