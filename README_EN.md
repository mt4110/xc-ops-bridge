# xc-ops-bridge

Edit Swift with your favorite editor (Antigravity / VSCode / Zed / JetBrains / nvim / Emacs),
but unify build/test execution via Xcode (xcodebuild).

> **This repository does not include your application's Xcode project.**
> `HelloWorld/` is only a sample Swift package used to verify `doctor` and CI.
> Place your `.xcodeproj` or `.xcworkspace` inside this repository and configure
> its relative path in `ops/xcode.env`.

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

### 1. Add your Xcode project

For a project named `MyApp`, use a layout such as:

```text
xc-ops-bridge/
├── MyApp/
│   ├── MyApp.xcodeproj
│   └── ...
├── HelloWorld/          # doctor/CI sample
├── ops/
├── Makefile
└── README.md
```

For a workspace-based project, place `MyApp/MyApp.xcworkspace` in the same way.

### 2. Create the local configuration

```bash
cd /Users/takemuramasaki/_workspace/xc-ops-bridge
make bootstrap
```

Edit the generated `ops/xcode.env`. For an Xcode project:

```sh
XCODE_WORKSPACE=""
XCODE_PROJECT="MyApp/MyApp.xcodeproj"
XCODE_SCHEME="MyApp"
```

For an Xcode workspace:

```sh
XCODE_WORKSPACE="MyApp/MyApp.xcworkspace"
XCODE_PROJECT=""
XCODE_SCHEME="MyApp"
```

All paths are relative to the `xc-ops-bridge/` directory.

### 3. Diagnose, build, and test

```bash
make doctor
make build
make test
```

`make doctor` displays the project or workspace, scheme, and destination selected
by `ops/xcode.env`, then builds and tests that target. A missing test target is
reported as a warning. Before you add an Xcode project, the default target is the
bundled `HelloWorld` package.

- ※ Run `make open` to instantly open Xcode if needed.

`make doctor` checks the selected Xcode, version, license, SDKs, and Simulator
runtimes, then builds and tests the configured target with `xcodebuild`.
Diagnostic logs and build artifacts stay under `.local/doctor/`. It also warns
about enabled secret-like values in shared schemes without printing those values.

GitHub Actions runs for pushes and pull requests, on demand, and every Monday at
00:00 UTC. It does not hook the Xcode updater; run the same `doctor` after a local
Xcode update to verify compatibility.

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

## License

Licensed under the MIT License (SPDX identifier: `MIT`). See [LICENSE](LICENSE)
for the full text.
