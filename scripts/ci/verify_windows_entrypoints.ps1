[CmdletBinding()]
param(
    [string]$ArtifactDirectory = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoRoot

if ([string]::IsNullOrWhiteSpace($ArtifactDirectory)) {
    if (-not [string]::IsNullOrWhiteSpace($env:RUNNER_TEMP)) {
        $ArtifactDirectory = Join-Path $env:RUNNER_TEMP "windows-entrypoint-readback"
    }
    else {
        $ArtifactDirectory = Join-Path $RepoRoot "artifacts\windows-entrypoint-readback"
    }
}

New-Item -ItemType Directory -Path $ArtifactDirectory -Force | Out-Null

$SetupPath = Join-Path $RepoRoot "setup_env.ps1"
$LauncherPath = Join-Path $RepoRoot "start_dashboard.ps1"
$VenvDir = Join-Path $RepoRoot ".venv"
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$AppPath = Join-Path $RepoRoot "apps\dashboard\frontend\app.py"
$WindowsPowerShell = (Get-Command powershell.exe -ErrorAction Stop).Source
$BasePython = (Get-Command python.exe -ErrorAction Stop).Source
$CommitSha = if (-not [string]::IsNullOrWhiteSpace($env:MTEL_HEAD_SHA)) {
    $env:MTEL_HEAD_SHA
}
else {
    $env:GITHUB_SHA
}

$Summary = [ordered]@{
    schema_version = "1.0"
    status = "running"
    repository_root = $RepoRoot
    commit = $CommitSha
    runner_os = $env:RUNNER_OS
    harness_powershell = $PSVersionTable.PSVersion.ToString()
    windows_powershell = $null
    base_python = $BasePython
    venv_python_version = $null
    setup_exit_code = $null
    dependency_probe_exit_code = $null
    static_contract_exit_code = $null
    missing_venv_exit_code = $null
    missing_app_exit_code = $null
    missing_streamlit_exit_code = $null
    dashboard_process_started = $false
    dashboard_health_status = $null
    dashboard_health_body = $null
    dashboard_root_status = $null
    dashboard_process_stopped = $false
    failure_message = $null
    started_at_utc = [DateTime]::UtcNow.ToString("o")
    finished_at_utc = $null
}

function Assert-True {
    param(
        [Parameter(Mandatory = $true)][bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Invoke-CapturedCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $LogPath = Join-Path $ArtifactDirectory ("{0}.log" -f $Name)
    Write-Host "[CI] $Name"
    Write-Host "[CI] Command: $FilePath $($Arguments -join ' ')"

    $Output = @(& $FilePath @Arguments 2>&1)
    $ExitCode = $LASTEXITCODE
    $OutputText = ($Output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
    $OutputText | Set-Content -Path $LogPath -Encoding UTF8

    if (-not [string]::IsNullOrWhiteSpace($OutputText)) {
        Write-Host $OutputText
    }
    Write-Host "[CI] Exit code: $ExitCode"

    return [PSCustomObject]@{
        ExitCode = $ExitCode
        OutputText = $OutputText
        LogPath = $LogPath
    }
}

function Invoke-LauncherExpectedFailure {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$ExpectedText
    )

    $Result = Invoke-CapturedCommand -Name $Name -FilePath $WindowsPowerShell -Arguments @(
        "-NoLogo",
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", $LauncherPath
    )

    Assert-True -Condition ($Result.ExitCode -ne 0) -Message "$Name unexpectedly returned exit code 0."
    Assert-True -Condition ($Result.OutputText -like "*$ExpectedText*") -Message "$Name did not report the expected failure: $ExpectedText"
    return $Result
}

function Stop-DashboardProcessTree {
    param(
        [Parameter(Mandatory = $true)][System.Diagnostics.Process]$Process
    )

    try {
        $Process.Refresh()
        if (-not $Process.HasExited) {
            $Taskkill = (Get-Command taskkill.exe -ErrorAction Stop).Source
            $TaskkillResult = Invoke-CapturedCommand -Name "dashboard-process-tree-stop" -FilePath $Taskkill -Arguments @(
                "/PID", [string]$Process.Id,
                "/T",
                "/F"
            )
            if ($TaskkillResult.ExitCode -ne 0) {
                Write-Warning "taskkill returned exit code $($TaskkillResult.ExitCode)."
            }
        }

        $null = $Process.WaitForExit(15000)
        $Process.Refresh()
        return $Process.HasExited
    }
    catch {
        Write-Warning "Unable to confirm dashboard process cleanup: $($_.Exception.Message)"
        return $false
    }
}

$DashboardProcess = $null
$DashboardStdout = Join-Path $ArtifactDirectory "dashboard.stdout.log"
$DashboardStderr = Join-Path $ArtifactDirectory "dashboard.stderr.log"

try {
    Assert-True -Condition (Test-Path $SetupPath) -Message "Missing setup script: $SetupPath"
    Assert-True -Condition (Test-Path $LauncherPath) -Message "Missing dashboard launcher: $LauncherPath"
    Assert-True -Condition (Test-Path $AppPath) -Message "Missing dashboard app: $AppPath"

    $WindowsPowerShellVersion = Invoke-CapturedCommand -Name "windows-powershell-version" -FilePath $WindowsPowerShell -Arguments @(
        "-NoLogo",
        "-NoProfile",
        "-Command", '$PSVersionTable.PSVersion.ToString()'
    )
    Assert-True -Condition ($WindowsPowerShellVersion.ExitCode -eq 0) -Message "Unable to read Windows PowerShell version."
    $Summary["windows_powershell"] = $WindowsPowerShellVersion.OutputText.Trim()

    $SetupResult = Invoke-CapturedCommand -Name "setup-env" -FilePath $WindowsPowerShell -Arguments @(
        "-NoLogo",
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", $SetupPath
    )
    $Summary["setup_exit_code"] = $SetupResult.ExitCode
    Assert-True -Condition ($SetupResult.ExitCode -eq 0) -Message "setup_env.ps1 failed."
    Assert-True -Condition (Test-Path $VenvPython) -Message "setup_env.ps1 returned success but .venv Python is missing."

    $VersionResult = Invoke-CapturedCommand -Name "venv-python-version" -FilePath $VenvPython -Arguments @(
        "-c",
        "import sys; print('.'.join(map(str, sys.version_info[:3]))); raise SystemExit(0 if sys.version_info >= (3, 10) else 1)"
    )
    Assert-True -Condition ($VersionResult.ExitCode -eq 0) -Message "The generated virtual environment does not satisfy Python 3.10+."
    $Summary["venv_python_version"] = $VersionResult.OutputText.Trim()

    $DependencyResult = Invoke-CapturedCommand -Name "dashboard-dependency-probe" -FilePath $VenvPython -Arguments @(
        "-c",
        "import pandas, plotly, psutil, requests, streamlit; print('dashboard-extras-ok')"
    )
    $Summary["dependency_probe_exit_code"] = $DependencyResult.ExitCode
    Assert-True -Condition ($DependencyResult.ExitCode -eq 0) -Message "The declared dashboard or monitoring extras are incomplete."

    $StaticResult = Invoke-CapturedCommand -Name "local-entrypoint-contracts" -FilePath $VenvPython -Arguments @(
        "-m", "pytest", "-q", "tests/test_local_entrypoint_contracts.py"
    )
    $Summary["static_contract_exit_code"] = $StaticResult.ExitCode
    Assert-True -Condition ($StaticResult.ExitCode -eq 0) -Message "Local entrypoint contract tests failed on Windows."

    $CompleteVenvBackup = Join-Path $RepoRoot ".venv-ci-complete"
    if (Test-Path $CompleteVenvBackup) {
        Remove-Item -LiteralPath $CompleteVenvBackup -Recurse -Force
    }

    Move-Item -LiteralPath $VenvDir -Destination $CompleteVenvBackup
    try {
        $MissingVenvResult = Invoke-LauncherExpectedFailure -Name "launcher-missing-venv" -ExpectedText "Virtual environment is missing"
        $Summary["missing_venv_exit_code"] = $MissingVenvResult.ExitCode
    }
    finally {
        if (Test-Path $VenvDir) {
            Remove-Item -LiteralPath $VenvDir -Recurse -Force
        }
        Move-Item -LiteralPath $CompleteVenvBackup -Destination $VenvDir
    }

    $AppBackup = "$AppPath.ci-backup"
    if (Test-Path $AppBackup) {
        Remove-Item -LiteralPath $AppBackup -Force
    }

    Move-Item -LiteralPath $AppPath -Destination $AppBackup
    try {
        $MissingAppResult = Invoke-LauncherExpectedFailure -Name "launcher-missing-app" -ExpectedText "Dashboard entrypoint is missing"
        $Summary["missing_app_exit_code"] = $MissingAppResult.ExitCode
    }
    finally {
        if (Test-Path $AppPath) {
            Remove-Item -LiteralPath $AppPath -Force
        }
        Move-Item -LiteralPath $AppBackup -Destination $AppPath
    }

    if (Test-Path $CompleteVenvBackup) {
        Remove-Item -LiteralPath $CompleteVenvBackup -Recurse -Force
    }

    Move-Item -LiteralPath $VenvDir -Destination $CompleteVenvBackup
    try {
        $MinimalVenvResult = Invoke-CapturedCommand -Name "create-minimal-venv" -FilePath $BasePython -Arguments @(
            "-m", "venv", $VenvDir
        )
        Assert-True -Condition ($MinimalVenvResult.ExitCode -eq 0) -Message "Unable to create the minimal virtual environment used for the missing-Streamlit test."

        $MissingStreamlitResult = Invoke-LauncherExpectedFailure -Name "launcher-missing-streamlit" -ExpectedText "Streamlit is not installed"
        $Summary["missing_streamlit_exit_code"] = $MissingStreamlitResult.ExitCode
    }
    finally {
        if (Test-Path $VenvDir) {
            Remove-Item -LiteralPath $VenvDir -Recurse -Force
        }
        Move-Item -LiteralPath $CompleteVenvBackup -Destination $VenvDir
    }

    Assert-True -Condition (Test-Path $VenvPython) -Message "The complete virtual environment was not restored after negative-path testing."
    Assert-True -Condition (Test-Path $AppPath) -Message "The dashboard app was not restored after negative-path testing."

    $env:STREAMLIT_SERVER_HEADLESS = "true"
    $env:STREAMLIT_BROWSER_GATHER_USAGE_STATS = "false"
    $env:STREAMLIT_SERVER_ADDRESS = "127.0.0.1"
    $env:STREAMLIT_SERVER_PORT = "8501"
    $env:STREAMLIT_SERVER_FILE_WATCHER_TYPE = "none"

    $DashboardProcess = Start-Process -FilePath $WindowsPowerShell -ArgumentList @(
        "-NoLogo",
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", ('"{0}"' -f $LauncherPath)
    ) -WorkingDirectory $RepoRoot -RedirectStandardOutput $DashboardStdout -RedirectStandardError $DashboardStderr -WindowStyle Hidden -PassThru

    $Summary["dashboard_process_started"] = $true
    Write-Host "[CI] Dashboard launcher PID: $($DashboardProcess.Id)"

    try {
        $HealthUri = "http://127.0.0.1:8501/_stcore/health"
        $RootUri = "http://127.0.0.1:8501/"
        $Deadline = [DateTime]::UtcNow.AddSeconds(90)
        $HealthResponse = $null

        while ([DateTime]::UtcNow -lt $Deadline) {
            $DashboardProcess.Refresh()
            if ($DashboardProcess.HasExited) {
                break
            }

            try {
                $HealthResponse = Invoke-WebRequest -Uri $HealthUri -TimeoutSec 5
                if ($HealthResponse.StatusCode -eq 200) {
                    break
                }
            }
            catch {
                Start-Sleep -Seconds 2
            }
        }

        $DashboardProcess.Refresh()
        if ($null -eq $HealthResponse -or $HealthResponse.StatusCode -ne 200) {
            $StdoutText = if (Test-Path $DashboardStdout) { Get-Content -LiteralPath $DashboardStdout -Raw } else { "" }
            $StderrText = if (Test-Path $DashboardStderr) { Get-Content -LiteralPath $DashboardStderr -Raw } else { "" }
            throw "Dashboard health endpoint did not become ready. HasExited=$($DashboardProcess.HasExited)`nSTDOUT:`n$StdoutText`nSTDERR:`n$StderrText"
        }

        $Summary["dashboard_health_status"] = [int]$HealthResponse.StatusCode
        $Summary["dashboard_health_body"] = ([string]$HealthResponse.Content).Trim()

        $RootResponse = Invoke-WebRequest -Uri $RootUri -TimeoutSec 10
        $Summary["dashboard_root_status"] = [int]$RootResponse.StatusCode
        Assert-True -Condition ($RootResponse.StatusCode -eq 200) -Message "Dashboard root endpoint did not return HTTP 200."

        Start-Sleep -Seconds 3
        $DashboardProcess.Refresh()
        Assert-True -Condition (-not $DashboardProcess.HasExited) -Message "Dashboard launcher exited immediately after reporting healthy."

        Write-Host "DASHBOARD_PROCESS_STARTED=YES"
        Write-Host "DASHBOARD_HEALTH_READY=YES"
        Write-Host "DASHBOARD_HTTP_STATUS=$($HealthResponse.StatusCode)"
    }
    finally {
        $Summary["dashboard_process_stopped"] = Stop-DashboardProcessTree -Process $DashboardProcess
    }

    Assert-True -Condition ([bool]$Summary["dashboard_process_stopped"]) -Message "Dashboard process tree cleanup could not be confirmed."
    Write-Host "DASHBOARD_PROCESS_STOPPED=YES"

    $Summary["status"] = "passed"
}
catch {
    $Summary["status"] = "failed"
    $Summary["failure_message"] = $_.Exception.Message
    Write-Host "[CI] Failure: $($_.Exception.Message)" -ForegroundColor Red
    throw
}
finally {
    if ($null -ne $DashboardProcess -and -not [bool]$Summary["dashboard_process_stopped"]) {
        $Summary["dashboard_process_stopped"] = Stop-DashboardProcessTree -Process $DashboardProcess
    }

    $Summary["finished_at_utc"] = [DateTime]::UtcNow.ToString("o")
    $SummaryPath = Join-Path $ArtifactDirectory "summary.json"
    $Summary | ConvertTo-Json -Depth 6 | Set-Content -Path $SummaryPath -Encoding UTF8
    Write-Host "[CI] Readback summary: $SummaryPath"
}
