:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@echo off

REM Define the directory for storing aliases
set "ALIASES_DIR=%APPDATA%\aliases.d"

REM Create the directory if it doesn't exist
if not exist "%ALIASES_DIR%\" mkdir "%ALIASES_DIR%\"

REM Check if there are no existing alias batch files, and create some defaults
if not exist "%ALIASES_DIR%\*.bat" (
    >"%ALIASES_DIR%\ll.bat"  echo::: unix: alias ls='ls -F --color=auto --show-control-chars'
    >>"%ALIASES_DIR%\ll.bat" echo:@for /f "tokens=*" %%%%i in ^('dir %%1^^^|findstr /b [0-9]'^) do @^(if "%%%%~xi"=="" ^(echo:^^^[94m%%%%i\^^^[0m^) else ^(echo:%%%%i^)^)
    >"%ALIASES_DIR%\~.bat"   echo:@pushd "%%USERPROFILE%%"
    >"%ALIASES_DIR%\e..bat"  echo:@explorer .
    >"%ALIASES_DIR%\cp.bat"  echo:@copy %%*
    >"%ALIASES_DIR%\ls.bat"  echo:@dir %%*
    >"%ALIASES_DIR%\mv.bat"  echo:@move %%*
    >"%ALIASES_DIR%\ni.bat"  echo:@if not "%%~1"=="" echo/^>"%%~f1"
    >"%ALIASES_DIR%\rm.bat"  echo:@del %%*
)

REM Add the aliases directory to current session PATH
call set "PATH=%ALIASES_DIR%;%%PATH:%ALIASES_DIR%;=%%"

REM Enable delayed expansion for variable manipulation
setlocal enabledelayedexpansion

REM Check command line arguments
if "%~1"=="" (
    echo Try '%~nx0 /?' for more information.
    echo. & call :show
    exit /b 0
) else if "%~1"=="/?" (
    goto :help
) else if /i "%~1"=="/d" (
    if "%~2"=="" (
        echo Alias name is required.
        exit /b 1
    )
    set REMOVE_ALIAS=1
    shift /1
) else if "%~2"=="" (
    call :show "%~1.bat"
    exit /b 0
) else (
    call :char "%~1" || (
        echo ERROR: The alias name invalid character "%~1".
        exit /b 1
    )
    if /i "%~n1"=="%~n0" (
        echo ERROR: The alias name cannot be the same as this script "%~nx0".
        exit /b 1
    )
)

REM Set alias name, value, and file path
set "ALIAS_NAME=%~1"
set "ALIAS_VALUE=%~2"
set "ALIASES_FILE=%ALIASES_DIR%\%ALIAS_NAME%.bat"

REM Check for spaces in alias name
if not ["%ALIAS_NAME: =%"] == ["%ALIAS_NAME%"] (
    echo ERROR: The alias name cannot contains spaces.
    exit /b 1
)

REM Execute the alias creation or removal
call :test "%ALIAS_NAME%" "%ALIASES_FILE%"
if %errorlevel% equ 0 exit /b 1

REM Remove the alias if option '/d' is used.
if defined REMOVE_ALIAS (
    if exist "%ALIASES_FILE%" del /q "%ALIASES_FILE%"
    exit /b 0
)

REM Check if alias value is provided
if not defined ALIAS_VALUE (
    echo ERROR: Alias value is required.
    exit /b 1
)

REM Create and update the aliases file.
echo::%ALIAS_NAME%>"%ALIASES_FILE%"
echo:@%ALIAS_VALUE%>>"%ALIASES_FILE%"
echo:Alias "%ALIAS_NAME%" successfully created.
exit /b 0

@REM :: Alternatives for creating aliases
@REM echo::%ALIAS_NAME%=%ALIAS_VALUE%>"%ALIASES_FILE%"
@REM set /p x=@%ALIAS_VALUE%< nul >>"%ALIASES_FILE%"

:test -- Execute alias validation
if "%~1"=="" exit /b 1
setlocal enabledelayedexpansion
set "name=%~1"
set "file=%~f2"
set "names=!PATHEXT:.=%name%.!;%name%.PS1"
for %%I in (%names%) do if not "%%~$PATH:I"=="" (
    if /i "%%~$PATH:I"=="%file%" exit /b 1
    echo WARNING: The alias same as "%%~nx$PATH:I".
    exit /b 0
)
exit /b 1

:char -- Validate characters in alias name
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
exit /b 0

:show -- Display all defined aliases
setlocal
for %%A in ("%ALIASES_DIR%\*%~n1.bat") do (
    for /f "eol=: tokens=* delims=@ " %%B in ('type "%%~fA"') do (
        if not defined %%~nA (set "%%~nA=1" & echo:%%~nA=%%B)
    )
)
exit /b 0

:help -- Display script usage information
echo. Usage: %~nx0 [/d] [name[=value] ... ]
echo.   %~nx0 - a recalls Windows commands.
echo.
echo.   name       The name of the alias
echo.   value      The value of the alias
echo.   /d ^<name^>  Remove the alias from the list
echo.
echo.   The NAME and/or VALUE must be enclosed in double quotes.
echo.   For escaping the env-var sign, use '^^%%' instead of '%%%%'.
echo.
echo.   Invalid characters in alias NAME : ^< ^> ^\ ^/ ^| ^? ^: ^*
echo.   Escaped characters in this script: ^^^| ^^^& ^^^< ^^^> ^^^( ^^^)
echo.
echo. Examples:
echo.   %~nx0 d="dir "^^%%ProgramFiles^^^^(x86^^^^)^^%%" %%*"
echo.   %~nx0 log="^(foo.exe ^&^& bar.bat^) ^> log.txt"
echo.   %~nx0 /d log
goto :EOF
