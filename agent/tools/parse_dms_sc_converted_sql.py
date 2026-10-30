"""Split an AWS DMS Schema Conversion (DMS SC) ``converted.sql`` file
into per-object CREATE blocks, and flag objects with inline Action
Item markers.

AWS DMS Schema Conversion（DMS SC）が S3 に出力する変換済み SQL は、
AWS SCT 単体ツールの ``converted.sql``（``parse_sct_converted_sql``
が対象）とはファイル構造が異なる:

- オブジェクトはマーカーコメントで区切られるのではなく、
  ``-- ------------ Write CREATE-XXX-stage scripts -----------``
  というステージ見出しでグルーピングされ、各ステージ内に複数オブジェクト
  の ``CREATE OR REPLACE ...`` 文が連続して並ぶ。
- 変換できなかった箇所は、オブジェクト全体の欠落ではなく、
  ``/* [<Action Item番号> - Severity <重大度> - <説明>] */`` という
  **行内インラインコメント**として、そのオブジェクトの CREATE 文の中に
  埋め込まれる（オブジェクト自体はほぼ変換済みの状態で出力される）。

実機で DMS Schema Conversion の Assess/Convert を実行して確かめた結果、
既存の ``code_splitter.split_objects`` が持つ
``_CREATE_BLOCK_RE`` の先読みパターンには、すでに
``-- ---- Write ...`` 見出しが区切り文字として含まれていたため、
オブジェクト分割自体は変更なしで DMS SC 出力にも正しく機能することを
確認済み（309オブジェクトへの分割、Action Item付きオブジェクトの
抽出を確認）。したがって本モジュールは ``split_objects`` をそのまま
再利用し、追加で必要な「各ブロック内のインライン Action Item 検出」
のみを実装する薄いラッパーである。``parse_sct_converted_sql``
は変更しない（別関数として並存させる）。

Deterministic — no LLM.
"""
import json
import os
import re

from _object_filter import fit_inline_payload, matches_object_name
from code_splitter import split_objects
from resolve_report_filename import resolve_report_path


# Matches DMS SC's inline Action Item marker, e.g.:
#   [5035 - Severity CRITICAL - Your code ends a transaction ...]
_ACTION_ITEM_RE = re.compile(
    r'\[(\d+)\s*-\s*Severity\s+(\w+)\s*-\s*([^\]]*)\]',
    re.IGNORECASE,
)


def _find_action_items(code: str) -> list[dict]:
    """Extract every inline Action Item marker from one object's code.

    Returns a list of ``{"action_item_id", "severity", "description"}``
    dicts, in the order they appear in the block. A given Action Item
    id may repeat (DMS SC often annotates both a commented-out
    statement and its context, e.g. a COMMIT inside a BEGIN block and
    the matching ROLLBACK inside the EXCEPTION handler).
    """
    items = []
    for m in _ACTION_ITEM_RE.finditer(code):
        items.append({
            'action_item_id': m.group(1),
            'severity': m.group(2).strip().upper(),
            'description': m.group(3).strip(),
        })
    return items


def parse_dms_sc_converted_sql(
    sql_path: str,
    *,
    inline: bool = True,
    out_dir: str | None = None,
    object_name: str | None = None,
) -> dict:
    """Parse a DMS Schema Conversion ``converted.sql``-equivalent file.

    Splits the file into per-object CREATE blocks (reusing
    ``code_splitter.split_objects`` unchanged) and, for each
    object, detects DMS SC's inline Action Item markers
    (``/* [<id> - Severity ... - ...] */``).

    Each returned object is tagged with a ``status``:

    - ``"action_items"``: the block contains one or more inline
      Action Item markers — DMS SC could not fully convert this
      object and left commented-out Oracle code plus a note. Whether
      to redo the whole object or patch just the flagged lines is a
      judgment call for the agent (not a fixed rule here — see the
      workflow-db-convert skill).
    - ``"converted"``: no markers found — DMS SC converted the
      object without flagging any issue.

    Args:
        sql_path: Absolute path to the DMS SC converted ``.sql`` file
            (already downloaded locally — this function does not
            fetch from S3; downloading from S3 is done beforehand with
            the ``download_s3_input`` tool).
        inline: When True (default), the full ``objects`` array (with
            per-object DDL text and detected action items) is
            returned in the response. When False, ``objects`` is
            written to ``<out_dir>/.cache/parse_dms_sc_converted_sql.json``
            and the response returns only ``cache_path`` + ``summary``.
        out_dir: Required when ``inline=False``.
        object_name: 対象オブジェクト名（例: ``SCHEMA.PROC_A`` または
            ``PROC_A``）。指定すると、一致したオブジェクトのブロックだけを
            code付きで返す（大きいファイルでも応答は小さい）。``inline``は
            無視される。大きいファイルから1オブジェクトを取り出す場合は
            必ずこれを使う。

    Returns:
        ``object_name``指定時: ``{"objects": [一致したもの], "summary":
        {"count": 全体件数, "with_action_items": int, "matched": int}}``。
        ``inline=True`` (default): ``{"objects": [{name, code,
        status, action_items}, ...], "summary": {"count": int,
        "with_action_items": int}}``。応答が上限サイズ
        （``_object_filter.INLINE_MAX_BYTES``）を超える場合は code を
        省略した一覧（``code_omitted: True``）、さらに超える場合は
        summary のみを返す。
        ``inline=False``: ``{"cache_path": str, "summary": {...}}``.

    Raises:
        ValueError: ``inline=False`` without ``out_dir``.
    """
    if object_name is None and not inline and not out_dir:
        raise ValueError(
            'parse_dms_sc_converted_sql: inline=False requires out_dir. '
            'Resolve the output directory first (confirm with the '
            'user if not specified) and pass it as out_dir.'
        )

    objects = split_objects(sql_path)
    objects_payload = []
    with_action_items = 0
    for o in objects:
        action_items = _find_action_items(o.code)
        status = 'action_items' if action_items else 'converted'
        if action_items:
            with_action_items += 1
        objects_payload.append({
            'name': o.name,
            'code': o.code,
            'status': status,
            'action_items': action_items,
            'action_item_ids': sorted({a['action_item_id'] for a in action_items}),
        })

    summary = {
        'count': len(objects_payload),
        'with_action_items': with_action_items,
    }

    if object_name is not None:
        matched = [o for o in objects_payload
                   if matches_object_name(o['name'], object_name)]
        return {'objects': matched,
                'summary': {**summary, 'matched': len(matched)}}

    if inline:
        return fit_inline_payload(
            objects_payload, summary,
            tool_name='parse_dms_sc_converted_sql',
            slim_keys=('name', 'status', 'action_item_ids'),
            narrow=lambda o: o['status'] == 'action_items',
            narrow_label='action_items（Action Item付き）のオブジェクト',
        )

    cache_path = resolve_report_path(
        out_dir, 'parse_dms_sc_converted_sql_cache'
    )
    os.makedirs(os.path.dirname(cache_path), exist_ok=True)
    with open(cache_path, 'w', encoding='utf-8') as f:
        json.dump({'objects': objects_payload, 'summary': summary}, f)
    return {'cache_path': cache_path, 'summary': summary}
