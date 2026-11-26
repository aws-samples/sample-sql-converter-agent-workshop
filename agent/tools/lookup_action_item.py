"""Look up an Action Item (AWS SCT / DMS Schema Conversion) by its 4-5 digit identifier.

Source of truth: the bundled
``resources/action_items_oracle_to_postgresql.json`` catalogue, which
mirrors the Action Items that AWS SCT and DMS Schema Conversion report
for Oracle to PostgreSQL / Aurora PostgreSQL (both tools use the same
numbers, e.g. 5030, 5605).

Deterministic — no file I/O beyond the single JSON load that
happens on first call.

Returns the six user-visible fields keyed by the same column names
the SCT Assessment Report CSV uses, so a reviewer can match a row
from their own CSV to the catalogue entry one-to-one.

Example::

    lookup_action_item("5034") ==> {
        "action_item": "5034",
        "description": "PostgreSQL doesn't support transaction control ...",
        "recommended_action": "PostgreSQL supports transaction control ...",
        "documentation_references": "https://www.postgresql.org/.../plpgsql-transactions.html",
        "learning_curve_efforts": 0.1,
        "efforts_to_convert_an_occurrence_of_the_action_item": 0.1,
    }

Unknown IDs raise ``ValueError`` rather than silently returning
``None`` — callers should not confuse "no such Action Item" with
"Action Item exists but has empty fields".
"""
from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path


_CATALOGUE_FILENAME = 'action_items_oracle_to_postgresql.json'


@lru_cache(maxsize=1)
def _catalogue() -> dict[str, dict]:
    """Load + index the catalogue on first call; cache for the
    process lifetime. Keyed by action_item string for O(1) lookup."""
    here = Path(__file__).resolve().parent
    path = here / 'resources' / _CATALOGUE_FILENAME
    with open(path, encoding='utf-8') as f:
        payload = json.load(f)
    return {item['action_item']: item for item in payload['action_items']}


def lookup_action_item(action_item: str) -> dict:
    """Return the catalogue entry for the given Action Item ID.

    Args:
        action_item: The identifier string (e.g. ``"5034"``,
            ``"9996"``). Leading / trailing whitespace is stripped.
            Numeric ints are accepted and coerced to string.

    Returns:
        Dict with six keys matching the SCT Assessment Report CSV
        columns: ``action_item``, ``description``,
        ``recommended_action``, ``documentation_references``,
        ``learning_curve_efforts``,
        ``efforts_to_convert_an_occurrence_of_the_action_item``.

    Raises:
        ValueError: The action_item is not present in the catalogue.
    """
    key = str(action_item).strip()
    catalogue = _catalogue()
    if key not in catalogue:
        raise ValueError(
            f'unknown action_item: {action_item!r} '
            f'(catalogue has {len(catalogue)} entries; typical range '
            f'5024 .. 30415)'
        )
    # Return a shallow copy so callers can mutate freely.
    return dict(catalogue[key])
