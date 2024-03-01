if ($PSVersionTable.PSVersion.Major -ge 6) {
    if (-not(Get-Module -Name 'Appx')) {
        Import-Module Appx -UseWindowsPowerShell -Force
    }
}

$packages = @{
    'VCLibs'   = 'Microsoft.VCLibs.140.00';
    'Terminal' = 'Microsoft.WindowsTerminal'
}

if (-not(Get-AppxPackage -Name $packages.VCLibs)) {
    [string]$VCLibsURL = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
    [string]$FileAppx = "$env:USERPROFILE\Downloads\" + $VCLibsURL.Split('/')[-1]
    if (-not(Test-Path "$FileAppx" -PathType Leaf)) {
        Invoke-WebRequest -Uri "$VCLibsURL" -OutFile "$FileAppx" -UseBasicParsing
    }
    if (Test-Path "$FileAppx" -PathType Leaf) { Add-AppxPackage "$FileAppx" }
}

if (-not(Get-AppxPackage -Name $packages.Terminal)) {
    $TerminalURL = Invoke-RestMethod 'https://api.github.com/repos/microsoft/terminal/releases/latest'
    [string]$TerminalURL = $TerminalURL.assets.browser_download_url.Where({ $_.EndsWith('.msixbundle') })
    [string]$FileMsix = "$env:USERPROFILE\Downloads\" + $TerminalURL.Split('/')[-1]
    if (-not(Test-Path "$FileMsix" -PathType Leaf)) {
        Invoke-WebRequest -Uri "$TerminalURL" -OutFile "$FileMsix" -UseBasicParsing
    }
    if (Test-Path "$FileMsix" -PathType Leaf) { Add-AppxPackage "$FileMsix" }
}
