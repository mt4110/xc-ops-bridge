# Editors（どの宗派でもOK）

「Swiftが書ける（補完・定義ジャンプ・診断が出る）」＝ **SourceKit-LSP が動くこと**。
これさえ満たせば、どのエディタでも開発可能です。

## VS Code
- 拡張機能 **"Swift" (sswg.swift)** を入れるだけ。
- 推奨設定は `.vscode/` に入っています。

## Zed
- 何もしなくても SourceKit-LSP を認識します。
- 必要なら `.sourcekit-lsp/config.json` をプロジェクトルートに置けます。

## Neovim / Emacs
- **SourceKit-LSP** をLSPクライアントから起動してください。
- パスは `xcrun -f sourcekit-lsp` で取れます（これが一番堅牢）。
- ビルドコマンドには `:!make build` や `M-x compile` (make build) を割り当てると快適です。

## Antigravity (Agent)
- 編集とリファクタリングを依頼してください。
- 実行は `make` コマンド経由で行うように指示済みです（`.agent/workflows` 参照）。
