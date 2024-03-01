:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    goto :usage
) else if /i "%~1"=="/a" (
    if "%~2"=="" goto :usage
    set "enable=true"
) else if /i "%~1"=="/d" (
    set "enable=false"
) else (
    goto :usage
)

set "args=%*"
set "args=!args:%1="%~f0"!"
set "args=!args:"=\"!"
if /i "%enable%"=="false" set "args="

reg add "HKCU\SOFTWARE\Microsoft\Command Processor" /v "AutoRun" /d "%args%" /t REG_SZ /f
reg add "HKCU\SOFTWARE\Wow6432Node\Microsoft\Command Processor" /v "AutoRun" /d "%args%" /t REG_SZ /f
endlocal & echo Please restart cmd.exe to apply the changes.

exit /b

:usage
echo Usage: %~nx0 [options] [file <args ...>]
echo.
echo Options:
echo   /d    Remove from autorun
echo   /a    Add to autorun
echo.
echo Examples:
echo   %~nx0 /a "C:\prog.bat" /foo "bar baz"
echo   %~nx0 /d
exit /b
