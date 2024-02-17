@echo off

SETLOCAL DISABLEDELAYEDEXPANSION
call :checkDelayedExpansion

ENDLOCAL
call :checkDelayedExpansion

goto :EOF

:checkDelayedExpansion
if "!!"=="" (
  echo Delayed expansion is on
)  else (
  echo Delayed expansion is off
)
goto :EOF
