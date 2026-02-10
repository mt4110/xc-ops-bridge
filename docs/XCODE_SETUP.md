# Xcode Setup（ツールチェーンとしての準備）

このプロジェクトでは、Xcodeは **「IDE」というより「コンパイラ＆SDK提供元」** として必須です。

## 1. インストール
App Store から Xcode をインストールしてください。

## 2. ライセンス同意（必須）
一度起動するか、コマンドで同意しないと `xcodebuild` が動きません。
```bash
sudo xcodebuild -license
```

## 3. Command Line Tools (CLT)
必須ではありませんが、安定動作のために推奨されます。
```bash
xcode-select --install
```

## 4. 診断
セットアップが終わったら、プロジェクトルートで以下を叩いてください。
```bash
make doctor
```
これで `xcodebuild`, `swiftc`, `sourcekit-lsp` が全部 OK なら準備完了です。
