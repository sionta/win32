<#
.SYNOPSIS
    Get Detailed file information.
.DESCRIPTION
    Collects various data for each file, storing information in a hash table
.NOTES
    This function is not supported in Linux or MacOS and only for Windows
.LINK
    https://learn.microsoft.com/en-us/windows/win32/shell/folder-getdetailsof
    https://gist.github.com/woehrl01/5f50cb311f3ec711f6c776b2cb09c34e
.EXAMPLE
    $data = Get-FileMetaData -FilePath "c:\temp\myImage.jpg"
    $dimen = $data.'myImage.png' | Select-Object 'Dimensions'
    Write-Host $dimen.Dimensions
#>

[CmdletBinding()]
[OutputType([hashtable])]
param (
    [Parameter(Mandatory = $true)]
    [string[]]$FilePath
)

$objInfo = [System.Collections.Hashtable]::new()

foreach ($File in $FilePath) {
    if ([System.IO.File]::Exists($File)) {
            # Get detailed of file info
            $fileInfo = [System.IO.FileInfo]::new($File)

        try {
            # Create a Shell.Application COM object
            $objShell = New-Object -ComObject Shell.Application

            # Get the folder where the file is located
            $objFolder = $objShell.NameSpace($fileInfo.DirectoryName)

            # Get the file object from the folder
            $objFolderItem = $objFolder.ParseName($fileInfo.Name)

            # Retrieve and output details of the file without non-ASCII characters
            for ($j = 0; $j -lt 266; $j++) {
                $objName = $objFolder.getDetailsOf($null, $j)
                if (-not [string]::IsNullOrWhiteSpace($objName)) {
                    $objValue = $objFolder.GetDetailsOf($objFolderItem, $j)
                    if (-not [string]::IsNullOrWhiteSpace($objValue)) {
                        $hashName = $fileInfo.BaseName
                        $objValue = [regex]::Replace($objValue, '[^\x00-\x7F]', '')
                        if (-not $objInfo[$hashName]) { $objInfo[$hashName] = @{} }
                        $objInfo[$hashName][$objName] = $objValue
                    }
                }
            }
        } finally {
            if ($objShell) {
                $null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$objShell)
            }
        }
    }
}
return $objInfo