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
        LogProcessedLines $lineIndex
        $line = $reader.ReadLine()
        $randomIndex = $random.Next($lineIndex + 1)
        if ($randomIndex -lt $sampleLineCount) {
            $replacedIndex = $lineIndex -lt $sampleLineCount ? $lineIndex : $randomIndex
            $result[$replacedIndex] = @{ Index = $lineIndex; Line = $line }
        }
        $lineIndex++
    }
    Write-Host "Reading file complete: $lineIndex lines"
    $resultLength = [Math]::Min($sampleLineCount, $lineIndex)
    $trimmedResult = $result[0 .. ($resultLength - 1)]
    $sortedResult = [System.Linq.Enumerable]::OrderBy(
        $trimmedResult, [Func[object, object]]{ param($x) $x.Index })
    return [System.Linq.Enumerable]::Select(
        $sortedResult, [Func[object, object]]{ param($x) $x.Line })
}

Function LogProcessedLines($lineCount) {
    if (($lineCount -gt 0) -and ($lineCount % 100000 -eq 0)) {
        Write-Host "Processed $lineIndex lines"
    }
}

Write-Host "Reading input file $inputFilePath..."
$sampleLines = Get-SampleLinesFromFile $inputFilePath $sampleLineCount $preserveFirstLine
$outputFilePath ??= Add-SuffixToFileName $inputFilePath "_sample"
Write-Host "Writing result to output file $outputFilePath..."
[IO.File]::WriteAllLines($outputFilePath, $sampleLines)
Write-Host "Output file with $($sampleLines.Count) lines is successfully created"
