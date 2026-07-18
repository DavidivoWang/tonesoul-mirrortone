"""Static contracts for cross-platform local setup entrypoints."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def _capture(pattern: str, text: str, label: str) -> str:
    match = re.search(pattern, text, flags=re.MULTILINE)
    assert match is not None, f"Unable to locate {label}"
    return match.group(1)


def test_package_version_matches_project_metadata() -> None:
    pyproject = _read("pyproject.toml")
    package_init = _read("tonesoul/__init__.py")

    project_version = _capture(r'^version = "([^"]+)"$', pyproject, "project version")
    package_version = _capture(
        r'^__version__ = "([^"]+)"$', package_init, "package version"
    )

    assert package_version == project_version


def test_windows_setup_uses_pyproject_as_dependency_source() -> None:
    setup = _read("setup_env.ps1")

    assert '"-e", ".[dev,dashboard,monitoring]"' in setup
    assert "pip install -r requirements.txt" not in setup
    assert "streamlit plotly pandas psutil requests" not in setup
    assert "Python 3.10+" in setup
    assert '@{ Name = "py"; Args = @("-3") }' in setup


def test_unix_installer_verifies_the_installed_distribution() -> None:
    installer = _read("install.sh")

    assert "set -euo pipefail" in installer
    assert 'version("tonesoul52")' in installer
    assert "package_version = tonesoul.__version__" in installer
    assert '|| echo "ToneSoul core installed"' not in installer
    assert "curl -sSL" not in installer


def test_dashboard_launcher_fails_closed_on_missing_inputs() -> None:
    launcher = _read("start_dashboard.ps1")

    assert "Set-Location $PSScriptRoot" in launcher
    assert "Test-Path $VenvPython" in launcher
    assert "Test-Path $AppPath" in launcher
    assert '$ErrorActionPreference = "Continue"' not in launcher
    assert "Blind Trust" not in launcher
    assert "Blind Mode" not in launcher
