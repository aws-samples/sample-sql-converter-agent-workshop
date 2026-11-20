# SCAW2.0 Agent

Kiro CLI エージェント定義とMCPツールサーバー（変換エンジン刷新版）。

- `mcpserver/` — Oracle/PostgreSQL接続用MCPサーバー（SCAW1.0から再利用）
- `tools/` — convertフェーズ用MCPツールサーバー（決定的処理のみ、LLMは呼ばない）
- `skills/` — エージェントが参照するSkill Markdown
- `kiro/` — Kiroエージェント定義（worker-db, worker-app, batch系）
- `scripts/install-agents.sh` — エージェント定義をKiro CLIに登録するスクリプト

使い方はリポジトリ直下の `README.md` を参照してください。
