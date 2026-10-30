"""Append a discovered conversion pattern to ``workshop-custom-rules/SKILL.md``.

前半の対話的変換のたびに、エージェントが発見した変換パターン
（Oracle構文→PostgreSQL構文のマッピング、注意点等）をこのツールで
草案として提示する。ツール自体は決定的（Markdown追記のみ）で、パターンの
内容そのもの（何を書くか）はエージェントが対話の中で判断し、テキストとして
渡す。参加者はエージェントが提示した内容をレビューし、承認 or 直接編集する
（この編集はエージェントの外、ユーザー自身による直接ファイル編集を想定）。
"""
from __future__ import annotations

import os
from datetime import datetime, timezone


_DEFAULT_TEMPLATE = """# Workshop Custom Rules

このファイルは、ワークショップ中の対話的変換で発見した
Oracle → PostgreSQL 変換パターンを蓄積する場所です。

前半（対話的変換）で見つかったパターンはここに追記され、後半（一括変換）
では最優先の参照ルールとして使われます。

このファイルは完全に編集可能です。参加者が直接書き換えて構いません。
またワークショップ終了後、実プロジェクトでこの仕組みを使い続ける場合、
このファイルと組み込みルール（domain-conversion-rules 等）の区分は
実質的に薄れ、両方とも自由に統合・再編集してよいものになります。

## 発見した変換パターン

"""


def _skill_path(project_root: str) -> str:
    return os.path.join(
        project_root, 'agent', 'skills', 'workshop-custom-rules', 'SKILL.md'
    )


def write_skill_draft(
    project_root: str,
    object_name: str,
    pattern_summary: str,
) -> dict:
    """Append a discovered pattern to ``workshop-custom-rules/SKILL.md``.

    Creates the file (from ``_DEFAULT_TEMPLATE``) if it does not exist
    yet — this is the expected state early in the workshop (初期
    状態は空/テンプレートのみ)。

    Args:
        project_root: Absolute path to the SCAW2.0 repository root.
        object_name: The object being converted when this pattern was
            found (for provenance in the appended entry).
        pattern_summary: Free-text description of the pattern, written
            by the agent (e.g. "NVL(a, b) を独自関数 CUSTOM_COALESCE に
            置き換える必要があった。理由: ..."). The tool does not
            interpret or validate this text — it is Markdown content
            supplied by the caller.

    Returns:
        dict with ``skill_path`` (absolute path) and ``created``
        (bool — True when the template was just created for the first
        time).
    """
    path = _skill_path(project_root)
    os.makedirs(os.path.dirname(path), exist_ok=True)

    created = not os.path.isfile(path)
    if created:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(_DEFAULT_TEMPLATE)

    timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')
    entry = (
        f"\n### {object_name} ({timestamp})\n\n"
        f"{pattern_summary.strip()}\n"
    )
    with open(path, 'a', encoding='utf-8') as f:
        f.write(entry)

    return {'skill_path': path, 'created': created}
