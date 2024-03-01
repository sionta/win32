:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@echo off
for %%i in (reg.exe setx.exe) do if "%%~$PATH:i"=="" (
    echo Error: %%i is not found in PATH.
    exit /b 3
)

call :backupPath >nul

if "%~1"=="" goto :usage

setlocal enabledelayedexpansion

:parse
set "args=%~1"
if "%args:~0,1%"=="/" (
    if "%~1"=="/?" (
        goto :usage
    ) else if "%~1"=="/h" (
        goto :usage
    ) else if "%~1"=="/R" (
        goto :resetPath
    ) else if "%~1"=="/p" (
        for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v "Path"') do echo %%B
        exit /b 0
    ) else if /i "%~1"=="/d" (
        set "removePath=1"
        shift /1
    ) else (
        echo ERROR: Invalid option - '%~1'.
        echo Type '%~nx0 /?' for usage.
        exit /b 1
    )
)

set "valuePath=%~1"

if not defined valuePath (
    echo ERROR: Requires path value.
    exit /b 1
)

set "validPath="
for %%i in ("%valuePath:;=";"%") do (
    if not "%%~i"=="" if exist "%%~i\*.*" (
        set "validPath=!validPath!%%~i;"
    )
)

for /f "tokens=2*" %%A in (
    'reg query "HKCU\Environment" /v "Path"'
) do set "RegPath=%%B"

if /i not "%RegPath%"=="%RegPath:~0,16383%" exit /b 5

set "newerPath=%RegPath%"
set "valuePath=%validPath%"

if not "%newerPath:~-1%"==";" set "newerPath=%newerPath%;"

rem This will also eliminate duplicate paths.
for %%A in ("%RegPath:;=";"%") do (
    for %%B in ("%valuePath:;=";"%") do (
        if not "%%~A"=="" if not "%%~B"=="" (
            if /i "%%~A"=="%%~B" (
                set "newerPath=!newerPath:%%~A;=!"
            ) else if /i "%%~A"=="%%~B\" (
                set "newerPath=!newerPath:%%~A;=!"
            )
        )
    )
)

if not defined removePath set "newerPath=%newerPath%%valuePath%"
if /i not "%newerPath%"=="%newerPath:~0,16383%" exit /b 5
echo RESULTS: %newerPath%
setx Path "%newerPath%"
exit /b %errorlevel%

:backupPath
reg query "HKCU\Environment\Backup" /v "Path" /t "REG_EXPAND_SZ" >nul 2>&1
if errorlevel 1 (reg copy "HKCU\Environment" "HKCU\Environment\Backup" /f)
exit /b %errorlevel%

:resetPath
reg query "HKCU\Environment\Backup" /v "Path" /t "REG_EXPAND_SZ" >nul 2>&1
if errorlevel 0 (for /f "tokens=2*" %%A in ('reg query "HKCU\Environment\Backup" /v "Path"') do setx Path "%%~B")
exit /b %errorlevel%

:enableLongPaths
set "key=HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled"
for /f "tokens=3" %%A in ('reg query %key%') do (if /i "%%~A"=="0x1" (exit /b 0))
powershell -nop -c "& {start reg.exe 'add %key% /t REG_DWORD /d 0x1 /f' -verb runas}"
exit /b 16383

:usage
echo Usage: %~nx0 [/R] ^| [/p] ^| [/d] [PATH[;...]]
echo.
echo   /R   Reset value from registry BACKUP.
echo   /p   Print value from registry PATH.
echo   /d   Remove value from registry PATH.
echo.
echo Notes:
echo   - Max VALUE length is 16,383 characters.
echo   - Only work for current user ^(%USERNAME%^).
echo.
echo Examples:
echo   %~nx0 "C:\foo\bar;D:\apple"
echo   %~nx0 /d "D:\apple"
exit /b 0

:trimChar
@echo off
if "%~1"=="" exit /b 1
if not defined %~1 exit /b 1
setlocal enabledelayedexpansion
set "dump=!%~1!"
if "!dump:~0,1!"==";" set "dump=!dump:~1!"
if "!dump:~-1!" ==";" set "dump=!dump:~0,-1!"
endlocal & set "%~1=%dump%"
exit /b 0

@REM start "" /i /wait rundll32 sysdm.cpl^,EditEnvironmentVariables

@REM not work
@REM reg add "HKCU\Environment" /v "Path" /t "REG_MULTI_SZ" /f /d "%newerPath%"
@REM reg add "HKCU\Environment" /v "Path" /t "REG_EXPAND_SZ" /f /d "%newerPath%"
@REM start "" /i rundll32 sysdm.cpl^,EditEnvironmentVariables

@REM :compare
@REM setlocal
@REM set "value1="
@REM set "value2="
@REM for /f "tokens=5*" %%A in (
@REM     'reg compare "HKCU\Environment" "HKCU\Environment\Backup" /v "Path"'
@REM ) do if not defined value1 (
@REM     set "value1=%%B"
@REM ) else if not defined value2 (
@REM     set "value2=%%B"
@REM )
@REM if not "%value1%"=="%value2%" (
@REM     setx Path "%value2%"
@REM )
@REM goto :EOF
