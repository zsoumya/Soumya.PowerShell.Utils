function Export-StylusStudioSettings {
    # Exports Stylus Studio settings registry key to
    # a registry export file (plain text) so that bulk
    # changes can be made to Stylus Studio settings by
    # modifying this registry file and re-importing it
    # to registry.

    [CmdletBinding()]
    param (
        [Alias('o')]
        [Parameter(Mandatory)]
        [string]
        $outFile
    )

    $outFile = Get-NormalizedPath -path $outFile
    $regPath = 'HKCU\SOFTWARE\Stylus Studio\X16 XML Enterprise Suite 64-bit\Plugin Settings'

    Write-Verbose -Message "Exporting registry '$regPath' to $outFile"
    & reg export $regPath $outFile
}

function Restore-BeyondCompare {
    & reg delete 'HKCU\Software\Scooter Software\Beyond Compare 4' /v CacheID /f
}
