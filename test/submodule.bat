@echo off
if not exist "%~dp0..\.git\modules\*" exit /b 1
pushd "%~dp0..\"
git fetch
git submodule status | findstr "^" >nul 2>&1
if %errorlevel% neq 0 (
    git submodule update --init --recursive
)
git submodule update --recursive --remote
popd
