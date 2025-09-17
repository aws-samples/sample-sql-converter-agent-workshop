# CDK TypeScript プロジェクト

このプロジェクトは TypeScript を使用した CDK 開発用のプロジェクトです。

`cdk.json` ファイルは CDK Toolkit がこのアプリケーションをどのように実行するかを定義しています。

## 使用可能なコマンド

* `npm run build`   TypeScript を JavaScript にコンパイル
* `npm run watch`   ファイルの変更を監視し、自動的にコンパイル
* `npm run test`    Jest を使用したユニットテストの実行
* `npx cdk deploy`  デフォルトの AWS アカウント/リージョンにスタックをデプロイ
* `npx cdk diff`    デプロイされているスタックと現在の状態を比較
* `npx cdk synth`   CloudFormation テンプレートを生成

## プロジェクトの構造

```
.
├── bin/          # CDKアプリケーションのエントリーポイント
├── lib/          # スタックの定義やコンストラクトの実装
├── test/         # テストコード
└── cdk.json      # CDK設定ファイル
```

## 開発の始め方

1. 必要な依存関係をインストール:
   ```bash
   npm install
   ```

2. TypeScript のコンパイル:
   ```bash
   npm run build
   ```

3. CDK スタックのデプロイ:
   ```bash
   npx cdk deploy
   ```
