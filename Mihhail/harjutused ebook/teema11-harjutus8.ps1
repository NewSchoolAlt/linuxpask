
while (Get-Process -Name "notepad" -ErrorAction SilentlyContinue) {
    Write-Output "Notepad is running from Mihhail"
    Start-Sleep -Seconds 1
}
Write-Output "Notepad has been but down. ai ai ai, kaput"
