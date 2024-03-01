<#
.SYNOPSIS
    Fonts installer for Windows.
.DESCRIPTION
    Install one or more specific font files from a directory.
.EXAMPLE
    .\Install-FontFile.ps1 -Path .\myfonts\ -Recurse
    Install all fonts, including those in the 'myfonts' subdirectory.

    PS > .\Install-FontFile.ps1 -Path .\font-name.ttf
    Install only the specific font file 'font-name.ttf'.
.LINK
    https://github.com/sionta/
#>

#Requires -Version 3.0
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true)]
    [Alias('p')]
    [string[]]$Path,

    [Alias('r')]
    [switch]$Recurse
)

$files = Get-ChildItem -Path $Path -Include '*.ttf', '*.otf' -File -Recurse:$Recurse
# $fonts = (New-Object -ComObject Shell.Application).Namespace('shell:fonts')
$fonts = (New-Object -ComObject Shell.Application).NameSpace(0x14)

$userFontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (-not (Test-Path $userFontDir -PathType Container)) {
    if ($PSCmdlet.ShouldProcess($userFontDir, 'Create Directory')) {
        New-Item $userFontDir -ItemType Directory | Out-Null
    }
}

foreach ($file in $files) {
    $fontBaseName = $file.Name
    $fontFullName = $file.FullName
    $installPath = "$userFontDir\$fontBaseName"
    if (-not (Test-Path $installPath -PathType Leaf)) {
        if ($PSCmdlet.ShouldProcess($installPath, 'Install Font')) {
            $fonts.CopyHere($fontFullName)
            Write-Host "Font '$fontBaseName' installed successfully."
        }
    } else {
        Write-Warning "The '$fontBaseName' font is already installed."
    }
}

exit $LASTEXITCODE
