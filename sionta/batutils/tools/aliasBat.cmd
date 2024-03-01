:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@echo off

set "ALIASES_DIR=%USERPROFILE%\aliases.d"

if not exist "%ALIASES_DIR%\" mkdir "%ALIASES_DIR%\"

if not exist "%ALIASES_DIR%\*.bat" (
    >"%ALIASES_DIR%\~.bat"   echo:@echo off
    >>"%ALIASES_DIR%\~.bat"  echo:pushd "%%USERPROFILE%%"
    >"%ALIASES_DIR%\-.bat"   echo:@echo off
    >>"%ALIASES_DIR%\-.bat"  echo:popd
    >"%ALIASES_DIR%\e..bat"  echo:@echo off
    >>"%ALIASES_DIR%\e..bat" echo:explorer .
    >"%ALIASES_DIR%\cp.bat"  echo:@echo off
    >>"%ALIASES_DIR%\cp.bat" echo:copy %%*
    >"%ALIASES_DIR%\ls.bat"  echo:@echo off
    >>"%ALIASES_DIR%\ls.bat" echo:dir %%*
    >"%ALIASES_DIR%\mv.bat"  echo:@echo off
    >>"%ALIASES_DIR%\mv.bat" echo:move %%*
    >"%ALIASES_DIR%\ni.bat"  echo:@echo off
    >>"%ALIASES_DIR%\ni.bat" echo:if not "%%~1"=="" echo/^>"%%~f1":0
    >"%ALIASES_DIR%\rm.bat"  echo:@echo off
    >>"%ALIASES_DIR%\rm.bat" echo:del %%*
)

call set "PATH=%ALIASES_DIR%;%%PATH:%ALIASES_DIR%;=%%"

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Try '%~nx0 /?' for more information.
    echo.& call :display_alias
    goto :EOF
) else if "%~1"=="/?" (
    goto :display_usage
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
        set "ALIAS_NAME=%%~nB"
        set "ALIAS_COMMAND=%%C"
        if not defined ALIAS_COMMAND exit /b 1
        set "ALIAS_FILE=%ALIASES_DIR%\!ALIAS_NAME!.bat"
        call :validate_alias "%%~B" "!ALIAS_FILE!"
        call :validate_char ALIAS_COMMAND
        if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!
        > "!ALIAS_FILE!" echo:@echo off
        >>"!ALIAS_FILE!" echo:!ALIAS_COMMAND!
    )
)

goto :EOF

:display_alias
for %%A in ("%ALIASES_DIR%\%~1*.bat") do (
    for /f "eol=@ tokens=*" %%B in ('type "%%~fA"') do (
        echo:%%~nA=%%B
    )
)
goto :EOF

:validate_char
setlocal enabledelayedexpansion
set "char=!%~1!"
set "char=!char:$*=%%*!"
set "char=!char:$0=%%0!"
set "char=!char:$1=%%1!"
set "char=!char:$2=%%2!"
set "char=!char:$3=%%3!"
set "char=!char:$4=%%4!"
set "char=!char:$5=%%5!"
set "char=!char:$6=%%6!"
set "char=!char:$7=%%7!"
set "char=!char:$8=%%8!"
set "char=!char:$9=%%9!"
set "char=!char:$A=&!"
set "char=!char:$C=(!"
set "char=!char:$D=)!"
set "char=!char:$I=<!"
set "char=!char:$O=>!"
set "char=!char:$P=|!"
set "char=!char:$Q==!"
set "char=!char:$S= !"
@REM set "char=!char:$$=%%!"
endlocal & set "%~1=%char%"
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
set "name=%~n1"
set "file=%~f1"
set "PATHS=.\;%~d0;%~dp0;%~d1;%~dp1;%path%"
set "EXTS=!PATHEXT:.=%name%.!;%name%.PS1"
for %%I in (%EXTS%) do if not "%%~$PATHS:I"=="" (
    if /i "%%~$PATHS:I"=="%file%" exit /b 0
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
echo Use these notations in %~nx0 arguments:
echo.  $1-$9      Equivalent to parameters '%%1'-'%%9'
echo.  ^^%%         Escape env-var with '^^%%' instead of '%%%%'
echo.  $*         Represents all command-line args '%%*'
echo.  $A         Allows multiple commands '^&'
echo.  $C         Represents the left parenthesis '^('
echo.  $D         Represents the right parenthesis '^)'
echo.  $I         Equivalent to redirecting inputs '^<'
echo.  $O         Equivalent to redirecting outputs '^>'
echo.  $P         Equivalent to using pipelines '^|'
echo.  $Q         Represents the equal sign '='
echo.  $S         Represents a space ' '
echo.
echo.Examples:
echo.  ^> %~nx0 ls=dir /o $1 $P findstr /b [0-9]
echo.  ^> %~nx0 ls=dir /o ^^%%1 ^^^| findstr /b [0-9]
echo.  - Result: ls=dir /o %%1 ^| findstr /b [0-9]
echo.  ^> %~nx0 /d ls
goto :EOF
