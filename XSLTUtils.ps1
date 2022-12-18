using namespace System.IO
using namespace System.Xml

. $PSScriptRoot\DotNetUtils.ps1

function Invoke-XSLTransform {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory)]
        [FileInfo] 
        $inputXmlFile,
        
        [Alias('x')]
        [Parameter(Mandatory)]
        [FileInfo]
        $xsltFile,
        
        [Alias('o')]
        [Parameter(Mandatory)]
        [FileInfo] 
        $outputXmlFile
    )
    
    $inputXmlFile = [FileInfo] (Get-NormalizedPath -path $inputXmlFile)
    if (-not $inputXmlFile.Exists) {
        throw "Input XML file '$inputXmlFile' does not exist!"
    }

    $xsltFile = [FileInfo] (Get-NormalizedPath -path $xsltFile)
    if (-not $xsltFile.Exists) {
        throw "XSLT file '$xsltFile' does not exist!"
    }

    $outputXmlFile = [FileInfo] (Get-NormalizedPath -path $outputXmlFile)

    $xsltSettings = [Xsl.XsltSettings]::new()
    $xsltSettings.EnableScript = $true
    
    $xslCompiledTransform = [Xsl.XslCompiledTransform]::new()
    $xslCompiledTransform.Load($xsltFile, [Xsl.XsltSettings]::TrustedXslt, $null)
    Write-Verbose -Message 'Loaded XSLT'
    
    $document = [XPath.XPathDocument]::new($inputXmlFile)
    Write-Verbose -Message 'Loaded input XML'
    
    $settings = [XmlWriterSettings]::new()
    $settings.Indent = $true
    $settings.OmitXmlDeclaration = $true
    
    Use-Object -inputObject ($writer = [XmlWriter]::Create($outputXmlFile, $settings)) -scriptBlock {
        Write-Verbose -Message 'Transforming input XML'
        $xslCompiledTransform.Transform($document, $writer)
        $writer.Close()
        Write-Verbose -Message 'Created output XML'
    }    
}
