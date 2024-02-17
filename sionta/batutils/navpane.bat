:: TASKER:
::   - set posistion to top, middle, or bottom
::         sort=0 (top This PC)
::         sort=50 (top in This PC)
::         sort=86 (under This PC)
::
::   - support disable/enable default navigation pane
::     i.e Quick Access, OneDrive, This PC, Network, etc.

@setlocal
@echo off

if /i "%~2"=="/force" set force=1& shift /2

if "%~1"=="" (
    echo usage: %~n0 set ^<name^> [^<path^>] [^<icon^>]
    echo    or: %~n0 unset ^<name^>
    echo.
    echo type '%0 /?' for more information.
    endlocal
    exit /b
) else if "%~1"=="/?" (
    echo Usage: [command] [arguments] ...
    echo.
    echo Command:
    echo   set      Create a new navigation pane
    echo   unset    Remove name if already created
    echo  /reset    Reset navigation pane to default
    echo.
    echo Arguments:
    echo   ^<name^>   Specify the navigation pane name
    echo   ^<path^>   Specify directory path, by default: %%cd%%
    echo   ^<icon^>   Specify the icon file, only: .ico, .exe, or .dll
    echo.
    echo Note: if using [icon] must be include [path]
    echo.
    echo Example:
    echo   %~n0 set foo x:\bar "imageres.dll,-1001"
    echo   %~n0 set /force foo
    echo   %~n0 unset foo
    endlocal
    exit /b
) else if /i "%~1"=="set" (
    set doset=1& set "name=%~2"
    if "" neq "%~3" (set "dest=%~f3") else set "dest=%cd%"
    if "" neq "%~4" (set "icon=%~4") else (
        set "icon=%windir%\system32\imageres.dll,-3"
    )
) else if /i "%~1"=="unset" (
    set unset=1& set "name=%~2"
) else if /i "%~1"=="/reset" (
    set reset=1
) else (
    echo %~n0: '%1' invalid command. try '%0 /?' for usage.
    endlocal
    exit /b
)

set data=%localappdata%\%~n0\data

if defined reset (
    if exist "%data%\*.cmd" (
        for /f "tokens=*" %%i in ('
            where /f "%data%:*.cmd" 2^>nul
        ') do call %%i 2>nul
    )
    endlocal
    exit /b
)

if not defined name (
    echo %~n0: name value must be specified
    endlocal
    exit /b
)

set name=%name:\=%
set name=%name:/=%

if defined unset (
    if exist "%data%\%name%.cmd" (
        call "%data%\%name%.cmd" 2>nul
    ) else (
        echo %~n0: '%name%' doesn't seem to exist and/or has been deleted.
    )
    endlocal
    exit /b
)

if exist "%data%\%name%.cmd" (
    if not defined force (
        echo %~n0: '%name%' already created or use '%0 %1 /force %2' for force mode
        endlocal
        exit /b
    ) else if exist "%data%\%name%.cmd" (
        call "%data%\%name%.cmd" 2>nul
    )
)

if not exist "%dest%\" (
    echo directory '%dest%' was not found.
    endlocal
    exit /b
)

if not exist "%data%" (
    mkdir "%data%"
    (echo.# %data%& echo.
     echo.PLEASE DON'T CHANGE ANYTHING FILES
    )>"%data%\KEEPME"
)

if not exist "%data%\bin\guid.bat" (
    mkdir "%data%\bin"
    (echo\@if ^(@X^)==^(@Y^) @end /*
     echo\@cscript //E:JScript //nologo "%%~f0" %%*
     echo\@exit /b %%errorlevel%%
     echo\@*/WScript.Echo^(^(new ActiveXObject^("Scriptlet.TypeLib"^)^).Guid^)
    )>"%data%\bin\guid.bat"
)

call "%data%\bin\guid.bat">"%data%\%name%.dat"
set /p "guid="<"%data%\%name%.dat"
del /f /q "%data%\%name%.dat"

echo Name: %name%
echo Path: %dest%
echo Icon: %icon%
echo Guid: %guid%

