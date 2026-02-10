# xc-ops-bridge

好きなエディタ（Antigravity / VSCode / Zed / JetBrains / nvim / Emacs）で Swift を編集し、
ビルド/テストは Xcode（xcodebuild）に統一するための運用キット。

## コンセプト（破綻しないための約束）
- **編集は自由**：どのエディタでもOK
- **実行は統一**：ビルド/テストは必ず `ops/xc` （または `make`）から
- 生成物は `.local/` に隔離（コミット禁止）
- 設定の唯一の真実は `ops/xcode.env`

## 前提条件 (Prerequisites)
- **Xcode Project**: `.xcodeproj` または `.xcworkspace` が必要です。
  - プロジェクトが無い場合は `make build` が動きません。
  - 本リポジトリには検証用の `HelloWorld/` パッケージが含まれており、すぐに動作確認できます。

## Quickstart
```bash
make bootstrap
# ops/xcode.env を自分のプロジェクト（またはHelloWorld）に合わせて編集
make doctor
make build
make test
```

## 絶対NG（これを破ると運用が死ぬ）
- `xcodebuild` を手で直叩きして手順が分岐する（必ず `ops/xc` 経由）
- `.local/` / `DerivedData/` / `*.xcresult` をコミットする
- 個人設定（xcuserdata 等）をコミットする
- エージェントに `rm -rf` / `git push` / `git tag` を許可する

## Docs
- **Start Here**: [docs/WALKTHROUGH.md](docs/WALKTHROUGH.md)
- **English README**: [README_EN.md](README_EN.md)
- Editors: [docs/EDITORS.md](docs/EDITORS.md)
- Xcode setup: [docs/XCODE_SETUP.md](docs/XCODE_SETUP.md)
- Development: [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)
