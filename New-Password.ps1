function New-Password {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateRange(12,256)] # Default minimum and maximum length in AzureAD 
        [int]$length,

        [Parameter(Mandatory = $false)]
        [bool]$includeUppercase = $true,

        [Parameter(Mandatory = $false)]
        [bool]$includeLowercase = $true,

        [Parameter(Mandatory = $false)]
        [bool]$includeNumbers = $true,

        [Parameter(Mandatory = $false)]
        [bool]$includeSymbols = $true
    )

    # Set up the character types to include in the password
    $charTypes = @()
    if ($includeUppercase) { $charTypes += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' }
    if ($includeLowercase) { $charTypes += 'abcdefghijklmnopqrstuvwxyz' }
    if ($includeNumbers) { $charTypes += '0123456789' }
    if ($includeSymbols) { $charTypes += '!@#$%^&*(){}[]=<>.' }

    # If no character types are selected, throw an error
    if ($charTypes.Count -eq 0) { throw 'Set at least one of the parameters to true.' }

    # Generate the password by selecting a random character from each character type
    $password = ''
    for ($i = 0; $i -lt $length; $i++) {
        $charType = $charTypes[(Get-Random -Minimum 0 -Maximum $charTypes.Count)]
        $password += $charType[(Get-Random -Minimum 0 -Maximum $charType.Length)]
    }

    # Check that the password includes at least one character from each specified character type
    $missingCharTypes = @()
    if ($includeUppercase -and ($password -notmatch '\p{Lu}')) { $missingCharTypes += 'uppercase' }
    if ($includeLowercase -and ($password -notmatch '\p{Ll}')) { $missingCharTypes += 'lowercase' }
    if ($includeNumbers -and ($password -notmatch '\p{Nd}')) { $missingCharTypes += 'numbers' }
    if ($includeSymbols -and ($password -notmatch '[`!@#$%^&*()_+\-=\[\]{}\\|.<>\/?~]')) { $missingCharTypes += 'symbols' }

    # If any character types are missing, regenerate the password
    if ($missingCharTypes.Count -gt 0) {
        # Because we are nesting another call of this function in here it will essentially loop until a password is generated that has all CharTypes
        Write-Verbose "The generated password does not include any of the following character types: $($missingCharTypes -join ', '). Regenerating password..."
        $password = New-Password -length $length -includeUppercase $includeUppercase -includeLowercase $includeLowercase -includeNumbers $includeNumbers -includeSymbols $includeSymbols
    }

    return $password
}
