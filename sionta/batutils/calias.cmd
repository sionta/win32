@echo off

for %%I in (doskey.exe findstr.exe) do (
    if "%%~$PATH:I"=="" (
        echo %~n0: Error cannot find '%%~i'.
        exit /b 1
    )
)

if "%ALIASES%"=="" set "ALIASES=%USERPROFILE%\aliases.txt"

if /i "%ALIASES%"=="%USERPROFILE%\aliases.txt" (
    if not exist "%ALIASES%" call :sample >"%ALIASES%"
    doskey.exe alias="%~f0" $*
    doskey.exe /macrofile="%ALIASES%" >nul
)

if "%~1"=="" (
    echo Try '%~nx0 /?' for more information.
    echo.& doskey.exe /macros
    exit /b 0
) else if "%~1"=="/?" (
    goto :usage
) else if "%~1"=="/h" (
    goto :usage
) else if "%~1"=="/f" (
    if "%~2"=="" (
        echo %~n0: Requires file path.
        exit /b 1
    ) else if exist "%~f2\" (
        echo %~n0: Is not a file '%~2'.
    ) else if not exist "%~f2" (
        echo %~n0: File not found '%~f2'.
    ) else (
        set "ALIASES=%~f2"
        doskey.exe /macrofile="%~f2" >nul
        exit /b 0
    )
    exit /b 2
) else if "%~1"=="/d" (
    if "%~2"=="" (
        echo %~n0: Requires alias name.
        exit /b 1
    )
    setlocal
    set "ALIAS_NAME=%~2"
    set "ALIAS_VALUE="
    doskey.exe %~2 =
    goto :filter
) else if "%~1"=="/reload" (
    set /p x="Reloading aliases ..." <nul
    doskey.exe /macrofile="%ALIASES%" >nul
    timeout /t 1 /nobreak >nul
    echo. done!
    exit /b 0
) else if "%~2"=="" (
    doskey.exe /macros | findstr.exe /ib "%~1" 2>nul
    exit /b 0
)

goto :append

:append
setlocal
set "ALIAS_NAME="
set "ALIAS_VALUE="
for /f "tokens=1,* delims==," %%A in ("%*") do (
    set "ALIAS_NAME=%%A" & set "ALIAS_VALUE=%%B"
)
if not ["%ALIAS_NAME: =%"] == ["%ALIAS_NAME%"] (
    echo %~n0: The alias name cannot contains spaces.
    exit /b 1
)
goto :filter

:filter
findstr.exe /vlib "%ALIAS_NAME%=" "%ALIASES%">"%temp%\aliases.tmp"
if defined ALIAS_VALUE echo:%ALIAS_NAME%=%ALIAS_VALUE%>>"%temp%\aliases.tmp"
type "%temp%\aliases.tmp">"%ALIASES%" && del /f /q "%temp%\aliases.tmp"
doskey.exe /macrofile="%ALIASES%" >nul
exit /b 0

:sample
@echo:== Starting with equals ^(=^) will not be executed.
@echo:== Uncoment and/or add your aliases below:
@echo:= cp=copy $*
@echo:= ll=dir /o $*$Bfindstr /b [0-9]
@echo:= ls=dir $*
@echo:= mv=move $*
@echo:= rm=del $*
@echo:= ni=if not "$1"=="" echo/$G$1:1
@echo:.=if not exist "$1" ^(exit /b 2^) else call $*
@echo:~=pushd "%%USERPROFILE%%"
@echo:np=notepad $1
@echo:e.=explorer .
@goto:EOF

:usage
echo.Define, display, or import aliases on cmd.exe.
echo.  %~nx0 - a aliases of the doskey.exe
echo.
echo.Usage: %~nx0 [/d] [name[=value] ... ]
echo.   or: %~nx0 [/f filename.] ^| [/reload]
echo.   or: %~nx0 [/?, /h [all]]
echo.
echo.  Without arguments display aliases. The env-var
echo.  aliases file is %%ALIASES%%. Recommended to define
echo.  or remove entries in ALIASES file.
if not "%~2"=="all" (
    echo.
    echo.Type '%~nx0 /? all' for more all information.
    exit /b 0
)
echo.
echo.The following special codes on values:
echo.  $1-$9      Equivalent to parameters ^(%%1-%%9^).
echo.  $*         Represents all command-lines ^(%%*^).
echo.  $B         Equivalent to using pipelines ^(^|^).
echo.  $T         Allows multiple commands ^(^&^).
echo.  $L         Equivalent to redirect inputs ^(^<^)
echo.  $G         Equivalent to redirect outputs ^(^>^).
echo.
echo.In the %~nx0 command, utilize these notations:
echo.  ^^%%         Escaped to env-var in this script ^(%%^).
echo.
echo.Examples:
echo   C:\^>:: Escaped to enviroment variable sign:
echo.  C:\^>%~nx0 edit="%%windir%%\notepad.exe" "^%%ALIASES^%%"
echo.  edit="C:\Windows\notepad.exe" "%%ALIASES%%"
echo.
echo   C:\^>:: Appends output to the end of a file:
echo   C:\^>%~nx0 save=doskey /macros $G$G "^%%ALIASES^%%"
echo   save=doskey /macros ^>^> "%%ALIASES%%"
exit /b 0

::: REFERENCES:
::    doskey /?
::    prompt /?
::    https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/doskey
::    https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/prompt
::    https://github.com/cmderdev/cmder/blob/master/vendor/bin/alias.cmd
::    https://www.robvanderwoude.com/escapechars.php
