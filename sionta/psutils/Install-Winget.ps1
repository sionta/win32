if ($PSVersionTable.PSVersion.Major -ge 6) {
    if (-not(Get-Module -Name 'Appx')) {
        Import-Module Appx -UseWindowsPowerShell -Force
    }
}

try {
    if (-not(Get-AppxPackage 'Microsoft.VCLibs.140.00')) {
        $VCLibsURL = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
        $FileAppx = "$env:USERPROFILE\Downloads\" + $VCLibsURL.Split('/')[-1]
        if (-not(Test-Path $FileAppx)) { Invoke-WebRequest -Uri "$VCLibsURL" -OutFile "$FileAppx" -UseBasicParsing }
        Add-AppxPackage $FileAppx
    }
    if (-not(Get-AppxPackage 'Microsoft.DesktopAppInstaller')) {
        $WingetURL = Invoke-RestMethod 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
        $WingetURL = $WingetURL.assets.browser_download_url.Where({ $_.EndsWith('.msixbundle') })
        $FileMsix = "$env:USERPROFILE\Downloads\" + $WingetURL.Split('/')[-1]
        if (-not(Test-Path $FileMsix)) { Invoke-WebRequest -Uri "$WingetURL" -OutFile "$FileMsix" -UseBasicParsing }
        Add-AppxPackage $FileMsix
    }
    'Windows Package Manager: ' + $(& winget --version) + '. For more details run: winget.exe --help'
}
catch {
    throw
}
