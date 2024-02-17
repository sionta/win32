@echo off

if "%~1"=="" (goto :usage) else if "%~1"=="/?" goto :usage

for %%i in (findstr.exe) do if "%%~$PATH:i"=="" (
    echo %~n0: Error cannot find '%%~i'.
    exit /b 1
)

setlocal

set "regHeader=Windows Registry Editor Version 5.00"

set "outputFile=%temp%\output.reg"
if exist "%outputFile%" del /f /q "%outputFile%"

@( if "%~1"=="-" (
    for /f "tokens=*" %%i in ('findstr "^"') do (type "%%~fi" 2>nul)
) else (
    for %%i in (%*) do (type "%%~fi" 2>nul)
)) > "%outputFile%"

type "%outputFile%" | findstr "^" >nul
if %errorlevel% equ 0 (
    echo %regHeader%
    type "%outputFile%" | findstr /vic:"%regHeader%"
)

exit /b %errorlevel%

:usage
echo Usage: %~nx0 [^<filename.reg ^| *.reg^> ...]
echo   Combine Registry Files to standard output.
echo.
echo   If using "-", read the file list from standard input.
echo.
echo Examples:
echo   %~nx0 foo.reg "%%cd%%\*.reg" ^> result.reg
echo   where.exe "c:\foo:*.reg" ^| %~nx0 - ^> result.reg
exit /b 0
