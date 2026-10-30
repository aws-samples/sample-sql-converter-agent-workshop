"""Split an SCT-converted ``.sql`` file into per-object CREATE blocks.

MCP-exposed wrapper around ``code_splitter``.
"""

import json
import os

from _object_filter import fit_inline_payload, matches_object_name
from code_splitter import split_objects
from resolve_report_filename import resolve_report_path


def parse_sct_converted_sql(
    sql_path: str,
    *,
    inline: bool = True,
    out_dir: str | None = None,
    object_name: str | None = None,
) -> dict:
    """Parse a SCT-produced ``converted.sql`` into per-object blocks.

    Deterministic — no LLM. The splitter recognises
    ``CREATE [OR REPLACE] TABLE / FUNCTION / PROCEDURE / VIEW /
    TRIGGER / SEQUENCE / DOMAIN / TYPE / SCHEMA`` statements,
    collapses multiple blocks with the same qualified name, and
    lowercases the ``name`` keys so they match
    :func:`parse_sct_csv`'s ``converted_name`` output.

    Args:
        sql_path: Absolute path to the converted ``.sql`` file.
        inline: When True (default), the full ``objects`` array
            (with per-object DDL text) is returned in the response.
            When False, ``objects`` is written to
            ``<out_dir>/.cache/parse_sct_converted_sql.json`` and
            the response returns only ``cache_path`` + ``summary``.
            Prefer ``inline=False`` in ad-hoc chat — a single
            object's ``code`` can be several KB.
        out_dir: Required when ``inline=False``.
        object_name: 対象オブジェクト名（例: ``SCHEMA.PROC_A`` または
            ``PROC_A``）。指定すると、一致したオブジェクトのブロックだけを
            返す（大きいファイルでも応答は小さい）。``inline``は無視される。

    Returns:
        ``object_name``指定時: ``{"objects": [一致したもの], "summary":
        {"count": 全体件数, "matched": int}}``。
        ``inline=True`` (default): ``{"objects": [{name, code}, ...],
        "summary": {"count": int}}``。応答が上限サイズを超える場合は
        code を省略した一覧（``code_omitted: True``）、さらに超える場合は
        summary のみを返す。
        ``inline=False``: ``{"cache_path": str, "summary":
        {"count": int}}``.

    Raises:
        ValueError: ``inline=False`` without ``out_dir``.
    """
    if object_name is None and not inline and not out_dir:
        raise ValueError(
            'parse_sct_converted_sql: inline=False requires out_dir. '
            'Resolve the output directory first (confirm with the '
            'user if not specified) and pass it as out_dir.'
        )

    objects = split_objects(sql_path)
    objects_payload = [
        {'name': o.name, 'code': o.code} for o in objects
    ]
    summary = {'count': len(objects)}

    if object_name is not None:
        matched = [o for o in objects_payload
                   if matches_object_name(o['name'], object_name)]
        return {'objects': matched,
                'summary': {**summary, 'matched': len(matched)}}

    if inline:
        return fit_inline_payload(
            objects_payload, summary,
            tool_name='parse_sct_converted_sql',
            slim_keys=('name',),
        )

    cache_path = resolve_report_path(
        out_dir, 'parse_sct_converted_sql_cache'
    )
    os.makedirs(os.path.dirname(cache_path), exist_ok=True)
    with open(cache_path, 'w', encoding='utf-8') as f:
        json.dump({'objects': objects_payload, 'summary': summary}, f)
    return {'cache_path': cache_path, 'summary': summary}
