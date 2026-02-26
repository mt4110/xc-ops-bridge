# xc-ops-bridge Walkthrough (Swift Dev / IDE-agnostic)

このリポジトリのゴールはシンプルです。

- **どのエディタ/IDEでSwiftを書いてもOK**
- ただし最終的に **CLI（ops/xc）で clean/build/test が再現**できること
- **CLIが真実**。CLIを基準とすることで、チームやAIエージェントの自動化体験が向上します。
- プロジェクトは `.xcodeproj`、`.xcworkspace`、純粋な `Package.swift` のどれでも動作します。

---

## 0. Quickstart

~~~bash
make bootstrap
make doctor
make build
~~~

Make を使わない場合:

~~~bash
bash ops/xc doctor
bash ops/xc build
~~~

---

## 1. ローカル設定: ops/xcode.env が最重要

- Gitに入れる: `ops/xcode.env.example`（テンプレ）
- Gitに入れない: `ops/xcode.env`（ローカル専用 / `.gitignore` 済み）

`ops/xcode.env` を消していい？ → **消してOK**。復旧はこれ:

~~~bash
rm -f ops/xcode.env
make bootstrap
~~~

もし事故でGitが追跡していたら:

~~~bash
git ls-files ops/xcode.env
# 出てきたら追跡解除
git rm --cached ops/xcode.env
git commit -m "chore: stop tracking ops/xcode.env (local only)"
~~~

---

## 2. destination を固定する（ログ静音化の主犯対策）

Xcodeは macOS の destination が複数見つかると警告を出しがちです。
このリポでは **macOS/arm64 をデフォルト**にして、PRレビューを静かにします。

例（arm64固定）:

~~~bash
bash ops/xc build -destination "platform=macOS,arch=arm64"
~~~

x86_64 が必要な場合:

~~~bash
bash ops/xc build -destination "platform=macOS,arch=x86_64"
~~~

iOS（例）:

~~~bash
bash ops/xc build -destination "platform=iOS Simulator,name=iPhone 16,OS=latest"
~~~

---

## 3. よくあるノイズと対処（Detect + Guide）

### 3.1 WARNING: Using the first of multiple matching destinations
→ destination を固定（arm64）で解決。

### 3.2 warning: no rule to process file .../.gitignore
`.gitignore` が Xcode Target（Resources等）に混入している時に出ます。

**対処（手作業推奨）**:
1. Xcode → Project Navigator で `.gitignore` を選択
2. File Inspector → **Target Membership のチェックを外す**

`.pbxproj` の自動編集は破損リスクが高いので、このリポではやりません。

### 3.3 MainActor 関連の警告（例: SettingsViewModel）
よくある方針:
- `SettingsViewModel` を `@MainActor` にする
- `throw` しない `do { } catch { }` の catch は削除してよい（到達不能ならノイズ）

Doctor は “検知とガイド” まで。自動修正はしません。

---

## 4. トラブルシュート最小ループ（最短で原因へ）

~~~bash
make doctor
bash ops/xc clean
bash ops/xc build -destination "platform=macOS,arch=arm64" | tee .local/build.log
tail -n 120 .local/build.log
~~~

---

## 5. このリポの「破綻しない約束」
- `ops/xcode.env` はローカル用（Git追跡しない）
- `ops/xc` で再現できれば勝ち（IDEは自由）
- Doctor は read-only（Detect + Guide）
- destination 固定でログを静音化し、PRレビューをラクにする
