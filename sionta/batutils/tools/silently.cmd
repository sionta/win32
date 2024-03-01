:: Copyright (c) 2019 Andre Attamimi
:: License: http://opensource.org/licenses/MIT

@setlocal
@set APP_NAME=%1
@set APP_ARGS=%*
@cscript //nologo "%~s0?.wsf" //job:VBElevate %*
@exit /b %errorlevel%

<job id="VBElevate"><script language="VBScript">
scriptPath = WScript.ScriptFullName
scriptPath = Replace(scriptPath, "?.wsf", "")
scriptName = Mid(scriptPath, InStrRev(scriptPath, "\") + 1)

If WScript.Arguments.Count = 0 Or CheckForHelpOption(WScript.Arguments) Then
    DisplayHelp()
    WScript.Quit 0
End If

Set env = CreateObject("WScript.Shell").Environment("PROCESS")
f = env.Item("APP_NAME") : a = env.Item("APP_ARGS")
a = Right(a, (Len(a) - Len(f)))

Set uac = CreateObject("Shell.Application")
e = uac.ShellExecute(f, a, "", "open", 0)

If e <> 0 Then
    WScript.Quit 1
Else
    WScript.Quit 0
End If

Function CheckForHelpOption(args)
    For Each arg In args
        If InStr(1, arg, "/help", vbTextCompare) Or InStr(1, arg, "--help", vbTextCompare) Then
            CheckForHelpOption = True
            Exit Function
        End If
    Next
    CheckForHelpOption = False
End Function

Sub DisplayHelp()
    WScript.Echo "Usage: " & scriptName & " <program> [arguments ... ]"
    WScript.Echo "   Execute the specified program silently from the command line."
    WScript.Echo ""
    WScript.Echo "Options:"
    WScript.Echo "   /help, --help     - Display this help information."
    WScript.Echo ""
    WScript.Echo "Arguments:"
    WScript.Echo "   program           - Specifies the program name."
    WScript.Echo "   arguments         - Additional arguments for the application."
    WScript.Echo ""
    WScript.Echo "Examples:"
    WScript.Echo "   " & scriptName & " robocopy D: ""E:\Mirror Backups"" /MIR"
End Sub
</script></job>
