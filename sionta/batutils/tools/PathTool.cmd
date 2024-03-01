:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@echo off
if not defined SESSIONPATH set "SESSIONPATH=%PATH%"

if "%~1"=="" (
    goto :show
) else if "%~1"=="/?" (
    goto :help
) else if "%~1"=="/R" (
    goto :refresh
) else if "%~1"=="/r" (
    if defined SESSIONPATH (
        set "PATH=%SESSIONPATH%"
        exit /b 0
    )
    exit /b 1
) else if "%~1"=="/a" (
    goto :begin
) else if "%~1"=="/d" (
    goto :begin
) else (
    echo %~n0: option '%1' is unknown.
    echo %~n0: try '%~nx0 /?' for more information
    exit /b 1
)

:begin
setlocal enabledelayedexpansion
set "AddPath=%~2"

if not defined AddPath (
    echo %~n0: option '%1' requires values.
    echo %~n0: try '%~nx0 /?' for more information
    exit /b 1
)

set "validPath="

for %%i in ("%AddPath:;=";"%") do (
    if not "%%~i"=="" (
        if exist "%%~i\" (
            if not defined validPath (
                set "validPath=%%~i;"
            ) else (
                set "validPath=!validPath!%%~i;"
            )
        )
    )
)

rem Retrieve the existing path
set "AddPath=%validPath%"
set "OldPath=%PATH%"
set "NewPath=%OldPath%"

rem Append trailing semicolon
if not "%NewPath:~-1%"==";" set "NewPath=%NewPath%;"

rem This will also eliminate duplicate paths.
for %%A in ("%OldPath:;=";"%") do (
    for %%B in ("%AddPath:;=";"%") do (
    if not "%%~A"=="" if not "%%~B"=="" (
            if /i "%%~A"=="%%~B" (
                set "NewPath=!NewPath:%%~A;=!"
            ) else if /i "%%~A"=="%%~B\" (
                set "NewPath=!NewPath:%%~A;=!"
            )
        )
    )
)

(ENDLOCAL & REM RETURN VALUES
    if "%~1"=="/a" (
        set "PATH=%NewPath%%AddPath%"
    ) else if "%~1"=="/d" (
        set "PATH=%NewPath%"
    ) else (
        exit /b 1
    )
)
exit /b 0

:help
echo Usage: %~nx0 [options] ^<dir^>[;...]
echo   Add or remove Path ^(sessions^).
echo.
echo   Without arguments display path list.
echo.
echo   /a   Add to path.
echo   /d   Remove from Path.
echo   /r   Reset to default .
echo   /R   Refresh from registry.
exit /b 0

:show
setlocal enabledelayedexpansion
set "prev="
set "count=1"
set "lines=%PATH%"
call :trim_char lines
call :split_char "%lines%" > "%temp%\show.txt"
call :sort_line -f "%temp%\show.txt" >"%temp%\show2.txt"
for /f "usebackq tokens=*" %%i in ("%temp%\show2.txt") do (
    set "line=%%~i"
    set index=!count!
    if !index! leq 9 set index=0!index!
    if not exist "!line!\" (
        echo !index! !line! [0;91m[INVALID][0m
    ) else if /i "!line!"=="!prev!" (
        echo !index! !line! [0;93m[DUPLICATE][0m
    ) else if /i "!line!"=="!prev!\" (
        echo !index! !line! [0;93m[DUPLICATE][0m
    ) else (
        echo !index! !line!
    )
    set /a count=count + 1
    set "prev=!line!"
)
endlocal & del /q "%temp%\show*.txt"
exit /b 0

:refresh
setlocal
set "regPath="
set /p "x=Refreshing Path value from registry ..." <nul
for %%A in (
    "HKLM\System\CurrentControlSet\Control\Session Manager\Environment",
    "HKCU\Environment"
) do for /f "tokens=2*" %%B in ('reg query "%%~A" /v Path') do (
    if not defined regPath (call set "regPath=%%~C;") else (
        call set "regPath=%%regPath%%%%~C;"
    )
)
set "regPath=%regPath:;;=;%"
if "%regPath:~0,1%"==";" set "regPath=%regPath:~1%"
endlocal & set "PATH=%regPath%"
timeout /t 1 /nobreak >nul
echo. done. && PATH
exit /b 0

:max_limit -- NOTE: MAX 4080 characters.
setlocal enabledelayedexpansion
if not defined %~1 exit /b 1
set "var="
set "var=!%~1!"
rem if the line too long return error 1
if not "!var:~0,4081!"=="!var:~0,4080!" exit /b 1
exit /b 0

:trim_char var char -- out: var=value
:: Trim leading or trailing character.
::   var  - Environment variable name and
::          ensure variable is defined.
::   char - Character (default: ';').
::
:: Examples trimming paths:
::   call :trim_char myvar ";"
::   make sure 'myvar' is defined.
::
rem Handle empty variable
setlocal enabledelayedexpansion
if not defined %~1 exit /b 1
set "var="
set "char="
set "var=!%~1!"
set "char=%~2"
if not defined char set "char=;"
rem Remove leading character
if "!var:~0,1!"=="%char%" set "var=!var:~1!"
rem Remove trailing character
if "!var:~-1!"=="%char%" set "var=!var:~0,-1!"
endlocal & set "%~1=%var%"
exit /b 0

:split_char str char -- out: string
:: Splits string using one character.
::   str  - Input string.
::   char - Character (default: ';').
::
:: Examples spliting paths:
::   call :split_char "%path%"
::   call :split_char "c:\foo\bar" "\"
::
setlocal enabledelayedexpansion
set "str="
set "char="
set "str=%~1"
set "char=%~2"
if not defined str exit /b 1
if not defined char set "char=;"
set "lines="!str:%char%=";"!""
for %%A in (!lines!) do if not "%%~A"=="" echo:%%~A
exit /b %errorlevel%

:sort_line
@echo off
setlocal enabledelayedexpansion
rem Define the unsorted list
if "%~1"=="-s" set "unsortedList=%~2"
rem Read the unsorted list from file
if "%~1"=="-f" set "inputFile=%~f2"
rem Requires parameter values
if "%~2"=="" exit /b 1

set i=0
if defined unsortedList (
    for %%a in (%unsortedList%) do (
        set "item[!i!]=%%a"
        set /a i+=1
    )
) else if defined inputFile (
    for /f "usebackq delims=" %%a in ("%inputFile%") do (
        set "item[!i!]=%%a"
        set /a i+=1
    )
)
rem Perform the sorting
set /a n=i-1
for /l %%i in (0,1,%n%) do (
    for /l %%j in (%%i,1,%n%) do (
        if "!item[%%i]!" gtr "!item[%%j]!" (
            set "dump=!item[%%i]!"
            set "item[%%i]=!item[%%j]!"
            set "item[%%j]=!dump!"
        )
    )
)
rem Display the sorted list
for /l %%i in (0,1,%n%) do echo !item[%%i]!
endlocal
exit /b 0
