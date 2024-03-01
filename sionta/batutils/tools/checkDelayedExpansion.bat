:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@echo off

SETLOCAL ENABLEDELAYEDEXPANSION

call :checkDelayedExpansion

ENDLOCAL

call :checkDelayedExpansion

goto :EOF

:checkDelayedExpansion
if [!!]==[] (
  echo Delayed expansion is on
)  else (
  echo Delayed expansion is off
)
goto :EOF
