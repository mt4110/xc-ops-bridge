# Development Flow（止まらない運用）

**「迷ったら `make doctor`」** これだけ覚えてください。

## 最短ルート（Shortest Path）
1. **初期化**: `make bootstrap`
2. **診断**: `make doctor`（ここが通れば、どのエディタでも戦える）
3. **ビルド**: `make build`
4. **テスト**: `make test`

## 運用ルール
- **入口は `make` (または `ops/xc`) に統一する**
  - エディタのボタンに頼らず、コマンド一発で動く状態を正とします。
- **Xcode は「確認用」**
  - `make open` で開いて、プレビューやデバッグに使います。
  - 編集して保存したら、また `make test` で検証します。

## 困ったときは
- **ビルドエラー？**: `make doctor` を見てください。誘導が出ます。
- **ゴミが溜まった？**: `make clean` で `.local/` 内の生成物を消せます。
