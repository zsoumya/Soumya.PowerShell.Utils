function Use-Object
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Object]
        $inputObject,

        [Parameter(Mandatory = $true)]
        [scriptblock]
        $scriptBlock
    )

    try
    {
        . $scriptBlock
    }
    finally
    {
        if (($null -ne $inputObject) -and ($inputObject -is [IDisposable]))
        {
            $inputObject.Dispose()
        }
    }
}
