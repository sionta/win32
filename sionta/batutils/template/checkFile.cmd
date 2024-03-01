@echo off

if "%~1"=="" (
    echo No file specified.
    exit /b 1
) else if not exist "%~f1" (
    echo File not found: "%~f1".
    exit /b 2
) else if exist "%~f1\" (
    echo "%~f1" is a directory, not a file.
    exit /b 3
)

exit /b 0
