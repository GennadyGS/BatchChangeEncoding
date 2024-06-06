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

Function Get-TotalLineCount($filePath) {
    $reader = [IO.File]::OpenText($inputFilePath)
    try {
        $result = 0;
        while (!$reader.EndOfStream) {
            $reader.ReadLine() | Out-Null
            $result++;
            if ($result % 100000 -eq 0) { Write-Host "Counting line $result" }
        }
    }

    finally {
        $reader.Dispose();
    }
    return $result
}

$outputFilePath ??= Add-SuffixToFileName $inputFilePath "_sample"

Write-Host "Counting number of lines..."
$totalLineCount = Get-TotalLineCount $inputFilePath
Write-Host "Total number of lines: $totalLineCount"

If ($totalLineCount -eq 0) {
    throw "Cannot create sample from empty file"
}
Write-Host "Reading the file..."
$reader = [IO.File]::OpenText($inputFilePath)
try {
    $writer = [IO.File]::CreateText($outputFilePath)
    try {
        $lineNumber = 0
        $lineCountToSelect = $sampleLineCount + ($preserveFirstLine ? 1 : 0)
        $random = New-Object Random
        while (!$reader.EndOfStream -and $lineCountToSelect -gt 0) {
            $line = $reader.ReadLine()
            $lineCountToRead = $totalLineCount - $lineNumber
            $selectionProbability = [Math]::Min($lineCountToSelect / $lineCountToRead, 1.0)
            If ($preserveFirstLine -and $lineNumber -eq 0 `
                    -or $random.NextSingle() -le $selectionProbability) {
                $writer.WriteLine($line)
                $lineCountToSelect--
            }
            $lineNumber++
            if ($lineNumber % 100000 -eq 0) { Write-Host "Processing line $lineNumber" }
        }
    }
    finally {
        $writer.Dispose();
    }
}
finally {
    $reader.Dispose();
}
Write-Host "Samle file with $sampleLineCount lines is successfully created"
