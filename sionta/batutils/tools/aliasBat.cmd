:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@echo off
if "%~1"=="/?" goto :display_usage

setlocal enabledelayedexpansion

if not defined ALIASES_DIR (
    set "ALIASES_DIR=%USERPROFILE%\aliases.d"
    setx ALIASES_DIR "!ALIASES_DIR!" >nul
    for /f "tokens=2*" %%I in (
        'reg query HKCU\Environment /v Path'
    ) do (
        setx PATH "!ALIASES_DIR!;%%~J" >nul
    )
)

if not exist "%ALIASES_DIR%\" mkdir "%ALIASES_DIR%\"

if not exist "%ALIASES_DIR%\*.bat" (
    >"%ALIASES_DIR%\~.bat"  (echo @echo off&echo pushd "%%USERPROFILE%%")
    >"%ALIASES_DIR%\-.bat"  (echo @echo off&echo popd)
    >"%ALIASES_DIR%\e..bat" (echo @echo off&echo explorer .)
    >"%ALIASES_DIR%\cp.bat" (echo @echo off&echo copy %%*)
    >"%ALIASES_DIR%\ls.bat" (echo @echo off&echo dir %%*)
    >"%ALIASES_DIR%\mv.bat" (echo @echo off&echo move %%*)
    >"%ALIASES_DIR%\rm.bat" (echo @echo off&echo del %%*)
    >"%ALIASES_DIR%\ni.bat" (echo @echo off&echo if not "%%~1"=="" echo/^>"%%~f1":0)
)

if "%~1"=="" (
    echo Try '%~nx0 /?' for more information.
    echo.& call :display_alias
    goto :EOF
) else if /i "%~1"=="/d" (
    set "REMOVE_ALIAS=%~n2"
    shift /1
) else if "%~2"=="" (
    call :display_alias "%~1"
    goto :EOF
)

if "%~1"=="" (
    echo %~n0: Error - No alias name specified.
    exit /b 1
)

call :validate_alias "%~1" || (
    echo %~n0: Error - Avoid using "%~1" this invalid characters.
    exit /b 1
)

if /i "%~n1"=="%~n0" (
    echo %~n0: Error - Avoid using "%~1" same as this script.
    exit /b 5
)

if defined REMOVE_ALIAS (
    del /q "%ALIASES_DIR%\%REMOVE_ALIAS%.bat" >nul 2>&1
    goto :EOF
)

for /f "tokens=*" %%A in ("%*") do (
    for /f "tokens=1,* delims== " %%B in ("%%A") do (
        if not ["%%A"]==["%%B=%%C"] (
            echo %~n0: Error - Invalid alias definition: %%A
            echo Make sure the alias name does not contain spaces.
            exit /b 1
        )
        set "ALIAS_NAME=%%~B"
        set "ALIAS_COMMAND=%%C"
    )
)

set "ALIAS_FILE=%ALIASES_DIR%\%ALIAS_NAME%.bat"
call :validate_alias "%ALIAS_NAME%" "%ALIAS_FILE%"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
> "%ALIAS_FILE%" echo:@echo off
>>"%ALIAS_FILE%" echo:%ALIAS_COMMAND%
goto :EOF

:display_alias
for %%A in ("%ALIASES_DIR%\%~1*.bat") do (
    for /f "eol=@ tokens=*" %%B in ('type "%%~fA"') do (
        echo:%%~nA=%%B
    )
)
goto :EOF

:validate_alias
if "%~1"==""  exit /b 1
if "%~1"=="." exit /b 1
if "%~1"=="<" exit /b 1
if "%~1"==">" exit /b 1
if "%~1"=="/" exit /b 1
if "%~1"=="\" exit /b 1
if "%~1"=="|" exit /b 1
if "%~1"==":" exit /b 1
if "%~1"=="?" exit /b 1
if "%~1"=="*" exit /b 1
if "%~2"==""  exit /b 0
shift /1
setlocal enabledelayedexpansion
set "NAME=%~n1"
set "FILE=%~f1"
set "EXTS=!PATHEXT:.=%NAME%.!;%NAME%.PS1"
set "PATHS=.\;%~d0;%~dp0;%~d1;%~dp1;%PATH%"
for %%I in (%EXTS%) do if not "%%~$PATHS:I"=="" (
    if /i "%%~$PATHS:I"=="%FILE%" exit /b 0
    echo %~n0: Error - The alias conflicts with: "%%~$PATH:I"
    exit /b 5
)
exit /b 0

:display_usage
echo.Usage: %~nx0 [/d] [name[=value] ... ]
echo.
echo.  name       The name of the alias
echo.  value      The value of the alias
echo.  /d ^<name^>  Remove the alias from the list
echo.
echo.  Escape env-var with '^^%%' instead of '%%%%'.
@REM echo.  The env-var alias location is ALIASES_DIR.
echo.
echo.Examples:
echo.  ^> %~nx0 ls=dir /o ^^%%1 ^^^| findstr /b [0-9]
echo.  - Result: ls=dir /o %%1 ^| findstr /b [0-9]
echo.  ^> %~nx0 /d ls
goto :EOF
