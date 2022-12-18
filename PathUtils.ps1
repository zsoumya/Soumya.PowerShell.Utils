function Add-EnvPath($newPath) {
    if (-not (Test-Path -Path $newPath -PathType Container)) {
        throw "New path '$newPath' does not exist!"
    }

    $paths = $env:Path.Split(';')

    $exists = $paths | Where-Object -FilterScript { $_ -ieq $newPath }
    if (-not $exists) {
        $paths = ,$newPath + $paths # note the comma, treats $newPath as an array instead of a string
    }

    $path = ($paths | Where-Object -FilterScript { -not [string]::IsNullOrEmpty($_) }) -join ';'
    $env:Path = $path
}

function Get-NormalizedPath($path) {
    return  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}