:: sort=0 (top This PC)
:: sort=86 (under This PC)
if not defined sort set sort=86
set class=HKCU\SOFTWARE\Classes\CLSID
>nul reg add "%class%\%guid%" /ve /t REG_SZ /d "%name%" /f
>nul reg add "%class%\%guid%" /v "Author" /t REG_SZ /d "@sionta" /f
>nul reg add "%class%\%guid%" /v "SortOrderIndex" /t REG_DWORD /d "%sort%" /f
>nul reg add "%class%\%guid%" /v "System.IsPinnedtoNameSpaceTree" /t REG_DWORD /d "1" /f
>nul reg add "%class%\%guid%\DefaultIcon" /ve /t REG_SZ /d "%icon%" /f
@REM >nul reg add "%class%\%guid%\InProcServer32" /ve /t REG_EXPAND_SZ /d "%systemroot%\system32\shell32.dll" /f
>nul reg add "%class%\%guid%\InProcServer32" /ve /t REG_SZ /d "%windir%\system32\shdocvw.dll" /f
>nul reg add "%class%\%guid%\InProcServer32" /v "ThreadingModel" /t REG_SZ /d "Both" /f
>nul reg add "%class%\%guid%\Instance" /v "CLSID" /t REG_SZ /d "{0AFACED1-E828-11D1-9187-B532F1E9575D}" /f
>nul reg add "%class%\%guid%\Instance\InitPropertyBag" /v "Attributes" /t REG_DWORD /d "21" /f
>nul reg add "%class%\%guid%\Instance\InitPropertyBag" /v "Target" /t REG_EXPAND_SZ /d "%dest%" /f
>nul reg add "%class%\%guid%\ShellEx\PropertySheetHandlers\Tab 1 General" /ve /t REG_SZ /d "{21B22460-3AEA-1069-A2DC-08002B30309D}" /f
>nul reg add "%class%\%guid%\ShellEx\PropertySheetHandlers\Tab 2 Sharing" /ve /t REG_SZ /d "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}" /f
>nul reg add "%class%\%guid%\ShellEx\PropertySheetHandlers\Tab 3 Security" /ve /t REG_SZ /d "{1f2e5c40-9550-11ce-99d2-00aa006e086c}" /f
>nul reg add "%class%\%guid%\ShellEx\PropertySheetHandlers\Tab 4 Customize" /ve /t REG_SZ /d "{ef43ecfe-2ab9-4632-bf21-58909dd177f0}" /f
>nul reg add "%class%\%guid%\ShellFolder" /v "Attributes" /t REG_DWORD /d "4034920525" /f
>nul reg add "%class%\%guid%\ShellFolder" /v "HideAsDeletePerUser" /t REG_SZ /d "" /f
>nul reg add "%class%\%guid%\ShellFolder" /v "WantsFORPARSING" /t REG_SZ /d "" /f

@REM :: IN NAVIGATION PANE
set edesk=HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace
>nul reg add "%edesk%\%guid%" /ve /t REG_SZ /d "%name%" /f
set hdesk=HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel
>nul reg add "%hdesk%" /v "%guid%" /t REG_DWORD /d "1" /f
@REM :: IN THIS PC: if using this disable %edesk% and %hdesk%
@REM set mycom=HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\Namespace
@REM >nul reg add "%mycom%\%guid%" /f

(echo.:; Name: %name%
 echo.:; Path: %dest%
 echo.:; Icon: %icon%
 echo.:; Guid: %guid%
 echo.&echo.@echo off
 echo.^>nul 2^>^&1 reg query "%class%\%guid%" ^&^& ^>nul reg delete "%class%\%guid%" /f
 echo.^>nul 2^>^&1 reg query "%edesk%\%guid%" ^&^& ^>nul reg delete "%edesk%\%guid%" /f
 echo.^>nul 2^>^&1 reg query "%hdesk%" /f "%guid%" ^&^& reg delete "%hdesk%" /v "%guid%" /f ^>nul
 echo.^>nul 2^>^&1 del /f /q "%data%\%name%.cmd" ^&^& exit /b %%errorlevel%%
)>"%data%\%name%.cmd"

echo.& endlocal
echo Please restart explorer.exe for take the effect.
exit /b
