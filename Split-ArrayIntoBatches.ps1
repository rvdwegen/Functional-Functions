function Split-ArrayIntoBatches {
    param(
        [Parameter(Mandatory=$true)]
        [array]$InputArray,
        [int]$ChunkSize = 20
    )

    $batchArrays = [System.Collections.Generic.List[object]]::new()
    $totalCount = $InputArray.Count
    $arrayCount = [Math]::Ceiling($totalCount / $ChunkSize)

    for ($i = 0; $i -lt $arrayCount; $i++) {
        $start = $i * $ChunkSize
        $end = [Math]::Min(($i + 1) * $ChunkSize - 1, $totalCount - 1)
        
        $guid = [guid]::NewGuid().ToString()
        $batch = @($InputArray[$start..$end])
        
        $batchArrays.Add([PSCustomObject]@{
            Id = $guid
            Values = $batch
        })
    }

    return $batchArrays
}

$userBatches = Split-ArrayIntoBatches -InputArray $UPNs -ChunkSize 20
