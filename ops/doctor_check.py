#!/usr/bin/env python3
import os
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
IGNORED_PARTS = {".build", ".git", ".local", "DerivedData", "Packages"}

def say(msg: str) -> None:
    print(msg)

def warn(msg: str) -> None:
    print(f"[WARN] {msg}")

def ok(msg: str) -> None:
    print(f"[OK] {msg}")

def find_files(pattern: str):
    return [
        str(path)
        for path in Path(ROOT).glob(pattern)
        if not IGNORED_PARTS.intersection(path.parts)
    ]

def main() -> int:
    issues = 0

    env_path = os.path.join(ROOT, "ops", "xcode.env")
    if not os.path.isfile(env_path):
        warn("ops/xcode.env is missing (local-only). Run: make bootstrap")
        issues += 1
    else:
        ok("ops/xcode.env exists")

    scheme_list = find_files("**/*.xcodeproj/xcshareddata/xcschemes/*.xcscheme")
    secret_key_pattern = re.compile(r"(?:API[_-]?KEY|TOKEN|SECRET|PASSWORD)", re.IGNORECASE)
    exposed_scheme_keys = []
    for scheme in scheme_list:
        try:
            root = ET.parse(scheme).getroot()
        except (ET.ParseError, OSError) as e:
            warn(f"Failed to inspect shared scheme: {os.path.relpath(scheme, ROOT)} ({e})")
            continue

        for variable in root.findall(".//EnvironmentVariable"):
            key = variable.get("key", "")
            value = variable.get("value", "")
            enabled = variable.get("isEnabled", "NO") == "YES"
            if enabled and value and secret_key_pattern.search(key):
                exposed_scheme_keys.append((os.path.relpath(scheme, ROOT), key))

    if exposed_scheme_keys:
        for scheme, key in exposed_scheme_keys:
            warn(f"Shared scheme enables secret-like environment variable '{key}': {scheme}")
        say("Fix: disable or remove secret values from shared schemes; load them from an ignored local source.")
        issues += len(exposed_scheme_keys)
    else:
        ok("No enabled secret-like values detected in shared schemes")

    if issues == 0:
        ok("doctor_check: no issues detected")
        return 0

    warn(f"doctor_check: {issues} issue(s) detected. (Detect + Guide only; no files were modified.)")
    return 1

if __name__ == "__main__":
    sys.exit(main())
