#!/bin/sh
set -eu

OPS_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH='' cd -- "$OPS_DIR/.." && pwd)

say() { printf "%s\n" "$*"; }
status() { printf "%-30s %s\n" "$1" "$2"; }
fail_hint() { printf "  -> ACTION: %s\n" "$*"; }

say "== xc-ops doctor =="
has_error=0
has_warning=0

# 1. Check Xcode and xcode-select
if p=$(xcode-select -p 2>/dev/null); then
  status "xcode-select" "OK ($p)"
  case "$p" in
    */Contents/Developer)
      xcode_app=${p%/Contents/Developer}
      if [ -d "$xcode_app" ]; then
        status "Xcode.app" "OK ($xcode_app)"
      else
        status "Xcode.app" "FAIL (selected bundle is missing)"
        has_error=1
      fi
      ;;
    *)
      status "Xcode.app" "WARNING (Command Line Tools selected)"
      fail_hint "Select Xcode with 'sudo xcode-select -s /Applications/Xcode.app'"
      has_warning=1
      ;;
  esac
else
  status "xcode-select" "NOT FOUND"
  fail_hint "Run 'xcode-select --install' or 'sudo xcode-select -s /Applications/Xcode.app'"
  has_error=1
fi

# 2. Check xcodebuild and license/first-launch state
if ver=$(xcrun xcodebuild -version 2>/dev/null); then
  ver_short=$(printf "%s\n" "$ver" | head -n1)
  status "xcodebuild" "OK ($ver_short)"
else
  status "xcodebuild" "FAIL"
  fail_hint "Run 'sudo xcodebuild -license' or open Xcode.app to accept license."
  has_error=1
fi

if xcrun xcodebuild -license check >/dev/null 2>&1 &&
   xcrun xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
  status "Xcode license/setup" "OK"
else
  status "Xcode license/setup" "FAIL"
  fail_hint "Open Xcode once, or run 'sudo xcodebuild -runFirstLaunch'."
  has_error=1
fi

# 3. Check Swift toolchain
if swift_ver=$(xcrun swiftc --version 2>/dev/null | head -n1); then
  status "swiftc" "OK ($swift_ver)"
else
  status "swiftc" "FAIL"
  has_error=1
fi

if lsp_path=$(xcrun --find sourcekit-lsp 2>/dev/null); then
  status "sourcekit-lsp" "OK ($lsp_path)"
else
  status "sourcekit-lsp" "WARNING"
  fail_hint "Needed for editor support, but not required for CLI builds. Usually part of Xcode/CLT."
  has_warning=1
fi

# 4. Check installed SDKs and Simulator runtimes
if sdk_output=$(xcrun xcodebuild -showsdks 2>/dev/null); then
  sdk_names=$(printf "%s\n" "$sdk_output" | awk '/-sdk / { if (names != "") names = names ", "; names = names $NF } END { print names }')
  status "SDKs" "OK ($sdk_names)"
else
  status "SDKs" "FAIL"
  has_error=1
fi

if runtime_output=$(xcrun simctl list runtimes 2>/dev/null); then
  runtime_count=$(printf "%s\n" "$runtime_output" | awk '/ - com\.apple\.CoreSimulator\.SimRuntime\./ && $0 !~ /unavailable/ { count++ } END { print count + 0 }')
  if [ "$runtime_count" -gt 0 ]; then
    status "Simulator runtimes" "OK ($runtime_count available)"
  else
    status "Simulator runtimes" "WARNING (none installed)"
    fail_hint "Install a runtime in Xcode Settings > Components if this project targets iOS, watchOS, tvOS, or visionOS."
    has_warning=1
  fi
else
  status "Simulator runtimes" "WARNING (simctl unavailable)"
  has_warning=1
fi

# 5. Check environment config
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
        has_warning=1
        ;;
    esac
  else
    status "DerivedData" "WARNING (Default location)"
    fail_hint "Set XCODE_DERIVED_DATA=\".local/xcode/DerivedData\" in ops/xcode.env"
    has_warning=1
  fi

else
  status "ops/xcode.env" "MISSING"
  fail_hint "Run 'make bootstrap' to generate it."
  has_error=1
fi

say ""
say "== Project checks =="
if command -v python3 >/dev/null 2>&1; then
  if ! python3 "$OPS_DIR/doctor_check.py"; then
    has_warning=1
  fi
else
  say "[WARN] python3 not found; skipping doctor_check.py"
  has_warning=1
fi

# 6. Build and test the configured target through the public command wrapper
project_log_dir="$ROOT_DIR/.local/doctor"
build_log="$project_log_dir/configured-build.log"
test_log="$project_log_dir/configured-test.log"

if [ -n "${XCODE_WORKSPACE:-}" ]; then
  configured_target="workspace: $XCODE_WORKSPACE"
elif [ -n "${XCODE_PROJECT:-}" ]; then
  configured_target="project: $XCODE_PROJECT"
elif [ -f "$ROOT_DIR/Package.swift" ]; then
  configured_target="package: Package.swift"
elif [ -n "${XCODE_SCHEME:-}" ] && [ -f "$ROOT_DIR/$XCODE_SCHEME/Package.swift" ]; then
  configured_target="package: $XCODE_SCHEME/Package.swift"
else
  configured_target="not found"
fi

status "Configured target" "$configured_target"
status "Configured scheme" "${XCODE_SCHEME:-not set}"
status "Configured destination" "${XCODE_DESTINATION:-not set}"

mkdir -p "$project_log_dir"
if sh "$OPS_DIR/xc" build -quiet >"$build_log" 2>&1; then
  build_ok=1
  status "Configured build" "OK"
  if grep -F "no rule to process file" "$build_log" | grep -F ".gitignore" >/dev/null 2>&1; then
    status ".gitignore membership" "WARNING (included in a build phase)"
    fail_hint "In Xcode, exclude .gitignore from all Build Phase Membership entries. See .local/doctor/configured-build.log."
    has_warning=1
  fi
else
  build_ok=0
  status "Configured build" "FAIL (see .local/doctor/configured-build.log)"
  tail -n 20 "$build_log"
  has_error=1
fi

if [ "$build_ok" -eq 0 ]; then
  status "Configured tests" "SKIPPED (build failed)"
elif sh "$OPS_DIR/xc" test -quiet >"$test_log" 2>&1; then
  status "Configured tests" "OK"
elif grep -F "is not currently configured for the test action" "$test_log" >/dev/null 2>&1; then
  status "Configured tests" "WARNING (no test target configured)"
  fail_hint "Add a test target to the shared scheme when the project has testable behavior."
  has_warning=1
else
  status "Configured tests" "FAIL (see .local/doctor/configured-test.log)"
  tail -n 20 "$test_log"
  has_error=1
fi

# 7. Summary
say ""
if [ "$has_error" -eq 0 ]; then
  if [ "$has_warning" -eq 0 ]; then
    say "Ready. Xcode can build and test the configured target."
  else
    say "Ready with warnings. Xcode can build the configured target; review the items above."
  fi
else
  say "Issues found. Please check hints above."
  exit 1
fi
