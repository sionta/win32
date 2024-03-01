<# : Batch script portion
@echo off
setlocal enabledelayedexpansion
set "args=%*"
set "args=!args:"=\"!"
if "%~1"=="" set "args="
powershell -nop -c "& {iex \"^& {$(gc '%~f0' -raw)} !args!\"}"
goto :EOF
#>

# PowerShell script starts here

Write-Host "Hello, World! $args" -ForegroundColor Green
