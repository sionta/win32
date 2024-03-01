:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

:: some_command | read_pipeline.bat
:: read_pipeline.bat < file_name
::

@echo off
for /f "delims=" %%i in ('more') do (
    echo:%%i
)
goto :EOF