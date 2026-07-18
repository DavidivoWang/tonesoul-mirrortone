$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"

Set-Location $PSScriptRoot

Write-Host "[ToneSoul] Dashboard Launcher" -ForegroundColor Cyan
Write-Host "Repository Root: $PSScriptRoot" -ForegroundColor Gray

$VenvPython = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
$AppPath = Join-Path $PSScriptRoot "apps\dashboard\frontend\app.py"

if (-not (Test-Path $VenvPython)) {
    Write-Host "[Error] Virtual environment is missing: $VenvPython" -ForegroundColor Red
    Write-Host "Run .\setup_env.bat first." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $AppPath)) {
    Write-Host "[Error] Dashboard entrypoint is missing: $AppPath" -ForegroundColor Red
    exit 1
}

& $VenvPython -c "import streamlit"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[Error] Streamlit is not installed in .venv." -ForegroundColor Red
    Write-Host "Run .\setup_env.bat to restore the declared dashboard extras." -ForegroundColor Yellow
    exit 1
}

Write-Host "Launching dashboard..." -ForegroundColor Green
& $VenvPython -m streamlit run $AppPath
if ($LASTEXITCODE -ne 0) {
    Write-Host "[Error] Dashboard exited with code $LASTEXITCODE." -ForegroundColor Red
    exit $LASTEXITCODE
}
