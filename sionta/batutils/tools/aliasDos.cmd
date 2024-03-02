:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@echo off

:: Check if doskey.exe is available, exit with error code 5 if not
call :check_command doskey.exe || exit /b 5

:: Set default ALIASES file path if not provided
if "%ALIASES%"=="" set "ALIASES=%USERPROFILE%\aliases.txt"

:: Check if ALIASES file is the default one,
:: create default aliases if it doesn't exist
if /i "%ALIASES%"=="%USERPROFILE%\aliases.txt" (
    if not exist "%ALIASES%" (
        >>"%ALIASES%" echo:== Starting with "=" will not be executed.
        >>"%ALIASES%" echo:== Add your aliases below:
        >>"%ALIASES%" echo:= ~=pushd "%%USERPROFILE%%"
        >>"%ALIASES%" echo:= -=popd
        >>"%ALIASES%" echo:= .=if exist "$1" call $1
        >>"%ALIASES%" echo:= ..=pushd ..
        >>"%ALIASES%" echo:= ...=pushd ..\..
        >>"%ALIASES%" echo:cp=copy $*
        >>"%ALIASES%" echo:e.=explorer .
        >>"%ALIASES%" echo:ls=dir $*
        >>"%ALIASES%" echo:mv=move $*
        >>"%ALIASES%" echo:np=notepad $1
        >>"%ALIASES%" echo:rm=del $*
        >>"%ALIASES%" echo:ni=if not "$1"=="" echo:$G$1:0
        >>"%ALIASES%" echo:ll=dir /o $1$Bfindstr /b [0-9]
    )
    call :load_file
)

if "%~1"=="" (
    echo Try '%~nx0 /?' for more information.
    echo.& doskey /macros | sort
    exit /b 0
) else if "%~1"=="-" (
    shift /1
    goto :read_lines
) else if "%~1"=="/?" (
    goto :usage_help
) else if "%~1"=="/d" (
    shift /1
    goto :del_alias
) else if "%~1"=="/f" (
    set "ALIASES=%~f2"
    goto :load_file
) else if "%~1"=="/reload" (
    set /p msg="Reloading aliases ..." <nul
    call :load_file && echo. done! || echo.
    goto :eof
) else if "%~2"=="" (
    goto :get_alias
)

goto :set_alias

:: ***************************************************************
:: NOTE: Before using the :load_file function, ensure that the ALIASES
::       variable is defined with the appropriate file path.
::
:: Function: load_file
:: Description: Loads aliases from the specified file and sets up doskey.
:: ***************************************************************
:load_file
call :check_file "%ALIASES%" || exit /b 1
doskey /macrofile="%ALIASES%" >nul
doskey realias="%~f0" /reload
doskey alias="%~f0" $*
exit /b 0

:: ***************************************************************
:: Function: set_alias
:: Description: Sets an alias with the specified name and value.
:: Arguments:
::   %1 - The name of the alias
::   %* - The value of the alias
:: ***************************************************************
:set_alias
setlocal enabledelayedexpansion
for /f "tokens=*" %%A in ("%*") do (
    for /f "tokens=1,* delims== " %%B in ("%%A") do (
        if not ["%%A"]==["%%B=%%C"] (
            echo %~n0: Error - Invalid alias definition: %%A
            exit /b 1
        )
        set "ALIAS_NAME=%%~B"
        set "ALIAS_COMMAND=%%C"
    )
)
call :del_alias "%ALIAS_NAME%"
if errorlevel 1 exit /b 1
echo:%ALIAS_NAME%=%ALIAS_COMMAND%>>"%ALIASES%"
doskey %ALIAS_NAME%=%ALIAS_COMMAND%
exit /b 0

:: ***************************************************************
:: Function: del_alias
:: Description: Removes the alias with the specified name.
:: Arguments:
::   %1 - The name of the alias to remove
:: ***************************************************************
:del_alias
if "%~1"=="" (
    echo %~n0: Error - No alias name specified.
    exit /b 1
)
call :check_file "%ALIASES%" || exit /b 1
(for /f "tokens=* delims= " %%A in ('type "%ALIASES%"') do (
    for /f "tokens=1 delims== " %%B in ("%%A") do (
        if /i "%%~B"=="%~1" (doskey %%~B =) else echo:%%A
    )
))>"%temp%\del_alias.tmp"
move /y "%temp%\del_alias.tmp" "%ALIASES%" >nul
exit /b 0

:: ***************************************************************
:: Function: get_alias
:: Description: Retrieves the value of the alias with the specified name.
:: Arguments:
::   %1 - The name of the alias to retrieve
::   %2 - The file containing aliases
:: ***************************************************************
:get_alias
if "%~1"=="" exit /b 1
setlocal enabledelayedexpansion
for /f "tokens=* delims= " %%A in ('doskey /macros') do (
    for /f "tokens=1 delims==" %%B in ("%%A") do (
        if /i "%%~B"=="%~1" (echo:%%A) else (
            for /L %%C in (0,1,31) do (
                set "char=%%~B"
                if /i "!char:~0,%%C!"=="%~1" echo:%%A
            )
        )
    )
)
exit /b 0

