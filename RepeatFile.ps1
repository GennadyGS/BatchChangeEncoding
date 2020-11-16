Param (
    $inputFile,
    $repeatCount = 2
)

$outputFileName = (Join-Path (Get-Item $inputFile).DirectoryName (Get-Item $inputFile).Basename) + 
    "_x$repeatCount" + [IO.Path]::GetExtension($inputFile);

if (Test-Path $outputFileName) { Remove-Item $outputFileName }

$content = Get-Content $inputFile
For ($i=0; $i -lt $repeatCount; $i++) {
    $i
    $content | Out-File $outputFileName -Append -Encoding "UTF8"
}