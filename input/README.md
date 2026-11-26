# input

ご自身のデータで変換を試すときに、変換対象のファイルを置くディレクトリです。構成は `input-sample/` と同じです。

```
input/
├── application/          # app trackの変換対象（アプリケーションのソースコード）
└── db-object/
    └── assessment/       # db trackの入力（AWS SCT / AWS DMS Schema Conversionの出力）
```

- アプリケーションのソースコードが大きい場合は、ここにコピーせず、元の場所のパスをエージェントに指定しても構いません。
