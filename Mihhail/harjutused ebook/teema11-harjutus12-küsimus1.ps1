function Count-Services {
    param ([string]$status)
    $count = (Get-Service   -ErrorAction SilentlyContinue  | Where-Object { $_.Status -eq $status }).Count
    Write-Host "Total services in $status state: $count"
}

Count-Services -status Running
Count-Services -status Stopped
