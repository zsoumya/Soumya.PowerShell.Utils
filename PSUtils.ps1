function Clear-PSHistory {
    # Debugging: For testing you can simulate not having PSReadline loaded with
    # Remove-Module PSReadline -Force
    $psReadlineInstalled = ($null -ne (Get-Module -Name PSReadLine -ErrorAction SilentlyContinue))

    if ($psReadlineInstalled) {
        $historyPath = (Get-PSReadlineOption).HistorySavePath

        # Remove PSReadline's saved-history file.
        if (Test-Path -Path $historyPath) { 
            # Abort, if the file for some reason cannot be removed.
            Remove-Item -Path $historyPath -ErrorAction Stop 
            # To be safe, we recreate the file (empty). 
            New-Item -Type File -Path $historyPath -Force | Out-Null
        }

        # Clear PSReadline's *session* history.
        # General caveat (doesn't apply here, because we're removing the saved-history file):
        # * By default (-HistorySaveStyle SaveIncrementally), if you use
        # [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory(), any sensitive
        # commands *have already been saved to the history*, so they'll *reappear in the next session*. 
        # * Placing `Set-PSReadlineOption -HistorySaveStyle SaveAtExit` in your profile 
        # SHOULD help that, but as of PSReadline v1.2, this option is BROKEN (saves nothing). 
        [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()

    }
    else {
        # Clear the doskey library's buffer, used pre-PSReadline. 
        # !! Unfortunately, this requires sending key combination Alt+F7.
        # Thanks, https://stackoverflow.com/a/13257933/45375
        [System.Reflection.Assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
        [System.Windows.Forms.SendKeys]::Sendwait('%{F7 2}')
    }

    # Clear PowerShell's own history 
    Clear-History
}