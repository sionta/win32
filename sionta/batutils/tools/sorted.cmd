:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@setlocal enabledelayedexpansion
@echo off

:parse
if "%~1"=="" (
    goto :usage
) else if /i "%~1"=="/?" (
    goto :usage
) else if /i "%~1"=="/help" (
    goto :usage
) else if /i "%~1"=="/t" (
    set "inputText=%~2"
) else if /i "%~1"=="/text" (
    set "inputText=%~2"
) else if /i "%~1"=="/f" (
    set "inputFile=%~f2"
) else if /i "%~1"=="/file" (
    set "inputFile=%~f2"
) else (
    echo %~n0: option '%1' is unknown
    echo %~n0: try '%~nx0 /?' for more information.
    goto :error
)

if "%~2"=="" (
    echo %~n0: option '%1' requires value.
    goto :error
)

set i=0

rem Read the unsorted list from string.
if defined inputText (
    for %%a in (%inputText%) do (
        set "item[!i!]=%%a"
        set /a i+=1
    )
)

rem Read the unsorted list from file.
if defined inputFile (
    if not exist "%inputFile%" (
        echo %~n0: File not found '%inputFile%'.
        goto :error
    )
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
for /l %%i in (0,1,%n%) do echo:!item[%%i]!

endlocal
exit /b 0

:error
if "!!"=="" endlocal
exit /b 1

:usage
echo:usage: %~nx0 [/t ^| /text] string
echo:   or: %~nx0 [/f ^| /file] filename.
echo:
echo:  /?, /help  Display usage information.
echo:  /t, /text  Read the unsorted list from a string.
echo:  /f, /file  Read the unsorted list from a file.
echo:
echo:examples
echo:  %~nx0 /t "baz foo bar" -^> bar baz foo
echo:  %~nx0 /f filelist.txt  -^> sorted by lines
goto:EOF
