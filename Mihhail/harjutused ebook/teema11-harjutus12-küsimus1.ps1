function countstart
{
    $start = Get-Service -ErrorAction SilentlyContinue | ?{$_.Status -eq "Running"}
    Write-Host "Total services in running state = "$start.count
}
function countstop
{
    $stop = Get-Service -ErrorAction SilentlyContinue | ?{$_.Status -eq "Stopped"}
    Write-Host "Total services in stopped state = "$stop.count
}
countstart
countstop