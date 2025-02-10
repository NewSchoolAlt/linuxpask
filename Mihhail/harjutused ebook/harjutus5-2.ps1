$files = Get-ChildItem -Path "C:\temp\test"
foreach ($file in $files) {
    Write-Host "FileName : " $file.Name
    $sizeKB = [math]::Round($file.Length / 1KB, 2)
    $sizeMB = [math]::Round($file.Length / 1MB, 2)
    Write-Host "Size in KB : " $sizeKB
    Write-Host "Size in MB : " $sizeMB
}