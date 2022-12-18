function Get-InstalledFontList {
    $fontsLMRegistryKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts')
    $fontsCURegistryKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts')
    
    $fontsLMRegistryKey.GetValueNames() | ForEach-Object -Process {
        $fontFile = "C:\Windows\Fonts\$($fontsLMRegistryKey.GetValue($_))"
        Write-Output -InputObject "$_ -> $fontFile"
    }
    
    $fontsCURegistryKey.GetValueNames() | ForEach-Object -Process {
        $fontFile = $fontsCURegistryKey.GetValue($_)
        Write-Output -InputObject "$_ -> $fontFile"
    }
}

function Get-InstalledSoftwareList {
    Get-CimInstance Win32_Product | Sort-Object -property Name | Format-Table -Property Name, Version, InstallDate, InstallLocation
}

function Remove-DesktopShortcuts {
    $desktopShortcuts = @(
        (Join-Path -Path ([Environment]::GetFolderPath("CommonDesktopDirectory")) -ChildPath '*.lnk'), 
        (Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath '*.lnk')
    )
    
    $desktopShortcuts | ForEach-Object -Process {
        Write-Verbose -Message "Removing $_..."
        Remove-Item -Path $_ -Force
    }    
}

class AppAlias {
    static [string] $appAliasesRegPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\'

    [string] $ExePath
    [string] $Name

    AppAlias([string] $name, [string] $exePath) {
        if (-not (Test-Path -Path $exePath -PathType Leaf)) {
            throw "Invalid file: $exePath"
        }

        $this.ExePath = $exePath
        $this.Name = $name
    }

    [string] ToString() {
        return "$($this.Name) => $($this.ExePath)"
    }

    [string] GetAppAliasRegsitryPath() {
        return Join-Path -Path $([AppAlias]::appAliasesRegPath) -ChildPath "$($this.Name).exe"
    }

    [bool] Exists() {
        $registryPath = $this.GetAppAliasRegsitryPath()
        return Test-Path -Path $registryPath -PathType Container
    }

    [void] Set() {
        if (!($this.Exists())) {
            New-Item -Path $([AppAlias]::appAliasesRegPath) -Name "$($this.Name).exe"
        }

        Set-Item -Path $($this.GetAppAliasRegsitryPath()) -Value $this.ExePath # Set 'Default' value
    }
}

function Set-AppAlias($name, $exePath) {
    $appAlias = [AppAlias]::new($name, $exePath)
    $appAlias.Set()
}

function Test-IsAdmin {
    [CmdletBinding()]
    [OutputType([Boolean])]
    Param()

    if ($PSVersionTable.Platform -eq 'Unix') {
        return (whoami) -eq 'root'
    }

    $user = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if ($user.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $true
    }

    return $false
}

function Restart-Explorer {
    [CmdletBinding()]
    param(
        [switch] $force
    )

    Write-Verbose -Message 'Attempting to stop ''explorer.exe'''
    Stop-Process -Name 'explorer' -Force -ErrorAction SilentlyContinue

    if ($force) {
        Write-Verbose -Message 'Waiting for 1 second'
        Start-Sleep -Seconds 1

        Write-Verbose -Message 'Attempting to start ''explorer.exe'''
        Start-Process -FilePath 'explorer.exe'
    }
}

function Set-ExtraLargeBlackCursor {
    [CmdletBinding()]
    param()

    $cursorRegPath = 'HKCU:\Control Panel\Cursors'

    Set-Item -Path $cursorRegPath -Value 'Windows Black (extra large)'
    Set-ItemProperty -Path $cursorRegPath -Name 'AppStarting' -Value '%SystemRoot%\cursors\wait_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'Arrow' -Value '%SystemRoot%\cursors\arrow_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'ContactVisualization' -Value '1' -Type DWord
    Set-ItemProperty -Path $cursorRegPath -Name 'Crosshair' -Value '%SystemRoot%\cursors\cross_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'CursorBaseSize' -Value '32' -Type DWord
    Set-ItemProperty -Path $cursorRegPath -Name 'GestureVisualization' -Value '31' -Type DWord
    Set-ItemProperty -Path $cursorRegPath -Name 'Hand' -Value '' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'Help' -Value '%SystemRoot%\cursors\help_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'IBeam' -Value '%SystemRoot%\cursors\beam_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'No' -Value '%SystemRoot%\cursors\no_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'NWPen' -Value '%SystemRoot%\cursors\pen_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'Person' -Value '%SystemRoot%\cursors\person_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'Pin' -Value '%SystemRoot%\cursors\pin_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'Scheme Source' -Value '2' -Type DWord
    Set-ItemProperty -Path $cursorRegPath -Name 'SizeAll' -Value '%SystemRoot%\cursors\move_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'SizeNESW' -Value '%SystemRoot%\cursors\size1_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'SizeNS' -Value '%SystemRoot%\cursors\size4_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'SizeNWSE' -Value '%SystemRoot%\cursors\size2_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'SizeWE' -Value '%SystemRoot%\cursors\size3_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'UpArrow' -Value '%SystemRoot%\cursors\up_rl.cur' -Type ExpandString
    Set-ItemProperty -Path $cursorRegPath -Name 'Wait' -Value '%SystemRoot%\cursors\busy_rl.cur' -Type ExpandString

    $csharpSig = @'
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
    uint uiAction,
    uint uiParam,
    uint pvParam,
    uint fWinIni);
'@

    $cursorRefresh = Add-Type -MemberDefinition $csharpSig -Name WinAPICall -Namespace SystemParamInfo -PassThru
    $cursorRefresh::SystemParametersInfo(0x0057, 0, $null, 0) | Out-Null
}