function Get-CSVdata {
    param (
        [string[]]$CorrectHeaders
    )

    # Open file select popup
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
    $OpenFileDialog.filter = 'CSV (*.csv)|*.csv'
    $result = $OpenFileDialog.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))

    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        throw "No file selected."
    }

    $filePath = $OpenFileDialog.FileName

    # Read the first few lines of the file
    $sampleContent = Get-Content -Path $filePath -TotalCount 5

    # Detect delimiter
    $delimiters = @(',', ';', "`t", '|')
    $delimiter = $delimiters | Where-Object {
        ($sampleContent[0] -split $_ | Measure-Object).Count -gt 1 -and
        ($sampleContent[1] -split $_ | Measure-Object).Count -eq ($sampleContent[0] -split $_ | Measure-Object).Count
    } | Select-Object -First 1

    # Fallback to comma if no clear delimiter is detected
    if (-not $delimiter) {
        throw "Failed to detect delimiter."
    } else {
        Write-Host "CSV file delimiter detected as '$delimiter'"
    }

    # Import CSV with detected delimiter
    $csvContent = Import-Csv -Path $filePath -Delimiter $delimiter

    # Get the headers from the CSV file
    $csvHeaders = $csvContent | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

    # Check if all correct headers are present in the CSV
    $missingHeaders = $CorrectHeaders | Where-Object { $_ -notin $csvHeaders }
    $extraHeaders = $csvHeaders | Where-Object { $_ -notin $CorrectHeaders }

    if ($missingHeaders) {
        throw "Missing headers: $($missingHeaders -join ', ')"
    }
    if ($extraHeaders) {
        Write-Warning "Extra headers found: $($extraHeaders -join ', ')"
    }
    if (-not $missingHeaders) {
        Write-Host "All required headers detected"
        return $csvContent
    }
}

$SiteCollections = Get-CSVdata -CorrectHeaders @('Title', 'Url', 'Alias', 'Owner', 'Type', 'Hubsite', 'HubsiteURL', 'Hubsitealias')
