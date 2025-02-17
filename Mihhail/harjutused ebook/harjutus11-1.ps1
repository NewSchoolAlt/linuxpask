$result = @() ## Empty table to store the information

$services = Get-Content C:\temp\Services.txt ## List of services whose status has

## to be checked

foreach($s in $services)
    {
        $data = $null
        $service = Get-Service $s -ErrorAction SilentlyContinue
        if ($service) {
            $data = $service | Select-Object Name,Status
        } else {
            $data = [PSCustomObject]@{ Name = $s; Status = "Not Found" }
        }
        $result += $data
    }
$result | Format-Table -AutoSize