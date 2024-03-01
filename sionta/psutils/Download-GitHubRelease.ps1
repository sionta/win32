<#
.SYNOPSIS
Download files from the latest release of a GitHub repository.

.DESCRIPTION
This script downloads files from the latest release of a GitHub repository. It allows you to specify the repository URL, filter assets by name pattern, provide a specific tag for the release, and force the download even if files already exist.

.PARAMETER Url
GitHub repository URL in the format 'owner/name'.

.PARAMETER Tag
A specific tag to fetch the release.

.PARAMETER Pattern
A pattern to filter assets by name.

.PARAMETER Force
Force the download, even if files already exist.

.EXAMPLE
# Download all assets from the latest release of the 'dracula/mixplorer' repository.
./Download-GitHubRelease.ps1 -Url 'dracula/mixplorer' -Force

.EXAMPLE
# Download assets matching the pattern 'dracula-pink.mit' from the latest release of the 'dracula/mixplorer' repository.
./Download-GitHubRelease.ps1 -Url 'dracula/mixplorer' -Pattern 'dracula-pink.mit' -Force

.EXAMPLE
# Download the latest release assets with a specific tag 'v1.0.0' from the 'dracula/mixplorer' repository.
./Download-GitHubRelease.ps1 -Url 'dracula/mixplorer' -Tag 'v1.0.0' -Force

.LINK
GitHub REST API Documentation - Repositories
https://docs.github.com/en/rest/reference/repos#get-a-repository
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [string]$Tag,
    [string]$Pattern,
    [switch]$Force
)

# Extract owner and repository names from the URL
$ownerRepo = $Url -replace '\\', '/' -split '/' | Where-Object { $_ -ne '' }

# Check if the URL is in the correct format (owner/repo)
if ($ownerRepo.Count -ne 2) {
    Write-Host "Invalid URL format. Please use the format 'owner/repo'."
    return
}

# Construct the 'owner/repo' format
$ownerRepo = $ownerRepo[0] + "/" + $ownerRepo[1]

# Modify API URL based on whether a tag is specified
if ($Tag) {
    $apiUrl = "https://api.github.com/repos/$ownerRepo/releases/tags/$Tag"
} else {
    $apiUrl = "https://api.github.com/repos/$ownerRepo/releases/latest"
}

# Get information about the release from the GitHub API
try {
    $release = Invoke-RestMethod -Uri $apiUrl -Method Get
} catch {
    Write-Host "Error retrieving release information. $_"
    return
}

# Get download URLs for each asset in the release
$assets = $release.assets

if ($assets.Count -eq 0) {
    Write-Host "No assets found in the latest release."
    return
}

Write-Host "Latest release from $ownerRepo`: $($release.name)"

# Display the list of assets in the release
Write-Host "`nAssets in the release:"
$assets | ForEach-Object { Write-Host "- $($_.name)" }

# Check if there is more than one file in the release
if ($assets.Count -gt 1) {
    # If the user specifies a pattern, use it
    if ($Pattern) {
        $filteredAssets = $assets | Where-Object { $_.name -like "*$Pattern*" }
        if ($filteredAssets.Count -gt 0) {
            $assets = $filteredAssets
        } else {
            Write-Host "No assets with the pattern '$Pattern' in the name."
            return
        }
    } elseif (-not $Force) {
        # If not, ask the user if they want to download all assets
        $downloadAll = Read-Host "Do you want to download all assets? (y/n)"
        if ($downloadAll.ToLower() -ne 'y') {
            Write-Host "Download canceled."
            return
        }
    }
}

# Download each asset
foreach ($asset in $assets) {
    $downloadUrl = $asset.browser_download_url
    $fileName = $asset.name

    # Full path for the output file
    $fullPath = Join-Path -Path $Pwd -ChildPath $fileName

    # Check if the file exists
    if (-not $Force -and (Test-Path -Path $fullPath -PathType Leaf)) {
        Write-Host "File $fileName already exists. Skipping download."
        continue
    }

    Write-Host "Downloading: $fileName"

    try {
        # Download with a progress bar
        $response = Invoke-WebRequest -Uri $downloadUrl -OutFile $fullPath -PassThru -ErrorAction Stop

        if ($response.ContentLength -gt 0) {
            $progressParams = @{
                PercentComplete = ($response.RawContentLength / $response.ContentLength) * 100
                Status          = "Downloading $fileName"
                Activity        = "Downloading"
            }
            Write-Progress @progressParams
        }

        Write-Host "$fileName successfully downloaded."
    } catch {
        Write-Host "Error downloading $fileName`: $_"
    }
}
