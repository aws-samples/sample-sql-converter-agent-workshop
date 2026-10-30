"""Parse AWS SCT assessment CSVs and compute per-object effort.

Deterministic — no LLM.
"""
import csv
import json
import os
import re
from collections import defaultdict

from resolve_report_filename import resolve_report_path


_CHILD_KEYWORDS = {
    'Parameters', 'Constraints', 'Indexes', 'Triggers',
    'Columns', 'Partitions', 'Subpartitions',
}


def _normalize_parent(parts: list[str]) -> list[str]:
    result = []
    for p in parts:
        if p in _CHILD_KEYWORDS:
            break
        result.append(p)
    return result


def _occurrence_to_converted_name(occurrence: str) -> tuple[str, str]:
    """Convert SCT ``Occurrence`` path to ``(converted_name, parent_key)``.

    ``parent_key`` is used to group child elements (Parameters,
    Constraints, …) under the parent object.
    """
    parts = occurrence.split('.')
    if len(parts) < 4:
        return None, occurrence

    schema = parts[1]
    type_seg = parts[2]
    parent_parts = _normalize_parent(parts)
    parent_key = '.'.join(parent_parts)

    if type_seg == 'Packages' and len(parent_parts) >= 6:
        pkg = parts[3]
        proc_raw = parts[5] if len(parts) > 5 else parts[4]
        proc = re.sub(r'\$\d+$', '', proc_raw)
        return (f'{schema}.{pkg}${proc}'.lower(),
                f'Schemas.{schema}.Packages.{pkg}')

    if type_seg in ('Tables', 'Procedures'):
        if len(parts) > 4 and parts[4] in _CHILD_KEYWORDS:
            name = parts[3]
            return (f'{schema}.{name}'.lower(),
                    f'Schemas.{schema}.{type_seg}.{name}')
        return f'{schema}.{parts[3]}'.lower(), parent_key

    if type_seg in (
        'Functions', 'Views', 'User Defined Types', 'Sequences',
        'Materialized View Logs', 'Database Links', 'Clusters',
        'External Tables', 'Synonyms',
    ):
        return f'{schema}.{parts[3]}'.lower(), parent_key

    obj_name = parts[3] if len(parts) > 3 else parts[-1]
    return f'{schema}.{obj_name}'.lower(), parent_key


def _parse_summary_csv(path: str) -> dict:
    summary = {}
    with open(path, encoding='utf-8-sig', newline='') as f:
        for row in csv.DictReader(f):
            aid = row['Action item'].strip()
            summary[aid] = {
                'total_occurrences': int(row['Number of occurrences']),
                'learning_curve': float(row['Learning curve efforts']),
                'effort_per_occurrence': float(
                    row['Efforts to convert an occurrence of the action item']
                ),
                'description': row.get('Action item description', ''),
                'recommended_action': row.get('Recommended action', ''),
            }
    return summary


def _parse_detail_csv(path: str) -> list[dict]:
    rows = []
    with open(path, encoding='utf-8-sig', newline='') as f:
        for row in csv.DictReader(f):
            rows.append({
                'category': row['Category'].strip(),
                'occurrence': row['Occurrence'].strip(),
                'action_item_id': row['Action item'].strip(),
                'subject': row.get('Subject', '').strip(),
                'description': row.get('Description', '').strip(),
                'recommended_action': row.get('Recommended action', '').strip(),
                'complexity': row.get('Estimated complexity', '').strip(),
                'line': row.get('Line', '').strip(),
                'position': row.get('Position', '').strip(),
                'schema_name': (row.get('Schema name') or '').strip(),
            })
    return rows


