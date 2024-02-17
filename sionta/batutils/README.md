# My Utilities

```cmd
git clone https://github.com/sionta/batch.scripts.git && cd batch.scripts\myutils
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
