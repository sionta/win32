# My Utilities

```cmd
git clone https://github.com/sionta/win32.git
cd win32\sionta\batutils\tools
```

## Add to PATH

```cmd
:: current session only
set path=%cd%;%path%
```

```cmd
:: current user permanently
for /f "tokens=2*" %a in ('reg query HKCU\Environment /v Path') do setx PATH "%cd%;%b"
```
