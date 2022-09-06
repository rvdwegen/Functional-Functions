Function Test-CSVHeaders {
	# Adapted from https://github.com/nickrod518/PowerShell-Scripts/blob/master/Validate-CSVHeaders.ps1
    [CmdletBinding()]
    param(
		[ValidateScript({
			if(-Not ($_ | Test-Path) ){
				throw "File or folder does not exist."
			}
			if(-Not ($_ | Test-Path -PathType Leaf) ){
				throw "The Path argument must be a file. Folder paths are not allowed."
			}
			if($_ -notmatch "(\.csv)"){ # "(\.csv|\.exe)"
				throw "The file specified in the path argument must be of type CSV."
			}
			return $true 
		})]
		[System.IO.FileInfo]$Path,

		[Parameter(Mandatory=$true)]
        [Array]$correctHeaders
	)

	# Get headers from $path CSV file
	$headers = Get-Content $Path -TotalCount 1

	# Determine delimiter from $headers
	If ($headers.Split(";").Length -gt 1) {
		Set-Variable -Name 'delimiter' -Value ";"
	} Elseif ($headers.Split(",").Length -gt 1) {
		Set-Variable -Name 'delimiter' -Value ","
	} Else {
		Throw "Could not detect delimiter or invalid delimiter used. Please use , or ;"
	}

	# put all the headers into a comma separated array
	$headers = $headers.Split($delimiter)

	# Initialize header check error array
	$headerErrorArray = @()

	for ($i = 0; $i -lt $headers.Count; $i++) {
	
		# trim any leading white space and compare the headers
		if ($headers[$i].TrimStart() -ne $correctHeaders[$i]) {
			$headerErrorArray += ("CSV header " + $headers[$i] + " does not match correct header " + $correctHeaders[$i])
		}
	}

	# Check for reported errors in $headerErrorArray, if none are found return $true
	If ($headerErrorArray) {
		ForEach ($headererror in $headerErrorArray) {
			Write-Host $headererror -ForegroundColor Red
		}
		throw "Incorrect headers found."
	}
	Else {
		return $true
	}
}

$CSVpath = ".\knzbvoorbeeld.csv"

$correctHeaders = @(
	'UserPrincipalName', 'Password', 'FirstName', 'LastName', 'JobTitle'
	)

Test-CSVHeaders -Path $CSVpath -correctHeaders $correctHeaders
