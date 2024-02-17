@if "%~1"=="" @(
    @echo Usage: %~nx0 ^<application^> [arguments]
    @echo   Executes processes silently.
    @echo.
    @echo   application   Specifies a the program name.
    @echo   arguments     parameter of the application.
    @echo.
    @echo Example:
    @echo   %~nx0 "foo bar\build.bat" /debug=1
    @echo   %~nx0 pwsh -nop -noe -c "& {irm get.scoop.sh | iex}"
    @exit /b 0
)

@setlocal
@set APP_NAME=%1
@set APP_ARGS=%*
@cscript //nologo "%~s0?.wsf"  %*
@exit /b %errorlevel%

<job><script language="VBScript">
Set Shell = WScript.CreateObject("Shell.Application")
Set WshShell = WScript.CreateObject("WScript.Shell")
Set WshProcEnv = WshShell.Environment("Process")
sFile = WshProcEnv("APP_NAME")
sLine = WshProcEnv("APP_ARGS")
sArgs = Right(sLine, (Len(sLine) - Len(sFile)))
sExec = Shell.ShellExecute(sFile, sArgs, "", "open", 0)
If sExec <> 0 Then
    WScript.Quit(1)
Else
    WScript.Quit(0)
End If
</script></job>
