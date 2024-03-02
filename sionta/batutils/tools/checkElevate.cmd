:: errorlevel 1 return false and 0 return true
@fsutil dirty query %SystemDrive% >nul
@net session >nul 2>&1