$array1 = @(1,2,3)
$array2 = @(4,5,6)
$array3 = @()
$array3 += $array1[0] + $array2[0]
$array3 += $array1[1] + $array2[1]
$array3 += $array1[2] + $array2[2]
$array3