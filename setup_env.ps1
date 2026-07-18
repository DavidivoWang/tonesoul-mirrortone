$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"

Set-Location $PSScriptRoot

Write-Host "[ToneSoul] Environment Setup" -ForegroundColor Cyan
Write-Host "Repository Root: $PSScriptRoot" -ForegroundColor Gray

function Resolve-PythonCommand {
    $candidates = @(
        @{ Name = "python"; Args = @() },
        @{ Name = "python3"; Args = @() },
        @{ Name = "py"; Args = @("-3") }
    )

    foreach ($candidate in $candidates) {
        try {
            $candidateName = [string]$candidate.Name
            $null = Get-Command $candidateName -ErrorAction Stop
            [string[]]$candidateArgs = $candidate.Args
            $versionText = & $candidateName @candidateArgs -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>$null

            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($versionText)) {
                continue
            }

            $parts = $versionText.Trim().Split(".")
            if ($parts.Count -lt 2) {
                continue
            }

            $major = [int]$parts[0]
            $minor = [int]$parts[1]
            if (($major -gt 3) -or ($major -eq 3 -and $minor -ge 10)) {
                return [PSCustomObject]@{
                    Name = $candidateName
                    Args = $candidate.Args
                    Version = $versionText.Trim()
                }
            }

            $message = "Skipping {0}: Python {1} is below the required 3.10." -f $candidateName, $versionText.Trim()
            Write-Host $message -ForegroundColor Yellow
        }
        catch {
            continue
        }
    }

    return $null
}

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE."
    }
}

$Python = Resolve-PythonCommand
if ($null -eq $Python) {
    Write-Host "[Error] Python 3.10+ was not found." -ForegroundColor Red
    Write-Host "Tried: python, python3, and py -3." -ForegroundColor Red
    exit 1
}

Write-Host ("Found Python {0} via {1}." -f $Python.Version, $Python.Name) -ForegroundColor Green

$VenvDir = Join-Path $PSScriptRoot ".venv"
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"

if (-not (Test-Path $VenvPython)) {
    Write-Host "Creating .venv..." -ForegroundColor Cyan
    [string[]]$venvArgs = @($Python.Args) + @("-m", "venv", $VenvDir)
    Invoke-Checked -Label "Virtual environment creation" -Command $Python.Name -Arguments $venvArgs
}
else {
    Write-Host "Existing .venv found. Re-using it." -ForegroundColor Yellow
}

if (-not (Test-Path $VenvPython)) {
    Write-Host "[Error] .venv was not created successfully." -ForegroundColor Red
    exit 1
}

Invoke-Checked -Label "Virtual environment validation" -Command $VenvPython -Arguments @(
    "-c",
    "import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)"
)

Write-Host "Installing editable dependencies from pyproject.toml..." -ForegroundColor Cyan
Invoke-Checked -Label "pip upgrade" -Command $VenvPython -Arguments @(
    "-m", "pip", "install", "--upgrade", "pip"
)
Invoke-Checked -Label "ToneSoul dependency installation" -Command $VenvPython -Arguments @(
    "-m", "pip", "install", "-e", ".[dev,dashboard,monitoring]"
)

Write-Host "Setup complete." -ForegroundColor Green
Write-Host "Run: .\start_dashboard.bat" -ForegroundColor Cyan
