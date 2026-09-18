# xc-ops-bridge

好きなエディタ（Antigravity / VSCode / Zed / JetBrains / nvim / Emacs）で Swift を編集し、
ビルド/テストは Xcode（xcodebuild）に統一するための運用キット。

> **このリポジトリには実アプリのXcodeプロジェクトは入っていません。**
> `HelloWorld/` は `doctor` とCIを確認するためのサンプルSwift Packageです。
> 自分の `.xcodeproj` または `.xcworkspace` をこのリポジトリ内へ配置し、
> `ops/xcode.env` からその相対パスを指定して使います。

## コンセプト
- **編集は自由**：使い慣れたエディタで開発を進められます。
- **実行は統一**：ビルドやテストは `ops/xc` （または `make`）から行います。
- **生成物を隔離**：ビルド中間ファイルなどは `.local/` に隔離されGitを汚しません。
- **設定は1つだけ**：`ops/xcode.env` を唯一の真実とします。

## 前提条件 (Prerequisites)
- **Xcode Project**: `.xcodeproj`、`.xcworkspace`、または `Package.swift` のいずれかが必要です。
  - プロジェクト設定が正しくない場合は `make build` が動きません。
  - 本リポジトリには検証用の `HelloWorld/` (SPMパッケージ) が含まれており、すぐに動作確認できます。

## Quickstart

### 1. Xcodeプロジェクトを配置する

例えば `MyApp` を使う場合、次のように配置します。

```text
xc-ops-bridge/
├── MyApp/
│   ├── MyApp.xcodeproj
│   └── ...
├── HelloWorld/          # doctor/CI用サンプル
├── ops/
├── Makefile
└── README.md
```

Workspaceを使うプロジェクトなら、同様に `MyApp/MyApp.xcworkspace` を配置します。

### 2. ローカル設定を作る

```bash
cd /Users/takemuramasaki/_workspace/xc-ops-bridge
make bootstrap
```

生成された `ops/xcode.env` を編集します。Xcode Projectの場合:

```sh
XCODE_WORKSPACE=""
XCODE_PROJECT="MyApp/MyApp.xcodeproj"
XCODE_SCHEME="MyApp"
```

Xcode Workspaceの場合:

```sh
XCODE_WORKSPACE="MyApp/MyApp.xcworkspace"
XCODE_PROJECT=""
XCODE_SCHEME="MyApp"
```

パスはすべて `xc-ops-bridge/` からの相対パスです。

### 3. 診断・ビルド・テスト

```bash
make doctor
make build
make test
```

`make doctor` は `ops/xcode.env` で選択したproject/workspace、scheme、destinationを表示し、
その対象を実際にbuild/testします。テストtargetがない場合は警告として表示します。
Xcodeプロジェクトをまだ配置していないデフォルト設定では、同梱の `HelloWorld` が対象です。

- ※ Xcodeを開きたい場合は `make open` で開けます。

`make doctor` はXcodeの選択先、バージョン、ライセンス、SDK、Simulator runtimeを確認し、
最後に設定対象を `xcodebuild` で実際にbuild/testします。診断ログと生成物は
`.local/doctor/` に隔離されます。shared schemeに有効な秘密情報らしい環境変数がある場合は、
値を表示せず警告します。

GitHub Actionsはpush/PRに加えて、手動実行と毎週月曜09:00（日本時間）の定期確認に対応します。
Xcode更新そのものはフックせず、更新後に同じ `doctor` を実行して互換性を確認します。

## AIエディタ / 拡張機能のおすすめ
- **VS Code**: 拡張機能 **"Swift" (sswg.swift)** を推奨します。
- **Windsurf / Cursor**: Xcodeの代わりとして強力なAI支援を受けつつ、補完はLSP経由で動作します。
- **Antigravity**: Agentに直接依頼してリファクタリング等の自動化が可能です。

## 絶対NG（システムでブロックされます）
以下の操作はリポジトリ破壊を防ぐため、Gitフック（`pre-commit`）により自動的にコミットがブロックされます。
- `.local/` / `DerivedData/` / `*.xcresult` のコミット
- 個人設定（xcuserdata 等）のコミット
- エージェントに対する破壊的コマンド（`rm -rf`, `git push` 等）の許可

## Docs
- **Start Here**: [docs/WALKTHROUGH.md](docs/WALKTHROUGH.md)
- **English README**: [README_EN.md](README_EN.md)
- Editors: [docs/EDITORS.md](docs/EDITORS.md)
- Xcode setup: [docs/XCODE_SETUP.md](docs/XCODE_SETUP.md)
- Development: [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)
