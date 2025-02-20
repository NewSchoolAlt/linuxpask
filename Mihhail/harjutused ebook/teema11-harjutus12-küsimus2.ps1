function countservice
{
param
(
[string]$status
)
if($status -eq "Running")
{
$start = Get-Service  -ErrorAction SilentlyContinue  | ?{$_.Status -eq "Running"}
Write-Host "Total services in running state = "$start.count
}
elseif($status -eq "Stopped")
{
$stop = Get-Service -ErrorAction SilentlyContinue   | ?{$_.Status -eq "Stopped"}
Write-Host "Total services in stopped state = "$stop.count
}
}
countservice -status Running
countservice -status Stopped