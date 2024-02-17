@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requires elevated privileges.
    pause
    powershell -noprofile -command "& {start '%~f0' -verb runas}"
    goto :EOF
)

setlocal enabledelayedexpansion
set "hostsFile=%SystemRoot%\System32\Drivers\etc\hosts"

if not exist "%hostsFile%" (
    call :contentHostFile > "%hostsFile%"
)

if not exist "%hostsFile%.bak" (
    copy /v "%hostsFile%" "%hostsFile%.bak"
)

:homePage
cls
echo Hosts Management Tool
echo [1] Add Host
echo [2] Remove Host
echo [3] Display Hosts
echo [4] Reset Hosts File
echo [5] Exit

choice /c 12345 /n /m "Enter your choice (1-5): "
goto :option%errorlevel%

:option1
set "isRemove="
goto :updateHosts

:option2
set "isRemove=true"
goto :updateHosts

:option3
goto :displayHosts

:option4
goto :resetHostsFile

:option5
exit /b 0

:endProcess
pause
set "isRemove="
goto :homePage

:updateHosts
set "newHostName="
if defined isRemove (
    set /p "newHostName=Enter the host to remove: "
) else (
    set /p "newHostName=Enter new host: "
)
if not defined newHostName (
    echo ERROR: Host name value is required.
    echo Example: 0.0.0.0 www.malware.com
    goto :updateHosts
)

set "hostExists="
for /f "usebackq delims=" %%a in ("%hostsFile%") do (
    set "line=%%~a"
    if /i "!line!"=="!newHostName!" (
        set "hostExists=true"
    )
    if defined isRemove (
        if not "!line!"=="!newHostName!" (
            echo:!line!>>"%hostsFile%.tmp"
        )
    )
)

if defined hostExists (
    if defined isRemove (
        move /y "%hostsFile%.tmp" "%hostsFile%" >nul
        echo Host "!newHostName!" removed successfully.
    ) else (
        echo Host "!newHostName!" already exists.
    )
) else (
    if not defined isRemove (
        >>"%hostsFile%" echo:!newHostName!
        echo Host "!newHostName!" added successfully.
    ) else (
        echo Host "!newHostName!" does not exist.
    )
)
goto :endProcess

:displayHosts
echo Current Hosts:
for /f "usebackq tokens=*" %%a in ("%hostsFile%") do (
    set "line=%%a"
    set "comment=!line:~0,1!"
    if not "!comment!"=="#" (
        echo !line!
    )
)
goto :endProcess

:resetHostsFile
if not exist "%hostsFile%.bak" (
    call :contentHost > "%hostsFile%.bak"
)
copy /y /v "%hostsFile%.bak" "%hostsFile%" >nul
echo Hosts file reset successfully.
goto :endProcess

:contentHostFile
@echo:# Copyright ^(c^) 1993-2009 Microsoft Corp.
@echo:#
@echo:# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
@echo:#
@echo:# This file contains the mappings of IP addresses to host names. Each
@echo:# entry should be kept on an individual line. The IP address should
@echo:# be placed in the first column followed by the corresponding host name.
@echo:# The IP address and the host name should be separated by at least one
@echo:# space.
@echo:#
@echo:# Additionally, comments ^(such as these^) may be inserted on individual
@echo:# lines or following the machine name denoted by a '#' symbol.
@echo:#
@echo:# For example:
@echo:#
@echo:#      102.54.94.97     rhino.acme.com          # source server
@echo:#       38.25.63.10     x.acme.com              # x client host
@echo:
@echo:# localhost name resolution is handled within DNS itself.
@echo:#	127.0.0.1       localhost
@echo:#	::1             localhost
@goto:eof
