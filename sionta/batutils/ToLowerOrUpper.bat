@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    goto :usage
) else if "%~1"=="/?" (
    goto :usage
) else if /i "%~1"=="/l" (
    set "alphabet=a b c d e f g h i j k l m n o p q r s t u v w x y z"
) else if /i "%~1"=="/u" (
    set "alphabet=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
) else (
    echo %~n0: Invalid command option: '%1'.
    exit /b 1
)

if "%~2"=="" (
    echo %~n0: String value must be specified.
    exit /b 2
)

set "output=%~2"
for %%A in (%alphabet%) do set "output=!output:%%A=%%A!"
echo:!output!
endlocal
exit /b 0

:usage
echo Usage: %~n0 [/l ^| /u] "string"
echo   Convert string to lowercase (/l) or uppercase (/u).
echo.
echo Examples:
echo   %~n0 /l "FoO bAr" * Output: foo bar
echo   %~n0 /u "FoO bAr" * Output: FOO BAR
exit /b 0
