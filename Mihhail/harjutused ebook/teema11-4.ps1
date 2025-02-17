while (Get-Service Fax  | Where-Object{$_.Status -eq "Stopped"}) 
{
    Write-Host "Stopped" -ForegroundColor Red
    Start-Sleep -Seconds 2 
}