@echo off
if "%~1"=="" (
    goto :GetHelper
)

setlocal enabledelayedexpansion

set "allMatches="
set "getAliases="

@REM ==================================================================
:parseOptions
set "param=%~1"
if "%~1"=="" (
    goto :mainExecute
) else if "%param:~0,1%"=="/" (
    if "%~1"=="/?" (
        goto :GetHelper
    ) else if /i "%~1"=="/a" (
        set "allMatches=true"
    ) else if /i "%~1"=="/all" (
        set "allMatches=true"
    ) else if /i "%~1"=="/i" (
        set "getAliases=true"
    ) else if /i "%~1"=="/alias" (
        set "getAliases=true"
    ) else (
        echo %~n0: option '%1' is unknown.
        echo.
        call :GetHelper
        exit /b 2
    )
    if "%~2"=="" (
        if defined allMatches (
            echo %~n0: option '%~1' requires command name.
        ) else (
            echo %~n0: option '%~1' requires alias name.
        )
        exit /b 2
    )
    shift /1
    goto :parseOptions
) else (
    set "words=!words! %~nx1"
)
shift /1
goto :parseOptions

@REM ==================================================================
:mainExecute
for %%i in (!words!) do if not defined _%%~nxi (
    if not defined allMatches (
        if defined getAliases (
            call :GetAlias %%~nxi && set "_%%~nxi=1"
        ) else (
            call :GetCommand %%~nxi && set "_%%~nxi=1"
        )
    ) else (
        call :GetCommand %%~nxi && set "_%%~nxi=1"
    )
)
exit /b !errorlevel!

@REM ==================================================================
:GetAlias
setlocal
call :GetCommand doskey.exe >nul
if %errorlevel% neq 0 (
    if exist "%SystemRoot%\System32\doskey.exe" (
        set "PATH=%SystemRoot%\System32;%PATH%"
    ) else (
        exit /b 2
    )
)
for /f "tokens=1,* delims==" %%A in ('doskey /macros') do (
    if /i "%%~A"=="%~n1" (
        echo %%~A=%%B
        exit /b 0
    )
)
exit /b 1

@REM ==================================================================
:GetCommand
setlocal
set "envPath=%~dp0;%CD%;%PATH%"
set "dotExts=%PATHEXT%;.ps1"
if not "%~x1"=="" (
    if not "%~$envPath:1"=="" (
        echo %~$envPath:1
        if not defined allMatches exit /b 0
    )
) else (
    if defined allMatches (
        if defined getAliases (
            call :GetAlias %~n1
        )
        if not "%~$envPath:1"=="" (
            echo %~$envPath:1
        )
    )
    for %%E in (%dotExts%) do (
        for %%I in (%~n1%%~E) do (
            if not "%%~f$envPath:I"=="" (
                echo %%~f$envPath:I
                if not defined allMatches exit /b 0
            )
        )
    )
)
if defined allMatches exit /b 0
exit /b 1

@REM ==================================================================
:GetHelper
echo.Usage: %~nx0 [options] COMMAND [...]
echo.Write the full path of COMMAND^(s^) to standard output.
echo.
echo.  /?, /help      Print this message and exit successfully.
echo.  /a, /all       Print all matches in PATH, not just the first.
call :GetCommand doskey.exe >nul && (
    echo.  /i, /alias     Print command matches in doskey macros.
)
echo.
echo.The script returns an exit code of 0 if the search is successful,
echo.1 if the search is unsuccessful, and 2 for failures or errors.
exit /b 0
