#!/usr/bin/env bash
# ToneSoul installation helper for Linux/macOS.
# Run from a local repository checkout: bash install.sh

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🌌 ToneSoul Installer"
echo "====================="
echo "Repository root: $SCRIPT_DIR"
echo ""

if [[ ! -f "pyproject.toml" || ! -d "tonesoul" ]]; then
    echo "❌ Error: install.sh must run from a complete ToneSoul checkout."
    echo "   Missing pyproject.toml or tonesoul/."
    exit 1
fi

PYTHON_CMD=""
for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 \
        && "$candidate" -c \
            'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)'; then
        PYTHON_CMD="$candidate"
        break
    fi
done

if [[ -z "$PYTHON_CMD" ]]; then
    echo "❌ Error: Python 3.10+ is required."
    echo "   Please install Python 3.10 or later from https://python.org"
    exit 1
fi

echo "✅ Found Python: $($PYTHON_CMD --version)"

if [[ ! -x ".venv/bin/python" ]]; then
    echo ""
    echo "📦 Creating virtual environment..."
    "$PYTHON_CMD" -m venv .venv
else
    echo ""
    echo "📦 Existing .venv found. Re-using it."
fi

VENV_PYTHON="$SCRIPT_DIR/.venv/bin/python"

echo ""
echo "📥 Installing ToneSoul from pyproject.toml..."
"$VENV_PYTHON" -m pip install --upgrade pip
"$VENV_PYTHON" -m pip install -e ".[dev]"

echo ""
echo "🔍 Verifying package and distribution versions..."
"$VENV_PYTHON" - <<'PY'
from importlib.metadata import version

import tonesoul

installed_version = version("tonesoul52")
package_version = tonesoul.__version__
if installed_version != package_version:
    raise SystemExit(
        "ToneSoul version mismatch: "
        f"package={package_version}, distribution={installed_version}"
    )
print(f"ToneSoul version: {package_version}")
PY

echo ""
echo "🎯 Running 7D audit..."
if [[ -f "scripts/verify_7d.py" ]]; then
    if ! "$VENV_PYTHON" scripts/verify_7d.py --json; then
        echo "⚠️  7D audit did not pass. Installation succeeded, but governance verification needs review."
    fi
else
    echo "⚠️  scripts/verify_7d.py is not present in this checkout."
fi

echo ""
echo "✨ Installation complete!"
echo ""
echo "To activate the environment:"
echo "  source .venv/bin/activate"
echo ""
echo "To run tests:"
echo "  python -m pytest"
echo ""
echo "To run the 7D audit:"
echo "  python scripts/verify_7d.py"
