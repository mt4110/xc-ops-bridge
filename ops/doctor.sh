#!/bin/sh
set -eu

OPS_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$OPS_DIR/.." && pwd)

say() { printf "%s\n" "$*"; }
status() { printf "%-30s %s\n" "$1" "$2"; }
fail_hint() { printf "  -> ACTION: %s\n" "$*"; }

say "== doctor =="
has_error=0

# 1. Check xcode-select
if p=$(xcode-select -p 2>/dev/null); then
  status "xcode-select" "OK ($p)"
  # Check if it points to Xcode.app (recommended for stable toolchain)
  case "$p" in
    /Applications/Xcode*) ;;
    *)
      say "   note: xcode-select is not pointing to standard /Applications/Xcode.app"
      ;;
  esac
else
  status "xcode-select" "NOT FOUND"
  fail_hint "Run 'xcode-select --install' or 'sudo xcode-select -s /Applications/Xcode.app'"
  has_error=1
fi

# 2. Check xcodebuild & License
if ver=$(xcrun xcodebuild -version 2>/dev/null); then
  # check for license agreement error inside output if possible, but usually it fails exit code if not agreed
  ver_short=$(echo "$ver" | head -n1)
  status "xcodebuild" "OK ($ver_short)"
else
  status "xcodebuild" "FAIL"
  fail_hint "Run 'sudo xcodebuild -license' or open Xcode.app to accept license."
  has_error=1
fi

# 3. Check Swift Toolchain
if swift_ver=$(xcrun swiftc --version 2>/dev/null | head -n1); then
  status "swiftc" "OK"
else
  status "swiftc" "FAIL"
  has_error=1
fi

if lsp_ver=$(xcrun sourcekit-lsp --version 2>/dev/null); then
  status "sourcekit-lsp" "OK"
else
  status "sourcekit-lsp" "WARNING"
  fail_hint "Needed for editor support, but not required for CLI builds. Usually part of Xcode/CLT."
fi

# 4. Check Environment Config
config_path="$OPS_DIR/xcode.env"
if [ -f "$config_path" ]; then
  status "ops/xcode.env" "OK"

  # Load config to check DerivedData
  # shellcheck disable=SC1090
  . "$config_path"

  # Check DerivedData location compliance
  dd="${XCODE_DERIVED_DATA:-}"
  if [ -n "$dd" ]; then
    case "$dd" in
      .local/*) status "DerivedData" "OK (Isolated in .local)" ;;
      *)
        status "DerivedData" "WARNING (Not in .local)"
        fail_hint "Set XCODE_DERIVED_DATA=\".local/...\" in ops/xcode.env to prevent git pollution."
        # Not a strict error, but a strong warning
        ;;
    esac
  else
    status "DerivedData" "WARNING (Default location)"
    fail_hint "Set XCODE_DERIVED_DATA=\".local/xcode/DerivedData\" in ops/xcode.env"
  fi

else
  status "ops/xcode.env" "MISSING"
  fail_hint "Run 'make bootstrap' to generate it."
  has_error=1
fi


echo ""
echo "== Doctor Check (Detect + Guide only) =="
if command -v python3 >/dev/null 2>&1; then
  python3 "$OPS_DIR/doctor_check.py" || true
else
  echo "[WARN] python3 not found; skipping doctor_check.py"
fi

# 5. Summary
say ""
if [ "$has_error" -eq 0 ]; then
  say "Ready to build. Try: make build"
else
  say "Issues found. Please check hints above."
  exit 1
fi
