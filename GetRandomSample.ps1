param (
    [Alias("i")] [Parameter(mandatory = $true)] $inputFilePath,
    [Alias("c")] $sampleLineCount = 1,
    [Alias("o")] $outputFilePath,
    [Alias("p")] [switch] $preserveFirstLine
)

Function Add-SuffixToFileName($filePath, $suffix) {
    [IO.Path]::ChangeExtension($filePath, "").TrimEnd(".") + `
    $suffix + `
    [IO.Path]::GetExtension($filePath)
}

Function Get-SampleLinesFromFile($inputFilePath, $sampleLineCount, $preserveFirstLine) {
    $reader = [IO.File]::OpenText($inputFilePath)
    try {
        if ($preserveFirstLine) {
            $preservedFirstLine = $reader.ReadLine()
        }
        $sampleLines = Get-RandomSampleFromReader $reader $sampleLineCount
        return $preserveFirstLine `
            ? ,$preservedFirstLine + $sampleLines
            : $sampleLines
    }
    finally {
        $reader.Dispose();
    }
}

Function Get-RandomSampleFromReader($reader, $sampleLineCount) {
    $random = New-Object Random
    $result = [PSCustomObject[]]::new($sampleLineCount)
    $lineIndex = 0
    while (!$reader.EndOfStream) {
        $line = $reader.ReadLine()
        $randomIndex = $random.Next($lineIndex + 1)
        if ($randomIndex -lt $sampleLineCount) {
            $replacedIndex = $lineIndex -lt $sampleLineCount ? $lineIndex : $randomIndex
            $result[$replacedIndex] = @{ Index = $lineIndex; Line = $line }
        }
        $lineIndex++
        if ($lineIndex % 100000 -eq 0) {
            Write-Host "Processed $lineIndex lines"
        }
    }
    $resultLength = [Math]::Min($sampleLineCount, $lineIndex)
    return $result[0 .. ($resultLength - 1)]
        | Sort-Object -Property Index
        | Select-Object -ExpandProperty Line
}

$sampleLines = Get-SampleLinesFromFile $inputFilePath $sampleLineCount $preserveFirstLine
$outputFilePath ??= Add-SuffixToFileName $inputFilePath "_sample"
Write-Host "Writing result to output file $outputFilePath..."
[IO.File]::WriteAllLines($outputFilePath, $sampleLines)
Write-Host "Sample file with $($sampleLines.Count) lines is successfully created"
