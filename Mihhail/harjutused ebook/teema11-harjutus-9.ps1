$count = 0
do {
    if (Get-Process -Name "notepad" -ErrorAction SilentlyContinue) {
        Write-Output "Notepad is running from Mihhail"
        $count++
        Start-Sleep -Seconds 1
    }
} while (Get-Process -Name "notepad" -ErrorAction SilentlyContinue)
Write-Output "Notepad has been but down. ai ai ai, kaput"
Write-Output "The statement was displayed $count times."
