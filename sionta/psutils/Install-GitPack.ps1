<#
.SYNOPSIS
Install Git, and GitHub CLI (gh-cli) on a Windows system.

.DESCRIPTION
This script dynamically fetches the latest release version and download URLs for Git and GitHub CLI (gh-cli) from GitHub API, then installs them on a Windows system.

.EXAMPLE
.\Install-GitPack.ps1
#>

# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an administrator." -ForegroundColor Red
    exit $LASTEXITCODE
}

function Test-GitInstalled {
    return $null -ne (Get-Command git -ErrorAction SilentlyContinue)
}

function Test-GitHubCLIInstalled {
    return $null -ne (Get-Command gh -ErrorAction SilentlyContinue)
}

function Test-GitHubDesktopInstalled {
    return (Test-Path "$env:LOCALAPPDATA\GitHubDesktop\GitHubDesktop.exe" -PathType Leaf)
}

function Get-LatestReleaseInfo {
    param (
        [string]$Repo
    )
    $apiUrl = "https://api.github.com/repos/$Repo/releases/latest"
    $release = Invoke-RestMethod -Uri $apiUrl -Method Get
    return $release
}

function Install-Git {
    if (Test-GitInstalled) {
        Write-Host "Git for Windows is already installed."
        return
    }
    $gitRepo = "git-for-windows/git"
    $latestRelease = Get-LatestReleaseInfo -Repo $gitRepo
    $bitVersion = if ([System.Environment]::Is64BitOperatingSystem) { "64-bit" } else { "32-bit" }
    $gitInstallerUrl = $latestRelease.assets | Where-Object { $_.name -like "*$bitVersion.exe" } | Select-Object -ExpandProperty browser_download_url
    $gitInstallerPath = "$env:TEMP\GitInstaller.exe"
    Invoke-WebRequest -Uri $gitInstallerUrl -OutFile $gitInstallerPath
    Start-Process -FilePath $gitInstallerPath -ArgumentList "/SILENT" -Wait
    Remove-Item -Path $gitInstallerPath -Force
    Write-Host "Git for Windows installed successfully."
}

function Install-GitHubCLI {
    if (Test-GitHubCLIInstalled) {
        Write-Host "GitHub CLI (gh-cli) is already installed."
        return
    }
    $ghCliRepo = "cli/cli"
    $latestRelease = Get-LatestReleaseInfo -Repo $ghCliRepo
    $ghCliUrl = $latestRelease.assets | Where-Object { $_.name -like "*windows_amd64.zip" } | Select-Object -ExpandProperty browser_download_url
    $ghCliZipPath = "$env:TEMP\gh-cli.zip"
    $ghCliExtractPath = "$env:TEMP\gh-cli"
    Invoke-WebRequest -Uri $ghCliUrl -OutFile $ghCliZipPath
    Expand-Archive -Path $ghCliZipPath -DestinationPath $ghCliExtractPath -Force
    Write-Host "Contents of $ghCliExtractPath`:"
    Get-ChildItem -Path $ghCliExtractPath
    $ghExePath = Get-ChildItem -Path $ghCliExtractPath -Include 'gh.exe' -File -Recurse
    Write-Host "Path of gh.exe: $ghExePath"
    Move-Item -Path $ghExePath -Destination (Join-Path $env:SystemRoot "System32") -Force
    Remove-Item -Path $ghCliZipPath -Force
    Remove-Item -Path $ghCliExtractPath -Recurse -Force
    Write-Host "GitHub CLI (gh-cli) installed successfully."
}

Install-Git
Install-GitHubCLI
