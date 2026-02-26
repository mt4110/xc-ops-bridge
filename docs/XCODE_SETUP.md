# Xcode Setup（ツールチェーンとしての準備）

このプロジェクトでは、Xcodeは **「IDE」としてだけでなく「コンパイラ＆SDK提供元」** として機能します。

## 1. インストール

Xcodeがインストールされていない場合は、以下のいずれかでインストールしてください：
- **App Store**: [Mac App Store: Xcode](macappstore://itunes.apple.com/app/id497799835) からインストール
- **Xcodes**: コマンドラインやサードパーティツールでのバージョン管理

## 2. ライセンス同意（必須）

一度起動するか、コマンドで同意しないと `xcodebuild` が動きません。

```bash
sudo xcodebuild -license
```

## 3. Command Line Tools (CLT)

動作安定のために必須です。

```bash
xcode-select --install
```

## 4. 診断

セットアップが終わったら、プロジェクトルートで以下を叩いてください。

```bash
make doctor
```

これで `xcodebuild`, `swiftc`, `sourcekit-lsp` が全部 OK なら準備完了です。
