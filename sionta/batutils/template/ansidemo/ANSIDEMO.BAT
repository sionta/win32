@ECHO OFF
REM ANSIDEMO.BAT,  Version 2.00
REM Demonstrates the use of ANSI to control
REM text attributes and cursor positioning.
REM Written by Rob van der Woude
REM http://www.robvanderwoude.com

REM "" is the Escape character, "[" is the Escape character followed by "["
REM How they will be displayed completely depends on the editor/viewer or
REM browser you use and the selected codepage.

REM See http://www.robvanderwoude.com/ansi.html for a detailed description
REM of ANSI sequences.

ECHO [2J[2;2HDemo of ANSI sequences in batch files[4;2HCursor positioning...
FOR %%A IN (6 8 10 12 14 16 18 20) DO ECHO [%%A;%%AH%%A
PAUSE
ECHO [6;2HText attributes...[0;1;31m
FOR %%A IN (8 10 12 14 16 18 20) DO ECHO [%%A;%%AH%%A
ECHO [1A[36m
PAUSE
ECHO [0m[2J
FOR %%A IN (0 1 2 3 4 5 6) DO ECHO [1%%A;1%%AH[0;3%%A;47mForeground color 3%%A[0;1;32m
ECHO [17;17H[0;37;40mForeground color 37[0;1;32m
PAUSE
ECHO [0;33m[2J[8;23HN O R M A L   F O R E G R O U N D
FOR %%A IN (0 1 2 3 4 5 6 7) DO %COMSPEC% /C FOR %%B IN (0 1 2 3 4 5 6 7) DO ECHO [1%%A;%%B1H[3%%A;4%%Bm 3%%A on 4%%B [K
ECHO [18;1H[0;1;35m[K[1B[K
PAUSE
ECHO [0;1;33m[8;23HB R I G H T   F O R E G R O U N D
FOR %%A IN (0 1 2 3 4 5 6 7) DO %COMSPEC% /C FOR %%B IN (0 1 2 3 4 5 6 7) DO ECHO [1%%A;%%B1H[3%%A;4%%Bm 3%%A on 4%%B [K
ECHO [18;1H[0;1;36m[K[1B[K
PAUSE
ECHO [2J[4;10H[0m0 = Normal text[5;10H1 = [1mBright text[0m
ECHO [6;10H2 = [1m[2mBright attribute off? probably not, this hardly ever works[0m
ECHO [7;10H4 = [4mUnderlined or blue[0m[8;10H5 = [5mBlinking text or bright background[0m
ECHO [9;10H7 = [7mReversed text[0m[10;10H8 = [8mInvisible text[0m (invisible, except on b/w screen prints)
ECHO [1;34m
PAUSE
ECHO [0m
IF EXIST "%~dp0AN_APPLE.ANS" TYPE "%~dp0AN_APPLE.ANS"
PAUSE
ECHO.
ECHO As you probably noticed, all kind of "nonsense" is displayed on your screen.
ECHO You obviously need to load ANSI.SYS first and then run this demo again.
ECHO.
ECHO See http://www.robvanderwoude.com/ansi.html for more details
ECHO.
ECHO [2A[K[2A[K[1A[KSee[1;33m http://www.robvanderwoude.com/ansi.html [0mfor more details
