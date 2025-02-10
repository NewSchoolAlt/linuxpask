Write-Host "Select Country" -ForegroundColor Yellow
Write-Host "1 : India" -ForegroundColor Cyan
Write-Host "2: Estonia ehk Eesti noh" -ForegroundColor Cyan
Write-Host "3: China" -ForegroundColor Cyan
$choice = Read-Host "Please select country"
if($choice -eq "1")
{
Write-Host "India's capital is uhhh...... the hub of indian youtube tutorial yes yes 👍" -ForegroundColor Green
}
elseif($choice -eq "2")
{
Write-Host "Eesti's capital is Tallinn" -ForegroundColor Green
}
elseif($choice -eq "3") {
Write-Host "China's capital is bing chilling noh mdea" -ForegroundColor Green
}
else
{
Write-Host "Kaput" -ForegroundColor Red
}