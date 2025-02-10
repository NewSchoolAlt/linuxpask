$csv = Import-Csv C:\temp\students.csv -Header Name, Age

$csv | ForEach-Object {
    if ($_.'Age' -lt 18) {
        $_ | Add-Member -NotePropertyName 'Status' -NotePropertyValue 'Junior' -Force
    } else {
        $_ | Add-Member -NotePropertyName 'Status' -NotePropertyValue 'Senior' -Force
    }
}

$csv | Format-Table -Property Name, Age, Status -AutoSize