function Get-FileFromUrl {
    param(
        [Parameter(Mandatory=$true)]
        [uri]$URL
    )
    
    Try {
        $BitsParams = @{
            Source = $URL
            Destination = ($env:TEMP + "\" + ([uri]$url).Segments[-1])
            DisplayName = "File download in progress..."
            Description = "   "
        }
    
        Start-BitsTransfer @BitsParams -ErrorAction Stop
    
        return $BitsParams["Destination"]
    }
    Catch {
        throw $_.Exception
    }
}