def parse_sct_csv(
    detail_csv: str,
    summary_csv: str,
    *,
    inline: bool = True,
    out_dir: str | None = None,
) -> dict:
    """Parse SCT detail + summary CSVs and aggregate per-object effort.

    Args:
        detail_csv: Path to SCT "Action Items Detail" CSV.
        summary_csv: Path to SCT "Action Items Summary" CSV.
        inline: When True (default), the full ``records`` array is
            returned in the response. When False, ``records`` is
            written to a cache file and the response returns only
            ``cache_path`` + ``summary``.
        out_dir: Required when ``inline=False``.

    Returns a dict with:
        records: (inline=True only) list of per-(object,
                 action_item) records (converted_name, category,
                 action_item_id, description, recommended_action,
                 complexity, occurrences_in_object,
                 learning_curve_prorated, conversion_effort,
                 subtotal_hours)
        cache_path: (inline=False only) absolute path to the
                    written cache JSON.
        summary: aggregate counts (unique_action_items,
                 total_occurrences, objects, total_hours).

    Raises:
        ValueError: ``inline=False`` without ``out_dir``.
    """
    if not inline and not out_dir:
        raise ValueError(
            'parse_sct_csv: inline=False requires out_dir. '
            'Resolve the output directory first (confirm with the '
            'user if not specified) and pass it as out_dir.'
        )

    summary_map = _parse_summary_csv(summary_csv)
    detail_rows = _parse_detail_csv(detail_csv)

    obj_actions: dict[tuple[str, str], dict] = defaultdict(lambda: {
        'converted_name': None, 'category': None,
        'action_item_id': None, 'description': None,
        'recommended_action': None, 'complexity': None, 'count': 0,
    })
    for row in detail_rows:
        converted_name, parent_key = _occurrence_to_converted_name(
            row['occurrence']
        )
        entry = obj_actions[(parent_key, row['action_item_id'])]
        entry['converted_name'] = converted_name
        entry['category'] = row['category']
        entry['action_item_id'] = row['action_item_id']
        entry['description'] = row['description']
        entry['recommended_action'] = row.get('recommended_action', '')
        entry['complexity'] = row['complexity']
        entry['count'] += 1

    records = []
    for (parent_key, aid), entry in sorted(obj_actions.items()):
        s = summary_map.get(aid)
        if s:
            lc_prorated = s['learning_curve'] / (s['total_occurrences'] or 1)
            conv_effort = s['effort_per_occurrence'] * entry['count']
            desc = entry['description'] or s['description']
            rec = entry['recommended_action'] or s['recommended_action']
        else:
            lc_prorated = 0.0
            conv_effort = 0.0
            desc = entry['description']
            rec = entry['recommended_action']

        records.append({
            'converted_name': entry['converted_name'] or parent_key,
            'category': entry['category'],
            'action_item_id': entry['action_item_id'],
            'description': desc,
            'recommended_action': rec,
            'complexity': entry['complexity'],
            'occurrences_in_object': entry['count'],
            'learning_curve_prorated': round(lc_prorated, 3),
            'conversion_effort': round(conv_effort, 3),
            'subtotal_hours': round(lc_prorated + conv_effort, 3),
        })

    objects = {r['converted_name'] for r in records}
    summary = {
        'unique_action_items': len(summary_map),
        'total_occurrences': len(detail_rows),
        'objects': len(objects),
        'total_hours': round(
            sum(r['subtotal_hours'] for r in records), 3
        ),
    }
    if inline:
        return {'records': records, 'summary': summary}

    payload = {'records': records, 'summary': summary}
    cache_path = resolve_report_path(out_dir, 'parse_sct_csv_cache')
    sct_path = resolve_report_path(out_dir, 'sct_assessment_json')
    os.makedirs(os.path.dirname(cache_path), exist_ok=True)
    os.makedirs(os.path.dirname(sct_path), exist_ok=True)
    with open(cache_path, 'w', encoding='utf-8') as f:
        json.dump(payload, f)
    with open(sct_path, 'w', encoding='utf-8') as f:
        json.dump(payload, f, indent=2)
    return {
        'cache_path': cache_path,
        'sct_assessment_path': sct_path,
        'summary': summary,
    }
