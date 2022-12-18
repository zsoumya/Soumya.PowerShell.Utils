function Convert-CertFileToBinFile($certFile, $binFile) {
    & certutil -f -v -decode $certFile $binFile
}

function Convert-BinFileToCertFile($binFile, $certFile) {
    & certutil -f -v -encode $binFile $certFile
}

function Convert-BinFileToBase64File($binFile, $textFile) {
    $binFile = Get-NormalizedPath -path $binFile
    $textFile = Get-NormalizedPath -path $textFile

    $bytes = [System.IO.File]::ReadAllBytes($binFile)
    $text = [System.Convert]::ToBase64String($bytes)

    [System.IO.File]::WriteAllText($textFile, $text)    
}

function Convert-Base64FileToBinFile($textFile, $binFile) {
    $binFile = Get-NormalizedPath -path $binFile
    $textFile = Get-NormalizedPath -path $textFile

    $text = [System.IO.File]::ReadAllText($textFile)
    $bytes = [System.Convert]::FromBase64String($text)

    [System.IO.File]::WriteAllBytes($binFile, $bytes)    
}

function Convert-BinFileToBase85File($binFile, $textFile) {
    $binFile = Get-NormalizedPath -path $binFile
    $textFile = Get-NormalizedPath -path $textFile

    $csFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'ASCII85.cs'
    Add-Type -Path $csFilePath

    [BaseN.ASCII85]::EncodeFile($binFile, $textFile)
}

function Convert-Base85FileToBinFile($textFile, $binFile) {
    $binFile = Get-NormalizedPath -path $binFile
    $textFile = Get-NormalizedPath -path $textFile

    $csFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'ASCII85.cs'
    Add-Type -Path $csFilePath

    [BaseN.ASCII85]::DecodeFile($textFile, $binFile) 
}