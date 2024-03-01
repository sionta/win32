:: Reference: https://www.windows-commandline.com/check-windows-32-bit-64-bit-command-line/

@echo off
if /i "%PROCESSOR_ARCHITECTURE%" EQU "x86" (
        echo This is a 32-bit Windows running on a 32-bit processor.
        echo x86-based
) else if /i "%PROCESSOR_ARCHITECTURE%" EQU "ARM64" (
        echo This is a 64-bit Windows running on an ARM64 processor.
        echo arm64-based
) else if /i "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" (
    if defined PROCESSOR_ARCHITECTUREW6432 (
        echo This is a 32-bit Windows running on a 64-bit processor.
        echo x64-based
    ) else (
        echo This is a 64-bit Windows running on an AMD64 processor.
        echo x64-based
    )
) else (
    echo Unsupported architecture detected.
)
exit /b 0

@REM if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "OS_ARCH=x64"
@REM if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "OS_ARCH=x86"
@REM if /i "%PROCESSOR_ARCHITECTURE%"=="X86" if "%PROCESSOR_ARCHITEW6432%"=="" set "OS_ARCH=x86"
@REM if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "OS_ARCH=x64"
@REM if /i "%PROCESSOR_ARCHITEW6432%"=="ARM64" set "OS_ARCH=x86"
