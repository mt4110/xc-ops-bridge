# xc-ops-bridge

Edit Swift with your favorite editor (Antigravity / VSCode / Zed / JetBrains / nvim / Emacs),
but unify build/test execution via Xcode (xcodebuild).

## Concept (Unbreakable Rules)
- **Edit Anywhere**: Use any editor you like.
- **Unify Execution**: Always build/test via `ops/xc` (or `make`).
- **Isolate Artifacts**: All build artifacts go to `.local/` (never commit).
- **Single Source of Truth**: Configuration lives in `ops/xcode.env`.

## Prerequisites
- **Xcode Project**: An `.xcodeproj` or `.xcworkspace` is required.
  - `make build` will not work without a valid project.
  - This repository includes a `HelloWorld/` package for immediate verification.

## Quickstart
```bash
make bootstrap
# Edit ops/xcode.env to point to your project (or HelloWorld)
make doctor
make build
make test
```

## Absolute NO-GOs (Violating these will break the workflow)
- Direct `xcodebuild` usage with divergent flags (Always via `ops/xc`).
- Committing `.local/`, `DerivedData/`, or `*.xcresult`.
- Committing user-specific settings (xcuserdata, etc.).
- Allowing agents to run `rm -rf`, `git push`, or `git tag`.

## Docs
- **Japanese README**: [README.md](README.md)
- Editors: [docs/EDITORS.md](docs/EDITORS.md)
- Xcode setup: [docs/XCODE_SETUP.md](docs/XCODE_SETUP.md)
- Development: [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)
