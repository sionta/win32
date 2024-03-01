#Requires -Version 3.0

<#
  https://adamtheautomator.com/regsvr32-exe/

  Attempt to only run the DllInstall against msxml3.dll with Verbose output
    Invoke-RegSvr32 "C:\Windows\System32\msxml3.dll" -Verbose -InstallOnly

  Attempt to register msxml3.dll silently with Verbose output
    Invoke-RegSvr32 "C:\Windows\System32\msxml3.dll" -Verbose

  Attempt to register msxml3.dll silently but no output
    Invoke-RegSvr32 "C:\Windows\System32\msxml3.dll"
#>

Function Invoke-RegSvr32 {
    <#
	.SYNOPSIS
	Wrap the regsvr32.exe Windows utility for registering OLE controls in a PowerShell function to aid in automation.

	.PARAMETER FilePath
	Specifies the DLL or control name to pass to regsvr32.exe, must be a valid file path.

	.PARAMETER InstallString
	Specify a string value to be passed as the pszCmdLine value in the DllInstall function when registering a control.

	.PARAMETER Unregister
	Unregister a previously registered control.

	.PARAMETER InstallOnly
	Do not register a control, only run the DllInstall function, which must also pass in an InstallString.

	.EXAMPLE
	PS> Invoke-RegSvr32 "C:\\Windows\\System32\\msxml3.dll"
	#>
    [CmdletBinding()]

    Param (
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [String]$FilePath,
        [ValidateScript({ -Not [String]::IsNullOrWhiteSpace($_) })]
        $InstallString,
        [Switch]$Unregister,
        [Switch]$InstallOnly
    )

    Begin {
        # Error codes are documented in this Microsoft article
        # <https://devblogs.microsoft.com/oldnewthing/20180920-00/?p=99785>
        $ExitCodes = @{
            0 = "SUCCESS";
            1 = "FAIL_ARGS - Invalid Argument";
            2 = "FAIL_OLE - OleInitialize Failed";
            3 = "FAIL_LOAD - LoadLibrary Failed";
            4 = "FAIL_ENTRY - GetProcAddress failed";
            5 = "FAIL_REG - DllRegisterServer or DllUnregisterServer failed.";
        }
    }

    Process {
        If ($InstallOnly -And -Not $InstallString) {
            Write-Error "If you are running DllInstall by itself, an install string must be included."
            Return
        }

        $Arguments = "/s{0}{1}{2} {3}" -f
      (($Unregister) ? ' /U': ''),
      (($InstallString) ? " /i:$InstallString": ''),
      (($InstallOnly) ? ' /n': ''),
        $FilePath

        Write-Verbose $Arguments

        Try {
            $Result = Start-Process -FilePath 'regsvr32.exe' -Args $Arguments -Wait -NoNewWindow -PassThru

            If ($Result.ExitCode -NE 0) {
                Write-Error $ExitCodes[$Result.ExitCode]
            }
        } Catch {
            Write-Error $_.Exception.Message
        }
    }
}
