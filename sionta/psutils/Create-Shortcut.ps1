<#
.SYNOPSIS
Create a shortcut with specified properties.

.DESCRIPTION
This script creates a shortcut with customizable properties, including the shortcut's name, target path, command-line arguments, icon path, start in directory, window style, hotkey, description, and whether to run the shortcut with elevated privileges.

.PARAMETER Name
The name of the shortcut (without the .lnk extension).

.PARAMETER Value
The target path of the shortcut.

.PARAMETER Arguments
Command-line arguments for the shortcut.

.PARAMETER Icon
The path to the icon file for the shortcut. It can be an ICO, EXE, or DLL file.

.PARAMETER Index
The icon index within the icon file.

.PARAMETER Directory
The start-in directory for the shortcut.

.PARAMETER Window
The window style for the shortcut (Normal, Minimized, Maximized).

.PARAMETER Hotkey
The hotkey for the shortcut.

.PARAMETER Description
The description for the shortcut.

.PARAMETER Elevated
Indicates whether the shortcut should be run with elevated privileges.

.EXAMPLE
# Create a shortcut named "MyApp" to "C:\Path\To\MyApp.exe" with elevated privileges.
.\Create-Shortcut.ps1 -Name "MyApp" -Value "C:\Path\To\MyApp.exe" -Elevated

.EXAMPLE
# Create a shortcut named "MyScript" to "C:\Scripts\MyScript.ps1" with a custom icon and description.
.\Create-Shortcut.ps1 -Name "MyScript" -Value "C:\Scripts\MyScript.ps1" -Icon "C:\Icons\Script.ico" -Description "Shortcut to My PowerShell Script"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Value,

    [string]$Name,

    [string]$Arguments,

    [string]$Icon,

    [int]$Index = 0,

    [string]$Directory,

    [string]$Window = "Normal",

    [string]$Hotkey,

    [string]$Description,

    [switch]$Elevated
)

# Ensure the name ends with ".lnk"
if (-not $Name) {
    $Name = [System.IO.Path]::GetFileNameWithoutExtension($Value)
}

if (-not $Name.EndsWith(".lnk", [StringComparison]::OrdinalIgnoreCase)) {
    $Name += ".lnk"
}

# Determine the full path for the shortcut
if (Test-Path $Name -PathType Container) {
    $ShortcutPath = Join-Path -Path $Name -ChildPath "$((Get-Item $Value).BaseName).lnk"
} else {
    $ShortcutPath = Join-Path -Path ([System.Environment]::GetFolderPath('Desktop')) -ChildPath $Name
}

# Create a WScript Shell object
$WshShell = New-Object -ComObject WScript.Shell

# Create a shortcut object
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)

# Set shortcut properties
$Shortcut.TargetPath = $Value
$Shortcut.Arguments = $Arguments

# Resolve the full path for the icon
$IconPath = if ($Icon) { $Icon } else { $Icon = $Value }

if ($IconPath -match '^[a-zA-Z]:') {
    # The icon path is already an absolute path
    $IconPath = (Resolve-Path $IconPath).Path
} else {
    # The icon path is a system icon or executable file, resolve the full path
    $IconPath = foreach ($ext in '.dll','.exe') {
        (Get-Command ($IconPath + $ext) -ErrorAction SilentlyContinue).Source
    }
}

# Set the icon location
$Shortcut.IconLocation = "$IconPath,$Index"

# Use the directory of the target as the working directory
$Shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($Value)

# Convert the window style to an integer
$WindowStyleValue = switch ($Window) { 'Normal' { 1 }; 'Minimized' { 7 }; 'Maximized' { 3 }; default { 1 } }
$Shortcut.WindowStyle = [int]$WindowStyleValue

$Shortcut.Hotkey = $Hotkey
$Shortcut.Description = $Description

# Save the shortcut
$Shortcut.Save()

# Set 'Run as Administrator' property if specified
if ($Elevated) {
    $bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)
    $bytes[0x15] = $bytes[0x15] -bor 0x20
    [System.IO.File]::WriteAllBytes($ShortcutPath, $bytes)
}

Write-Host "Shortcut '$Name' created at: $ShortcutPath"
