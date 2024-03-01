:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@echo off
call :check_command doskey.exe || exit /b 1

if "%ALIASES%"=="" set "ALIASES=%USERPROFILE%\aliases.txt"

if /i "%ALIASES%"=="%USERPROFILE%\aliases.txt" (
    if not exist "%ALIASES%" (
        >>"%ALIASES%" echo:== Starting with "=" will not be executed.
        >>"%ALIASES%" echo:== Add your aliases below:
        >>"%ALIASES%" echo:~=pushd ^"%%USERPROFILE%%"
        >>"%ALIASES%" echo:-=popd
        >>"%ALIASES%" echo:.=if exist "$1" call $1
        >>"%ALIASES%" echo:..=pushd ..
        >>"%ALIASES%" echo:...=pushd ..\..
        >>"%ALIASES%" echo:cp=copy $*
        >>"%ALIASES%" echo:e.=explorer .
        >>"%ALIASES%" echo:ls=dir $*
        >>"%ALIASES%" echo:mv=move $*
        >>"%ALIASES%" echo:np=notepad $1
        >>"%ALIASES%" echo:rm=del $*
        >>"%ALIASES%" echo:ni=if not "$1"=="" echo:$G$1:0
        >>"%ALIASES%" echo:ll=dir /o $1$Bfindstr /b [0-9]
    )
    doskey.exe /macrofile="%ALIASES%" >nul
    doskey.exe alias="%~f0" $*
)

:: -------------------------------------------------------------
:parse_args
if "%~1"=="" (
    echo Try '%~nx0 /?' for more information.
    echo.& doskey.exe /macros
    exit /b 0
) else if "%~1"=="-" (
    shift /1
    goto :read_lines
) else if "%~1"=="/?" (
    goto :help_alias
) else if "%~1"=="/h" (
    goto :help_alias
) else if "%~1"=="/d" (
    call :delete_alias "%~2" "%ALIASES%" "%ALIASES%"
    doskey.exe %~2 =
    exit /b 0
) else if "%~1"=="/f" (
    call :check_file "%~f2" || exit /b 1
    doskey.exe /macrofile="%~f2" >nul
    set "ALIASES=%~f2"
    exit /b 0
) else if "%~1"=="/reload" (
    call :check_file "%ALIASES%" || exit /b 1
    set /p "msg=Reloading aliases ..." <nul
    doskey.exe /macrofile="%ALIASES%" >nul
    timeout /t 1 /nobreak >nul
    echo. done!
    exit /b 0
) else if "%~2"=="" (
    call :get_alias "%~1" "%ALIASES%"
    exit /b 0
)

:: -------------------------------------------------------------
:set_alias -- [name[=value] ... ]
setlocal
for /f "tokens=1,* delims==," %%A in ("%*") do (
    set "ALIAS_NAME=%%A"
    set "ALIAS_VALUE=%%B"
)
if not ["%ALIAS_NAME: =%"] == ["%ALIAS_NAME%"] (
    echo %~n0: The alias name cannot contains spaces.
    endlocal
    exit /b 1
)
call :delete_alias "%ALIAS_NAME%" "%ALIASES%" "%ALIASES%"
echo:%ALIAS_NAME%=%ALIAS_VALUE%>> "%ALIASES%"
doskey.exe /macrofile="%ALIASES%" >nul
endlocal
exit /b 0

:: -------------------------------------------------------------
:delete_alias -- [string] [filename] [filename(default: stdout)]
if "%~1"=="" (
    echo ERROR: No name specified.
    exit /b 1
)
call :check_file "%~f2" || exit /b 1
(for /f "tokens=* delims= " %%A in ('type "%~f2"') do (
    for /f "tokens=1 delims== " %%B in ("%%A") do (
            if not "%%~B"=="%~1" echo:%%A
        )
    )
) 1> "%temp%\output.tmp"
if %errorlevel% equ 0 if "%~3"=="" (
    type "%temp%\output.tmp" 2> nul
) else (
    move "%temp%\output.tmp" "%~f3" > nul
)
exit /b %errorlevel%

:: -------------------------------------------------------------
:get_alias -- [string] [filename]
if "%~1"=="" (
    echo ERROR: No name specified.
    exit /b 1
)
call :check_file "%~f2" || exit /b 1
setlocal enabledelayedexpansion
for /f "eol== tokens=* delims= " %%A in ('type "%~f2"') do (
    for /f "tokens=1 delims== " %%B in ("%%A") do (
        if /i "%%~B"=="%~1" (echo:%%A) else (
            for /L %%C in (0,1,31) do (
                set "char=%%~B"
                if /i "!char:~0,%%C!"=="%~1" echo:%%A
            )
        )
    )
)
endlocal
exit /b 0

:: -------------------------------------------------------------

