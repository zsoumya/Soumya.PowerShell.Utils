# Quick & dirty PowerShell script to report the record count of each file in the folder

function Get-LineCount {
	[CmdletBinding()]
	param (
        [Parameter(Mandatory)]
		[string]
        $path,

        [Parameter()]
		[string]
        $pattern = '*.txt'      
	)
	PROCESS
	{
        if (-not (Test-Path -Path $path -PathType Container)) {
            throw "Invalid path: $path"
        }
		
		if ([string]::IsNullOrWhiteSpace($path)) {
			$path = "."
		}
		
		if ([string]::IsNullOrWhiteSpace($pattern)) {
			$pattern = "*.txt"
		}
		
		Get-ChildItem -Path $path -Filter $pattern -Recurse | ForEach-Object -Process { 
			$_ | Select-Object -Property `
				@{ Name = 'Path'; Expression = { $_.Directory } }, `
				Name, `
				@{ Name = "Count"; Expression = { (Get-Content -Path $_.FullName | Measure-Object -Line | Select-Object -ExpandProperty Lines) - 1 } }
		}
	}
}