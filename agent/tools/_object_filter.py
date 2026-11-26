"""Helpers shared by parse_sct_converted_sql / parse_dms_sc_converted_sql.

大きい converted.sql（数十MB、数千オブジェクト）を扱う際に、MCP応答が
巨大になって MCP サーバー（stdio）がクラッシュするのを防ぐための処理。

- ``matches_object_name``: 対象オブジェクト名でブロックを絞り込む
- ``fit_inline_payload``: inline 応答が上限サイズを超える場合に、段階的に
  内容を縮小する（code を省略 → 一覧も省略して件数のみ）
"""
from __future__ import annotations

import json
from typing import Callable

# inline 応答の上限サイズ（バイト）。これを超える応答は返さない。
# MCPサーバーのクラッシュ防止に加え、エージェントのコンテキストを圧迫
# しないための上限（100KBのJSONでも数万トークン相当になる）。
INLINE_MAX_BYTES = 100_000


def _normalize(name: str) -> str:
    return name.strip().replace('"', '').lower()


def matches_object_name(name: str, target: str) -> bool:
    """``name``（split_objects が返す小文字の修飾名）が ``target`` に一致するか。

    大文字小文字・二重引用符は区別しない。``target`` にスキーマ接頭辞が
    ない場合（例: ``PROC_A``）は、``name`` のスキーマを除いた部分と比較する。
    """
    n = _normalize(name)
    t = _normalize(target)
    if not t:
        return False
    if n == t:
        return True
    if '.' not in t and n.rsplit('.', 1)[-1] == t:
        return True
    return False


def payload_size(payload: dict) -> int:
    return len(json.dumps(payload, ensure_ascii=False).encode('utf-8'))


def fit_inline_payload(
    objects: list[dict],
    summary: dict,
    *,
    tool_name: str,
    slim_keys: tuple[str, ...],
    narrow: Callable[[dict], bool] | None = None,
    narrow_label: str = '',
) -> dict:
    """inline 応答を INLINE_MAX_BYTES 以内に収める。

    1. そのまま収まれば ``{"objects": objects, "summary": summary}`` を返す。
    2. 収まらなければ、各オブジェクトを ``slim_keys`` のキーだけに絞った一覧
       （code なし）を返し、``code_omitted: True`` と案内を付ける。
    3. それでも収まらず ``narrow`` が指定されていれば、``narrow`` が True を
       返すオブジェクトだけに絞った一覧を返す（``listed`` に ``narrow_label``）。
    4. それでも収まらなければ一覧も省略し、summary と案内だけを返す。
    """
    full = {'objects': objects, 'summary': summary}
    if payload_size(full) <= INLINE_MAX_BYTES:
        return full

    hint = (
        f'応答が大きすぎるため code を省略しました。対象オブジェクトの '
        f'ブロックを取得するには、{tool_name} を object_name 引数付きで '
        f'呼び直してください（ファイルを手動で分割する必要はありません）。'
    )
    slim = [{k: o[k] for k in slim_keys if k in o} for o in objects]
    slim_payload = {
        'objects': slim,
        'summary': summary,
        'code_omitted': True,
        'listed': 'all',
        'hint': hint,
    }
    if payload_size(slim_payload) <= INLINE_MAX_BYTES:
        return slim_payload

    if narrow is not None:
        narrowed = [s for s, o in zip(slim, objects) if narrow(o)]
        narrowed_payload = {
            'objects': narrowed,
            'summary': summary,
            'code_omitted': True,
            'listed': narrow_label,
            'hint': hint + f'（件数が多いため、一覧は {narrow_label} のみ）',
        }
        if payload_size(narrowed_payload) <= INLINE_MAX_BYTES:
            return narrowed_payload

    return {
        'summary': summary,
        'code_omitted': True,
        'objects_omitted': True,
        'hint': (
            'オブジェクト数が多すぎるため一覧も省略しました。対象オブジェクト'
            f'が決まっている場合は {tool_name} を object_name 引数付きで、'
            '一覧が必要な場合は inline=False と out_dir を指定して呼んで'
            'ください（キャッシュファイルは大きくなるため fs_read で直接'
            '読まないこと）。'
        ),
    }
