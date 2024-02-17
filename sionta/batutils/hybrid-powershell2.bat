@type "%~f0" | findstr "^@type.*" | powershell -& goto :EOF

# PowerShell script starts here

Write-Host "Hello, World!" -ForegroundColor Green
