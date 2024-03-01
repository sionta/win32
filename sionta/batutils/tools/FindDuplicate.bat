:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@echo off

if not exist "%~f1" (
    echo File does not exist.
    exit /b 1
)

setlocal enabledelayedexpansion

set "inputFile=%~f1"

rem Create an empty temporary file
set "tempFile=%temp%\tempfile.txt"
type nul > "%tempFile%"

rem Read the input file line by line
set "lineNumber=0"
for /f "tokens=1 delims=" %%a in ('type "%inputFile%"') do (
    set "currentLine=%%~a"

    rem Compare with previous lines
    set "isDuplicate="
    for /l %%b in (0,1,!lineNumber!) do (
        set "previousLine=!lines[%%b]!"
        if "!currentLine!" equ "!previousLine!" (
            set "isDuplicate=1"
            rem Break the inner loop if a duplicate is found
            goto :break_inner_loop
        )
    )

    :break_inner_loop
    if not defined isDuplicate (
        rem Save the current line to the array
        set "lines[!lineNumber!]=!currentLine!"
        echo !currentLine! >> "%tempFile%"
    )

    set /a "lineNumber+=1"
)

rem Print to standart output
type "%tempFile%"

rem Clean up temporary file
del "%tempFile%" /q

endlocal
goto :EOF