:read_lines
call :check_command more.com || goto :parse_args
setlocal enabledelayedexpansion
for /f "eol== tokens=* delims= " %%A in ('more') do (
    for /f "tokens=1,* delims==," %%B in ("%%A") do (
        set "ALIAS_LINES=%%A"
        set "ALIAS_NAME=%%~B"
        set "ALIAS_VALUE=%%C"
        if "%~1"=="" (
            call :delete_alias "!ALIAS_NAME!" "!ALIASES!" "!ALIASES!"
            if errorlevel 0 (
                echo:!ALIAS_NAME!=!ALIAS_VALUE!>>"!ALIASES!"
                doskey.exe !ALIAS_NAME!=!ALIAS_VALUE!
            )
        ) else if "%~1"=="/d" (
            call :delete_alias "!ALIAS_NAME!" "!ALIASES!" "!ALIASES!"
            if errorlevel 0 (doskey.exe !ALIAS_NAME! =)
        ) else if "%~2"=="" (
            if /i "!ALIAS_NAME!"=="%~1" (
                echo:!ALIAS_LINES!
            ) else for /L %%D in (0,1,31) do (
                if /i "!ALIAS_NAME:~0,%%D!"=="%~1" (
                    echo:!ALIAS_LINES!
                )
            )
        ) else (
            endlocal
            exit /b 1
        )
    )
)
endlocal
exit /b 0

:: -------------------------------------------------------------
:check_command
if "%~$PATH:1"=="" (
    echo ERROR: Cannot find '%~1'.
    exit /b 1
)
exit /b 0

:: -------------------------------------------------------------
:check_file -- [filename]
if "%~1"=="" (
    echo ERROR: No file specified.
    exit /b 1
) else if not exist "%~f1" (
    echo ERROR: File "%~f1" not found.
    exit /b 1
) else if exist "%~f1\" (
    echo ERROR: "%~f1" is a directory, not a file.
    exit /b 1
)
exit /b 0

:: -------------------------------------------------------------
:help_alias -- [/?, /h [all]]
echo.Define, display, or import aliases on cmd.exe.
echo.  %~nx0 - a aliases of the doskey.exe
echo.
echo.Usage: %~nx0 [/d] [name[=value] ... ]
echo.   or: %~nx0 [/f filename] ^| [/reload]
echo.   or: %~nx0 [/?, /h [all]]
echo.
echo.In the %~nx0 command, utilize these notations:
echo.  name       The name of the alias
echo.  value      The value of the alias
echo.  /d ^<name^>  Remove the alias from the list
echo.  /f ^<file^>  File set to enviroment variable ALIASES.
echo.             Default: %ALIASES%
echo.  /reload    Reloaded aliases file
echo.
echo.Without arguments display aliases.
call :check_command more.com >nul && (
    echo.If using "-", read the 'name[=value]' from standard input.
)
echo.The enviroment variable aliases file is %%ALIASES%%.
echo.Recommended to define or remove entries in %%ALIASES%% file.
echo.For escaping the env-var sign, use '^^%%' instead of '%%%%'.
echo.
echo %~nx0 version 1.1 was written by Andre Attamimi
echo maintained at https://github.com/sionta/win32
if not "%~2"=="all" (
    echo.
    echo.Type '%~nx0 /? all' for more all information.
    exit /b 0
)
echo.
echo.The following special codes on value:
echo.  $1-$9      Equivalent to parameters ^(%%1-%%9^).
echo.  $*         Represents all command-lines ^(%%*^).
echo.  $B         Equivalent to using pipelines ^(^|^).
echo.  $T         Allows multiple commands ^(^&^).
echo.  $L         Equivalent to redirect inputs ^(^<^)
echo.  $G         Equivalent to redirect outputs ^(^>^).
echo.
echo.Examples:
echo.  :: Escaped to enviroment variable sign:
echo.  C:\^> %~nx0 edit="%%windir%%\notepad.exe" "^%%ALIASES^%%"
echo.  Result: edit="C:\Windows\notepad.exe" "%%ALIASES%%"
echo.
echo.  :: Supported special codes in values:
echo.  C:\^> %~nx0 save=doskey /macros $G$G "^%%ALIASES^%%"
echo.  Result: save=doskey /macros $G$G "%%ALIASES%%"
echo.  The command is the same as in command line:
echo.    save=doskey /macros ^>^> "%%ALIASES%%"
call :check_command more.com >nul && (
    echo.
    echo.Read from standart inputs or pipelines:
    echo.  :: If using option '/f' only support one file.
    echo.
    echo.  :: Read 'name=value' from files merge to %%ALIASES%%.
    echo.  C:\^> type alias1.txt alias2.txt 2^>nul ^| %~nx0 -
    echo.
    echo.  This example on 'alias1.txt' and 'alias2.txt':
    echo.    alias1.txt:
    echo.      fo=foo.exe $T$T go.bat $*
    echo.    alias2.txt:
    echo.      ba=bar $1 $2
    echo.      bz=baz $*
    echo.
    echo.  :: Delete aliases name contains 'c'.
    echo.  C:\^> %~nx0 c ^| %~nx0 - /d
    echo.
    echo.  This output the aliases name to be delete.
    echo.    c=c $*
    echo.    cm=cm $*
    echo.    cmd=cmd $*
)
exit /b 0