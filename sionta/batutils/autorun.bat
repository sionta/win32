@echo off
setlocal

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

set "params=%~2"
if defined params set "params=%params:"=\"%"
if /i "%enable%"=="false" set "msg=Un" & set "params="

<nul set /p x="%msg%Registering autorun..."
>nul reg add "HKCU\SOFTWARE\Microsoft\Command Processor" /v "AutoRun" /t REG_SZ /d "%params%" /f
>nul reg add "HKCU\SOFTWARE\Wow6432Node\Microsoft\Command Processor" /v "AutoRun" /t REG_SZ /d "%params%" /f
echo. successfully.
echo Please restart cmd.exe for take the effect.
exit /b 0

:usage
echo usage: %~nx0 [/d] ^| [/a "file args ..."]
echo.
echo   /d    remove from autorun
echo   /a    add to autorun
echo.
echo e.g,: %~nx0 /a ""c:\file.bat" --foo "bar baz""
exit /b 0
