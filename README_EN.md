# xc-ops-bridge

Edit Swift with your favorite editor (Antigravity / VSCode / Zed / JetBrains / nvim / Emacs),
but unify build/test execution via Xcode (xcodebuild).

## Concept
- **Edit Anywhere**: Feel free to use your favorite editor.
- **Unify Execution**: Always build/test via `ops/xc` (or `make`).
- **Isolate Artifacts**: All build artifacts go to `.local/` (never commit).
- **Single Source of Truth**: Configuration lives in `ops/xcode.env`.

## Prerequisites

- **Xcode Project**: An `.xcodeproj`, `.xcworkspace`, or `Package.swift` is required.
  - `make build` will not work without a valid project configuration.
  - This repository includes a `HelloWorld/` package for immediate verification.

## Quickstart

```bash
make bootstrap
# Edit ops/xcode.env to point to your project (or HelloWorld)
make doctor
make build
make test
```

- ※ Run `make open` to instantly open Xcode if needed.

## Recommended AI Editors & Extensions

- **VS Code**: We recommend the **"Swift" (sswg.swift)** extension.
- **Windsurf / Cursor**: Use these for powerful AI features while relying on SourceKit-LSP for fast autocomplete.
- **Antigravity**: Delegate to the Agent to easily orchestrate refactoring right from your terminal without opening Xcode.

## Absolute NO-GOs (Blocked by System)

To prevent repository corruption, a Git `pre-commit` hook automatically blocks the following:
- Committing `.local/`, `DerivedData/`, or `*.xcresult`.
- Committing user-specific settings (xcuserdata, etc.).
- Allowing agents to run `rm -rf`, `git push`, or `git tag`.

## Docs

- **Japanese README**: [README.md](README.md)
- Editors: [docs/EDITORS.md](docs/EDITORS.md)
- Xcode setup: [docs/XCODE_SETUP.md](docs/XCODE_SETUP.md)
- Development: [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)
