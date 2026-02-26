#!/bin/sh
set -eu

OPS_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$OPS_DIR/.." && pwd)

say() { printf "%s\n" "$*"; }
ask() {
  printf "%s [y/N]: " "$1"
  read ans || true
  case "${ans:-}" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

say "== xc-ops-bridge bootstrap =="
say "root: $ROOT_DIR"

uname_s=$(uname -s)
if [ "$uname_s" != "Darwin" ]; then
  say "error: macOS only (xcodebuild required)"
  exit 1
fi

# 1) create ops/xcode.env if missing
if [ ! -f "$OPS_DIR/xcode.env" ]; then
  say "creating ops/xcode.env from example..."
  cp "$OPS_DIR/xcode.env.example" "$OPS_DIR/xcode.env"
else
  say "ops/xcode.env exists: OK"
fi

# 2) ensure scripts executable
chmod +x "$OPS_DIR/xc" "$OPS_DIR/doctor.sh" "$OPS_DIR/bootstrap.sh" 2>/dev/null || true

# 3) ensure .local dir
mkdir -p "$ROOT_DIR/.local/xcode"

# 4) Command Line Tools check
if xcode-select -p >/dev/null 2>&1; then
  say "Xcode Command Line Tools: OK ($(xcode-select -p))"
else
  say "Xcode Command Line Tools not found."
  if ask "Install Command Line Tools now? (opens Apple installer)"; then
    xcode-select --install || true
    say "note: installer UI opened. After install, rerun ./ops/bootstrap.sh"
    exit 0
  else
    say "abort: CLT required."
    exit 1
  fi
fi

# 5) Xcode.app check
if [ -d "/Applications/Xcode.app" ]; then
  say "Xcode.app: found"
else
  say "Xcode.app not found."
  say "Xcode is distributed via App Store. (cannot be fully auto-installed by script)"
  if ask "Open App Store page for Xcode now?"; then
    # Opens App Store directly
    open "macappstore://itunes.apple.com/app/id497799835" || true
    say "note: install Xcode, open it once, accept license, then rerun ./ops/bootstrap.sh"
    exit 0
  else
    say "skip: you can still edit code, but you will need Xcode or Xcodes CLI to build/test natively."
  fi
fi

# 6) Install Git pre-commit hook for safety
say "installing pre-commit hook to block forbidden files..."
if [ -d "$ROOT_DIR/.git/hooks" ]; then
  ln -sf "$OPS_DIR/pre-commit.sh" "$ROOT_DIR/.git/hooks/pre-commit"
  chmod +x "$ROOT_DIR/.git/hooks/pre-commit"
  say "pre-commit hook installed: OK"
else
  say "warning: .git/hooks not found, skipping hook install."
fi

# 7) sanity check xcodebuild
if xcrun xcodebuild -version >/dev/null 2>&1; then
  say "xcodebuild: OK"
else
  say "warning: xcodebuild not usable yet."
  say "hint: open Xcode once, accept license, then retry."
fi

say ""
say "Next:"
say "  1) edit ops/xcode.env (workspace/scheme/destination)"
say "  2) ./ops/xc doctor"
say "  3) ./ops/xc build"
say "OK."