:: ***************************************************************
:: Function: read_lines
:: Description: Reads lines from standard input and performs actions based on them.
:: Arguments:
::   [options] - Additional options for reading lines
:: ***************************************************************
:read_lines
call :check_command more.com || exit /b 1
call :check_file "%ALIASES%" || exit /b 1
for /f "eol== tokens=* delims= " %%A in ('more') do (
    for /f "tokens=1,* delims== " %%B in ("%%A") do (
        if "%~1"=="/d" (
            call :del_alias %%~B
            if errorlevel 1 exit /b 1
        ) else if "%~1"=="" (
            call :del_alias %%~B
            if errorlevel 1 exit /b 1
            echo %%~B=%%C>>"%ALIASES%"
        ) else (
            echo %~n0: Error - Invalid option '%1' for standard input.
            echo Only '-' to define, '- /d' to remove aliases are allowed.
            exit /b 1
        )
    )
)
exit /b 0

:: ***************************************************************
:: Function: check_file
:: Description: Checks if the specified file exists.
:: Arguments:
::   %1 - The file to check
:: ***************************************************************
:check_file
if "%~1"=="" (
    echo %~n0: Error - No ALIASES file specified.
) else if not exist "%~f1" (
    echo %~n0: Error - File "%~f1" not found.
) else if exist "%~f1\" (
    echo %~n0: Error - "%~f1" is a directory, not a file.
) else (
    exit /b 0
)
exit /b 1

:: ***************************************************************
:: Function: check_command
:: Description: Checks if the specified command is available in PATH.
:: Arguments:
::   %1 - The command to check.
:: ***************************************************************
:check_command
if "%~$PATH:1"=="" (
    echo %~n0: Error - No find "%~1" in PATH.
    exit /b 1
)
exit /b 0

:: ***************************************************************
:: Function: usage_help
:: Description: Displays usage information for the script.
:: ***************************************************************
:usage_help
echo Define, display, or import aliases on cmd.exe.
echo   %~nx0 - an alias for doskey
echo.
echo Usage: %~nx0 [/d] [name[=value] ... ]
echo    or: %~nx0 [/f file] ^| [/reload]
echo.
echo   name         The name of the alias
echo   value        The value of the alias
echo   /d ^<name^>    Remove the alias from the list
echo   /f ^<file^>    File to set environment variable ALIASES.
echo   /reload      Reloaded aliases file
echo.
echo In the %~nx0 command, utilize these notations:
echo   Without arguments, display aliases.
echo   The environment variable aliases file is ALIASES.
call :check_command more.com >nul && (
    echo   If using '-', read the 'name=value' from standard input.
)
echo   To escape the environment variable sign, use '^^%%' instead of '%%%%'.
echo   It is recommended to define or remove entries in the ALIASES file.
echo.
echo The following special codes on values:
echo   $1-$9        Equivalent to parameters ^(%%1-%%9^).
echo   $*           Represents all command-lines ^(%%*^).
echo   $B           Equivalent to using pipelines ^(^|^).
echo   $T           Allows multiple commands ^(^&^).
echo   $L           Equivalent to redirect inputs ^(^<^)
echo   $G           Equivalent to redirect outputs ^(^>^).
if not "%~2"=="all" (
    echo.& echo Type '%~nx0 /? all' for more information.
    exit /b 0
)
echo.
echo Examples:
echo   :: Escaping environment variable signs:
echo   C:\^> %~nx0 edit="%%windir%%\notepad.exe" "^%%ALIASES^%%"
echo   Result: edit="C:\Windows\notepad.exe" "%%ALIASES%%"
echo.
echo   :: Utilizing special codes in values:
echo   C:\^> %~nx0 save=doskey /macros $G$G "^%%ALIASES^%%"
echo   Result: save=doskey /macros $G$G "%%ALIASES%%"
echo   Output: save=doskey /macros ^>^> "%%ALIASES%%"
call :check_command more.com >nul || exit /b 0
echo.
echo Reading from standard input or pipelines:
echo   :: Removing an alias related to redirecting input:
echo   C:\^>%~nx0 - /d ^< alias.txt
echo.
echo   :: Defining an alias related to using pipelines:
echo   C:\^>type alias1.txt alias2.txt 2^>nul ^| %~nx0 -
echo   C:\^>echo c=%%ComSpec%% $* ^| %~nx0 -
echo.
echo   :: Removing aliases with names containing a substring:
echo   C:\^>%~nx0 c ^| %~nx0 - /d
exit /b 0
