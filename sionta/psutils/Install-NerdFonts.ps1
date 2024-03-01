<#
.SYNOPSIS
Installs Nerd Fonts.
.DESCRIPTION
Installs the fonts provided by https://github.com/ryanoasis/nerd-fonts.
.EXAMPLE
./Install-NerdFonts.ps1 -Name Hack
Install the 'Hack Nerd Font' family.

PS > ./Install-NerdFonts.ps1 Meslo, Iosevka
Install fonts named 'Meslo' and 'Iosevka'.
#>

#Requires -Version 3.0
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Alias('n','Name')]
    [string[]]$FontNames,

    [Alias('l','List')]
    [switch]$ListFonts
)

$FONT_NAMES = @(
    "0xProto",
    "3270",
    "Agave",
    "AnonymousPro",
    "Arimo",
    "AurulentSansMono",
    "BigBlueTerminal",
    "BitstreamVeraSansMono",
    "CascadiaCode",
    "CascadiaMono",
    "CodeNewRoman",
    "ComicShannsMono",
    "CommitMono",
    "Cousine",
    "D2Coding",
    "DaddyTimeMono",
    "DejaVuSansMono",
    "DroidSansMono",
    "EnvyCodeR",
    "FantasqueSansMono",
    "FiraCode",
    "FiraMono",
    "FontPatcher",
    "GeistMono",
    "Go-Mono",
    "Gohu",
    "Hack",
    "Hasklig",
    "HeavyData",
    "Hermit",
    "iA-Writer",
    "IBMPlexMono",
    "Inconsolata",
    "InconsolataGo",
    "InconsolataLGC",
    "IntelOneMono",
    "Iosevka",
    "IosevkaTerm",
    "IosevkaTermSlab",
    "JetBrainsMono",
    "Lekton",
    "LiberationMono",
    "Lilex",
    "MartianMono",
    "Meslo",
    "Monaspace",
    "Monofur",
    "Monoid",
    "Mononoki",
    "MPlus",
    "NerdFontsSymbolsOnly",
    "Noto",
    "OpenDyslexic",
    "Overpass",
    "ProFont",
    "ProggyClean",
    "RobotoMono",
    "ShareTechMono",
    "SourceCodePro",
    "SpaceMono",
    "Terminus",
    "Tinos",
    "Ubuntu",
    "UbuntuMono",
    "VictorMono"
)

if ($ListFonts) { return $FONT_NAMES }

# Check if the specified font names are valid
$invalidFonts = $FontNames | Where-Object { $_ -notin $FONT_NAMES }
if ($invalidFonts) {
    Write-Warning "Invalid font names: $($invalidFonts -join ', '). Please use valid font names."
    Write-Warning "Try using the switch '-ListFonts' to display the list of font names."
    return
}

$userFontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$nerdFontDir = "$PSScriptRoot\nerd-fonts"

$userFontDir, $nerdFontDir | ForEach-Object {
    if (-not (Test-Path $_ -PathType Container)) {
        if ($PSCmdlet.ShouldProcess($_, 'Create Directory')) {
            New-Item -Path $_ -ItemType Directory | Out-Null
        }
    }
}

$fontFiles = @()
foreach ($font_name in $FontNames) {
    $nerdPathName = "$nerdFontDir\$font_name"
    $installFonts = Get-ChildItem -Path $nerdPathName -Filter "*.?tf" -File -ErrorAction SilentlyContinue
    if (-not $installFonts) {
        $zipFilePath = $nerdPathName + '.zip'
        if (-not (Test-Path $zipFilePath)) {
            $latest_releases = Invoke-RestMethod 'https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest'
            $download_url = $latest_releases.assets | Where-Object { $_.name -eq "$font_name.zip" } | Select-Object -ExpandProperty browser_download_url
            if ($null -ne $download_url) {
                if ($PSCmdlet.ShouldProcess($nerdPathName, 'Download font')) {
                    Write-Verbose "Downloading font '$font_name' from $download_url to $zipFilePath"
                    Invoke-WebRequest -Uri $download_url -OutFile $zipFilePath
                }
            } else {
                Write-Warning "Download URL not found for font '$font_name'."
            }
        }
        if (Test-Path $zipFilePath) {
            if ($PSCmdlet.ShouldProcess($nerdPathName, 'Extract font')) {
                Write-Verbose "Extracting font archive to $nerdPathName"
                Expand-Archive -Path $zipFilePath -Destination $nerdPathName -Force
            }
        }
    }
    if ($PSCmdlet.ShouldProcess($nerdPathName, 'Add to $fontFiles')) {
        $fontFiles += $installFonts
    }
}

if ($fontFiles) {
    $shell = New-Object -ComObject Shell.Application
    $fonts = $shell.Namespace(0x14)
    foreach ($font in $fontFiles) {
        $base_name = $font.Name
        $file_name = $font.FullName
        if (-not (Test-Path "$userFontDir\$base_name")) {
            if ($PSCmdlet.ShouldProcess($userFontDir, "Install Font: $base_name")) {
                Write-Verbose "Installing font: $base_name"
                $fonts.CopyHere($file_name)
            }
        } else {
            Write-Warning "Font '$base_name' is already installed."
        }
    }
}
