#!/usr/bin/env python3
import os
import sys
import glob

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

def say(msg: str) -> None:
    print(msg)

def warn(msg: str) -> None:
    print(f"[WARN] {msg}")

def ok(msg: str) -> None:
    print(f"[OK] {msg}")

def find_files(pattern: str):
    return glob.glob(os.path.join(ROOT, pattern), recursive=True)

def main() -> int:
    issues = 0

    env_path = os.path.join(ROOT, "ops", "xcode.env")
    if not os.path.isfile(env_path):
        warn("ops/xcode.env is missing (local-only). Run: make bootstrap")
        issues += 1
    else:
        ok("ops/xcode.env exists")

    pbx_list = find_files("**/*.xcodeproj/project.pbxproj")
    if not pbx_list:
        warn("No .xcodeproj/project.pbxproj found (skipping .gitignore target check)")
    else:
        found = False
        for p in pbx_list:
            try:
                data = open(p, "r", encoding="utf-8", errors="ignore").read()
            except Exception as e:
                warn(f"Failed to read pbxproj: {p} ({e})")
                continue
            if ".gitignore" in data:
                found = True
                warn(f".gitignore appears in Xcode project file: {os.path.relpath(p, ROOT)}")
        if found:
            say("Fix (manual, recommended):")
            say("  1) Open Xcode")
            say("  2) Select .gitignore in Project Navigator")
            say("  3) File Inspector -> Target Membership -> uncheck all")
            issues += 1
        else:
            ok("No .gitignore reference detected in pbxproj")

    svm_list = find_files("**/SettingsViewModel.swift")
    if not svm_list:
        ok("SettingsViewModel.swift not found (skipping MainActor guidance)")
    else:
        for s in svm_list:
            rel = os.path.relpath(s, ROOT)
            try:
                txt = open(s, "r", encoding="utf-8", errors="ignore").read()
            except Exception as e:
                warn(f"Failed to read Swift file: {rel} ({e})")
                continue

            if "SettingsViewModel" in txt and "@MainActor" not in txt:
                warn(f"@MainActor not found in {rel} (consider annotating SettingsViewModel with @MainActor)")
                issues += 1

            if "catch" in txt and ("try" not in txt and "throw" not in txt):
                warn(f"{rel} contains 'catch' but no 'try/throw' found (possible unreachable catch; please review)")
                issues += 1

    if issues == 0:
        ok("doctor_check: no issues detected")
        return 0

    warn(f"doctor_check: {issues} issue(s) detected. (Detect + Guide only; no files were modified.)")
    return 1

if __name__ == "__main__":
    sys.exit(main())
