# Chrome Without CORS

Windows batch script to launch Chrome with CORS disabled for local development.

## Quick Start

```bash
cmod.bat
```

## Add to PATH

Run from anywhere by adding the script directory to PATH:

```powershell
$path = "C:\Users\bensc\localdev\scripts\windows\web\chrome-without-cors"
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$path", "User")
```

Then use from any console:

```bash
cmod
```

Restart your terminal for changes to take effect.

Edit the script to change:

- URL: Replace `http://localhost:3000`
- Chrome path: Update executable path if installed elsewhere

## Using Environment Variables

Set Windows env vars:

```powershell
[Environment]::SetEnvironmentVariable("DEV_URL", "http://localhost:3000", "User")
```

Then use in script:

```batch
"%DEV_URL%"
```

## Flags

| Flag                               | Purpose              |
| ---------------------------------- | -------------------- |
| `--no-first-run`                   | Skip setup wizard    |
| `--disable-web-security`           | Disable CORS         |
| `--incognito`                      | No data stored       |
| `--disable-features=Translate,...` | Disable translations |
| `--disable-extensions`             | No extensions        |

See [Chromium switches](https://peter.sh/experiments/chromium-command-line-switches/) for more.
