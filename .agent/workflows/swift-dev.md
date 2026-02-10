# Swift Dev Workflow

## 目的
- 編集は自由。実行は統一（./ops/xc）。

## ルール
- 変更後は必ず \`./ops/xc test\`
- 失敗時はログを貼って原因を1つずつ潰す
- \`xcodebuild\` の直叩きは禁止（再現性が死ぬ）
- 危険コマンドは禁止（rm -rf / git push / git tag）
