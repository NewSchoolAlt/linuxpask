function mainmenu {
    Write-Host "`t`t`tArea Calculator" -ForegroundColor Green
    Write-Host "`n`t`t`tMain Menu" -ForegroundColor Yellow
    Write-Host "`nPlease select the option to perform the respective task`n" -ForegroundColor Yellow
    Write-Host "1: Area of Square" -ForegroundColor Green
    Write-Host "2: Area of Rectangle" -ForegroundColor Green
    Write-Host "3: Area of Circle" -ForegroundColor Green
    Write-Host "4: Area of Triangle" -ForegroundColor Green
    Write-Host "5: Area of Trapezoid" -ForegroundColor Green
    Write-Host "6: Exit`n" -ForegroundColor Green
    $choice = Read-Host "Enter your choice"
    return $choice
}

function checkmenu {
    Write-Host "`n`nPlease select the next option" -ForegroundColor Yellow
    Write-Host "`n1: Return to Main Menu" -ForegroundColor Green
    Write-Host "2: Exit`n" -ForegroundColor Green
    $ch2 = Read-Host "Enter your choice"
    if ($ch2 -eq "1") {
        continue
    }
    if ($ch2 -eq "2") {
        exit
    } else {
        Write-Host "`nEnter correct option" -ForegroundColor Red
        checkmenu
    }
}

function square {
    cls
    Write-Host "`t`t`tArea of Square`n" -ForegroundColor Green
    [int]$side = Read-Host "Enter the side of the square"
    $area = $side * $side
    Write-Host "`nArea of the square : "$area -ForegroundColor Green
    checkmenu
}

function rectangle {
    cls
    Write-Host "`t`tArea of Rectangle`n" -ForegroundColor Green
    [int]$length = Read-Host "Enter length of the rectangle"
    [int]$breadth = Read-Host "Enter breadth of the rectangle"
    $area = $length * $breadth
    Write-Host "`nArea of the rectangle : "$area -ForegroundColor Green
    checkmenu
}

function circle {
    cls
    Write-Host "`t`tArea of Circle`n" -ForegroundColor Green
    [int]$radius = Read-Host "Enter the radius of the circle"
    $area = 3.14 * $radius * $radius
    Write-Host "`nArea of the circle : "$area -ForegroundColor Green
    checkmenu
}

function triangle {
    cls
    Write-Host "`t`tArea of Triangle`n" -ForegroundColor Green
    [int]$height = Read-Host "Enter height of triangle"
    [int]$base = Read-Host "Enter base of triangle"
    $area = 0.5 * $height * $base
    Write-Host "`nArea of Triangle : "$area -ForegroundColor Green
    checkmenu
}

function trapezoid {
    cls
    Write-Host "`t`tArea of Trapezoid`n" -ForegroundColor Green
    [int]$base1 = Read-Host "Enter the length of the first base of the trapezoid"
    [int]$base2 = Read-Host "Enter the length of the second base of the trapezoid"
    [int]$height = Read-Host "Enter the height of the trapezoid"
    $area = 0.5 * ($base1 + $base2) * $height
    Write-Host "`nArea of the trapezoid : "$area -ForegroundColor Green
    checkmenu
}

do {
    cls
    $ch1 = mainmenu
    switch ($ch1) {
        1 {
            cls
            square
            checkmenu
        }
        2 {
            cls
            rectangle
            checkmenu
        }
        3 {
            cls
            circle
            checkmenu
        }
        4 {
            cls
            triangle
            checkmenu
        }
        5 {
            cls
            trapezoid
            checkmenu
        }
    }
} while ($ch1 -ne "6")