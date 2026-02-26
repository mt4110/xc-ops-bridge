# xc-ops-bridge

好きなエディタ（Antigravity / VSCode / Zed / JetBrains / nvim / Emacs）で Swift を編集し、
ビルド/テストは Xcode（xcodebuild）に統一するための運用キット。

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
```bash
make bootstrap
# ops/xcode.env を自分のプロジェクト（またはHelloWorld）に合わせて編集
make doctor
make build
make test
```
- ※ Xcodeを開きたい場合は `make open` で開けます。

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
