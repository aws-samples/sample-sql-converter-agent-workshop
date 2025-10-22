## プロジェクト概要

本ディレクトリにはOracleデータベースを使用した従業員情報の管理（登録、更新、削除、検索）を行うSpring + MyBatisアプリケーションの基盤となるスクリプト群が含まれています。

> **注意**: サンプルのためにコアファイルのみが存在する状態なので、実際に動作させるには、Spring周りの設定やビルド設定、適切なディレクトリ構造の見直しなど、実装する必要があります。

## ファイル構成

### データベース関連
- **oracle_schema.sql** - Oracleデータベースのテーブル定義（departments、employeesテーブル等）

### MyBatis設定
- **mybatis-config.xml** - MyBatisの設定ファイル（Oracle用設定、キャメルケース変換、タイムアウト設定等）
- **EmployeeMapper.xml** - SQLマッピング定義（動的検索クエリ、CRUD操作）

### Javaクラス
- **Employee.java** - 従業員エンティティクラス（ID、名前、メール、給与、部署ID等のプロパティ）
- **EmployeeDao.java** - データアクセス層インターフェース（MyBatisマッパー）
- **EmployeeService.java** - ビジネスロジック層（トランザクション管理付き）
- **EmployeeSearchCriteria.java** - 検索条件を格納するDTOクラス（名前、給与範囲、部署、ソート条件等）

## 主な特徴

### 1. Oracle固有機能を含む複雑な構造
- SEQUENCE（employee_seq.NEXTVAL）
- ROWNUM によるページネーション
- CONNECT BY による階層クエリ
- PIVOT操作
- ウィンドウ関数（RANK, LAG, LEAD）
- SYSDATE関数

### 2. 複雑なクエリパターン
- 動的SQL（MyBatis XMLマッパー）
- 複数テーブルJOIN
- 集計・統計クエリ
- 条件付きソート・ページネーション

### 3. PostgreSQL変換が必要な要素
- SEQUENCE.NEXTVAL → nextval('sequence_name')
- ROWNUM → ROW_NUMBER() OVER()
- SYSDATE → CURRENT_TIMESTAMP
- CONNECT BY → 再帰CTE
- DUAL → 削除
- VARCHAR2 → VARCHAR
- NUMBER → NUMERIC


