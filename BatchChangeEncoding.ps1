$Utf8BomEncoding = New-Object System.Text.UTF8Encoding($True)
foreach ($i in Get-ChildItem *.cs -Recurse) {
    if ($i.PSIsContainer -or $i.Length -eq 0) {
        continue
    }

    Write-Output $i
    $dest = $i.Fullname.Replace($PWD, "D:\Temp\1")

    if (!(Test-Path $(Split-Path $dest -Parent))) {
        New-Item $(Split-Path $dest -Parent) -type Directory
    }

    $content = get-content $i 
    [System.IO.File]::WriteAllLines($dest, $content, $Utf8BomEncoding)
}