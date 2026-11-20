"""SCAW2.0 convert-phase MCP tool server.

Exposes the SCAW2.0 MCP tools via FastMCP.

Run:
    uv run server.py
"""
import json
import sys
from pathlib import Path

# Allow flat, non-packaged imports between the tool modules in this
# directory (mirrors the pattern used by agent/mcpserver/server.py).
sys.path.append(str(Path(__file__).resolve().parent))

from mcp.server.fastmcp import FastMCP

from parse_sct_csv import parse_sct_csv as _parse_sct_csv
from download_s3_input import download_s3_input as _download_s3_input
from parse_sct_converted_sql import (
    parse_sct_converted_sql as _parse_sct_converted_sql,
)
from parse_dms_sc_converted_sql import (
    parse_dms_sc_converted_sql as _parse_dms_sc_converted_sql,
)
from convert_oracle_sql_rules import (
    convert_oracle_sql_rules as _convert_oracle_sql_rules,
)
from validate_pg_sql import validate_pg_sql as _validate_pg_sql
from validate_bind_integrity import (
    validate_bind_integrity as _validate_bind_integrity,
)
from scan_for_sql_files import scan_for_sql_files as _scan_for_sql_files
from detect_xml_sql import detect_xml_sql as _detect_xml_sql
from detect_proc_sql import detect_proc_sql as _detect_proc_sql
from detect_sql_by_opengrep import (
    detect_sql_by_opengrep as _detect_sql_by_opengrep,
    scan_files_opengrep as _scan_files_opengrep,
)
from detect_properties_sql import detect_properties_sql as _detect_properties_sql
from detect_sql_file import detect_sql_file as _detect_sql_file
from lookup_action_item import lookup_action_item as _lookup_action_item
from validate_ecpg import validate_ecpg as _validate_ecpg
from write_app_convert_outputs import (
    write_app_convert_outputs as _write_app_convert_outputs,
)
from write_db_result import (
    write_db_result as _write_db_result,
    list_converted_objects as _list_converted_objects,
)
from write_skill_draft import write_skill_draft as _write_skill_draft
from load_custom_rules import (
    load_custom_rules as _load_custom_rules,
    format_custom_rules_for_prompt as _format_custom_rules_for_prompt,
)

mcp = FastMCP("scaw-convert")


def _raise_on_error(result: dict) -> dict:
    """Turn a validation error returned by a write tool into a tool error, so
    the call is shown as failed and is not mistaken for a successful write."""
    if isinstance(result, dict) and result.get('error'):
        raise ValueError(json.dumps(result, ensure_ascii=False))
    return result


# ---- Parse -----------------------------------------------------------------

@mcp.tool()
def download_s3_input(
    s3_uri: str,
    dest_subdir: str = 'db-object/assessment',
    overwrite: bool = False,
) -> dict:
    """Download conversion input files from Amazon S3 into <repo>/input/<dest_subdir>/.

    Use this when the user gives an s3:// path (for example the AWS DMS Schema
    Conversion output bucket). Deterministic, no LLM. ZIP files are extracted
    and every file is written flat (by file name) into the destination; for
    DMS SC, ORACLE_POSTGRESQL_*.zip holds the assessment CSVs, Oracle-*.zip
    the original Oracle DDL, and PostgreSQL-*.zip the converted DDL.

    s3_uri accepts one object (s3://bucket/key), a prefix (s3://bucket/prefix/),
    or a pattern directly under a prefix (s3://bucket/prefix/*.zip).
    The destination always stays inside <repo>/input/ (git-ignored). Existing
    files are kept and returned as "skipped"; use overwrite=True only after the
    user confirms. After extraction, <endpoint>.csv is the detail CSV,
    <endpoint>_Action_Items_Summary.csv the summary CSV, PostgreSQL-<date>.sql the
    converted SQL and Oracle-<date>.sql the original Oracle DDL. Pass the
    returned local file paths to parse_sct_csv / parse_dms_sc_converted_sql.
    Shell commands such as aws s3 cp are not available; use this tool.
    """
    return _download_s3_input(s3_uri, dest_subdir=dest_subdir, overwrite=overwrite)


@mcp.tool()
def parse_sct_csv(
    detail_csv: str,
    summary_csv: str,
    inline: bool = True,
    out_dir: str | None = None,
) -> dict:
    """Parse SCT detail + summary CSVs into per-object action item records.

    Deterministic, no LLM. See parse_sct_csv.py for full docs.
    """
    return _parse_sct_csv(detail_csv, summary_csv, inline=inline, out_dir=out_dir)


@mcp.tool()
def parse_sct_converted_sql(
    sql_path: str,
    inline: bool = True,
    out_dir: str | None = None,
    object_name: str | None = None,
) -> dict:
    """Split an SCT ``converted.sql`` file into per-object CREATE blocks.

    Deterministic, no LLM. 対象オブジェクトが決まっている場合は必ず
    object_name（例: "SCHEMA.PROC_A" または "PROC_A"）を指定し、そのブロック
    だけを取得すること。大きいファイルでもファイルを手動で分割する必要は
    ない（split などで分割したファイルを作らない）。object_name なしの inline
    応答は、上限サイズを超えると code を省略した一覧（code_omitted: true）に
    なる。inline=False で書き出される .cache/*.json は大きいため fs_read で
    直接読まない。See parse_sct_converted_sql.py.
    """
    return _parse_sct_converted_sql(
        sql_path, inline=inline, out_dir=out_dir, object_name=object_name,
    )


@mcp.tool()
def parse_dms_sc_converted_sql(
    sql_path: str,
    inline: bool = True,
    out_dir: str | None = None,
    object_name: str | None = None,
) -> dict:
    """Split an AWS DMS Schema Conversion converted-SQL file into per-object
    CREATE blocks, flagging objects that carry inline Action Item markers.

    Deterministic, no LLM. Use this instead of parse_sct_converted_sql when
    the input file uses DMS Schema Conversion's stage-grouped layout
    (``-- ------------ Write CREATE-XXX-stage scripts -----------``) rather
    than the AWS SCT standalone tool's per-object marker layout.

    対象オブジェクトが決まっている場合は必ず object_name（例:
    "SCHEMA.PROC_A" または "PROC_A"）を指定し、そのブロックだけを取得する
    こと。大きいファイルでもファイルを手動で分割する必要はない（split などで
    分割したファイルを作らない）。object_name なしの inline 応答は、上限サイズを
    超えると code を省略した一覧（name / status / action_item_ids、
    code_omitted: true）になる。inline=False で書き出される .cache/*.json は
    大きいため fs_read で直接読まない。Oracle の CREATE OR REPLACE も同じ方法で
    分割できるため、元の Oracle DDL ファイル（DMS SC の DDL_oracle.sql など）から
    対象オブジェクトの定義を取り出すときにも使える。
    See parse_dms_sc_converted_sql.py for full docs.
    """
    return _parse_dms_sc_converted_sql(
        sql_path, inline=inline, out_dir=out_dir, object_name=object_name,
    )


# ---- Convert (rule-based, deterministic) -----------------------------------

@mcp.tool()
def convert_oracle_sql_rules(sql: str) -> dict:
    """Apply deterministic Oracle->PostgreSQL rules (NVL, DECODE, SYSDATE, ...).

    No LLM call. If no rule applies, returns the original text unchanged.
    """
    return _convert_oracle_sql_rules(sql)


# ---- Validate ---------------------------------------------------------------

@mcp.tool()
def validate_pg_sql(sql: str) -> dict:
    """Check converted SQL for Oracle residuals and PostgreSQL syntax errors.

    Call this for every converted SQL / object before running it or writing
    results. Fix and re-check when issues are returned.
    """
    return _validate_pg_sql(sql)


@mcp.tool()
def validate_bind_integrity(source_sql: str, converted_sql: str) -> dict:
    """Compare bind-placeholder counts between source and converted SQL.

    App track: call this for every converted SQL. If the counts differ, do not
    retry the conversion; report the SQL as manual_review_bind.
    """
    return _validate_bind_integrity(source_sql, converted_sql)


@mcp.tool()
def validate_ecpg(statement: str, timeout: int = 30) -> dict:
    """Precompile-check one EXEC SQL statement with ecpg -C ORACLE.

    実験的機能（Pro*C）。ecpg not installed -> gracefully degrades
    (ecpg_available=False, clean=True).
    """
    return _validate_ecpg(statement, timeout=timeout)


# ---- Detect (app track) -----------------------------------------------------

@mcp.tool()
def scan_for_sql_files(project_root: str) -> dict:
    """Walk a project root and index files that probably contain SQL.

    Writes a jsonl index to disk and returns a compact summary + path
    (avoids flooding chat UI with a large file list).
    """
    return _scan_for_sql_files(project_root)


@mcp.tool()
def detect_xml_sql(file_path: str) -> dict:
    """Locate SQL fragments inside a MyBatis/Hibernate/iBATIS mapper XML file."""
    return _detect_xml_sql(file_path)


@mcp.tool()
def detect_proc_sql(file_path: str) -> dict:
    """Locate EXEC SQL statements and Pro*C constructs in a .pc file.

    実験的機能（Pro*C）。
    """
    return _detect_proc_sql(file_path)


@mcp.tool()
def detect_sql_by_opengrep(file_paths: list[str]) -> dict:
    """Locate embedded SQL in host-language source files (Java, Python, JS/TS,
    C#, PHP, Ruby, C/C++, VB) with opengrep static analysis.

    Two passes run per file: a taint pass that follows a SQL string through
    concatenation, StringBuilder.append, branches, etc. to the call that runs
    it (executeQuery, prepareStatement, ...), which finds dynamically built
    SQL; and a pattern pass for static SQL literals and annotations such as
    @Select / @Query. Use it for the files that scan_for_sql_files classified
    as "source", before reading them; then read the hit ranges to confirm.

    Returns {"ok", "files": {path: {"hits": [{"start_line", "end_line",
    "dynamic"}], "errors": [...]}}, "errors": [...]}. "dynamic" is true when
    the range is a dynamically built SQL (taint pass). ok=false (for example,
    the opengrep binary is not installed) means nothing was scanned: find the
    SQL by reading the files instead.
    """
    files = [p for p in file_paths if p]
    batch = _scan_files_opengrep(files)
    out = {'ok': batch.get('ok', False), 'files': {}, 'errors': batch.get('errors', [])}
    if not out['ok']:
        return out
    for path, raw in batch.get('per_file', {}).items():
        res = _detect_sql_by_opengrep(path, raw_taint=raw['taint'], raw_pattern=raw['pattern'])
        out['files'][path] = {
            'hits': [{'start_line': h['start_line'], 'end_line': h['end_line'],
                      'dynamic': bool(h.get('dynamic'))} for h in res.get('hits', [])],
            'errors': res.get('errors', []),
        }
    return out


@mcp.tool()
def detect_properties_sql(file_path: str) -> dict:
    """Locate SQL in a .properties file (key=value pairs whose value contains
    SQL, e.g. Seasar2 / S2Dao), honoring backslash line continuation. Use it
    for files that scan_for_sql_files classified as "properties"."""
    return _detect_properties_sql(file_path)


@mcp.tool()
def detect_sql_file(file_path: str) -> dict:
    """Split a .sql file into statements (semicolons inside strings and
    comments are handled) and return the DML statements with their line
    ranges. DDL and PL/SQL blocks are skipped (convert DB objects with the db
    track). Use it for files that scan_for_sql_files classified as "sql"."""
    return _detect_sql_file(file_path)


# ---- Reference ----------------------------------------------------------------

@mcp.tool()
def lookup_action_item(action_item: str) -> dict:
    """Look up an Action Item number reported by DMS Schema Conversion or AWS
    SCT (Oracle -> PostgreSQL; both use the same numbers, e.g. 5030, 5605).

    Returns description, recommended_action, documentation_references and
    effort estimates. Use it when the assessment CSV does not explain an
    Action Item well enough to plan the conversion, or when the user asks
    what an Action Item means. Unknown numbers return {"error": ...}.
    """
    try:
        return _lookup_action_item(action_item)
    except ValueError as e:
        return {'error': str(e)}


# ---- Write ------------------------------------------------------------------

@mcp.tool()
def write_app_convert_outputs(
    out_dir: str,
    output_items: list[dict] | None = None,
    per_file_replacements: dict | None = None,
    project_root: str = '',
    mode: str = 'diff',
    test_skipped_reason: str = '',
    output_items_path: str | None = None,
    per_file_replacements_path: str | None = None,
) -> dict:
    """Write app-convert diff/patch outputs (mode: inplace/diff/patch).

    per_file_replacements: {"<file path>": [{"start_line": 10, "end_line": 17,
    "new_text": "<converted lines joined with newlines>"}, ...]}. Line numbers
    are 1-based and inclusive; the range start_line..end_line of the original
    file is replaced by new_text. "converted_lines" (list of lines) may be
    given instead of "new_text". Relative file paths are resolved against
    project_root (pass the absolute path of the application directory the
    user named; diff paths under <out_dir>/diffs/ are relative to it). Line numbers
    always refer to the original file. In diff / patch mode the source is not
    changed and replacements from earlier calls with the same out_dir are kept
    (stored in <out_dir>/.scaw-replacements.json; a new replacement that
    overlaps an earlier one replaces it), so a file may be written in several
    calls. Stored replacements are dropped (stale_replacements_dropped) when
    the source file has changed since. After writing, the whole converted file
    is scanned and Oracle constructs that remain (NVL, DECODE, ROWNUM, (+),
    SYSDATE, ...) are listed in remaining_oracle_syntax: convert them too, or
    tell the user why they stay. Replacements in one call must not overlap.
    Check files_patched / diff_paths in
    the result; files_not_found and files_unchanged list files that produced
    no output. Before writing, each replacement is compared with the original
    lines: if positional placeholders (?, %s, $n) change in number, or named
    placeholders (:name, #{name}, ${name}) change in name or style, nothing is
    written and bind_errors is returned; each error shows original_lines, the
    current content of the given range, so wrong line numbers can be spotted.
    Exception: MyBatis ${x} -> #{x} with the same name is accepted
    automatically (no parameter needed) and listed in the result's
    dollar_to_hash; report it to the user. Keep the
    placeholders as they were, or drop that replacement and report it as
    manual_review_bind. The converted SQL must have been run successfully
    with both run_ora_sql and run_postgres_sql in this chat session within
    the last 30 minutes; otherwise nothing is written and test_errors is
    returned. Missing tables are not a reason to skip: create them first (use
    the project's schema files if any, otherwise minimal temporary tables on
    both databases, dropped afterwards). Only if the SQL really cannot be run
    (e.g. a database is unreachable), give the reason in test_skipped_reason
    and tell the user.
    Do not write diff/patch files yourself with fs_write.
    """
    return _raise_on_error(_write_app_convert_outputs(
        out_dir,
        output_items=output_items,
        per_file_replacements=per_file_replacements,
        project_root=project_root,
        mode=mode,
        test_skipped_reason=test_skipped_reason,
        output_items_path=output_items_path,
        per_file_replacements_path=per_file_replacements_path,
    ))


@mcp.tool()
def write_db_result(
    result_dir: str,
    object_name: str,
    oracle_sql: str,
    postgres_sql: str,
    test_result: str = '',
    status: str = '',
    summary: str = '',
    kind_change_reason: str = '',
) -> dict:
    """Write one db-track conversion result to ./result/<object_name>/.

    status is a review status (tool-review-status skill, e.g. "pass", "fail");
    it decides OK.txt or NG.txt. summary must follow the "OK.txt / NG.txt の雛形"
    template in the tool-output-layout skill (same headings and item labels).
    If something is missing, nothing is written and error / missing_headings
    are returned: fix the summary and call again. 実施日時 is filled in by
    this tool. If oracle_sql is a FUNCTION and postgres_sql a PROCEDURE (or the
    reverse), nothing is written unless kind_change_reason explains why the
    kind must change (callers change too, so prefer keeping the kind).
    Do not write result files yourself with fs_write.
    """
    return _raise_on_error(_write_db_result(
        result_dir, object_name, oracle_sql, postgres_sql, test_result,
        status=status, summary=summary, kind_change_reason=kind_change_reason,
    ))


@mcp.tool()
def list_converted_objects(result_dir: str) -> list[str]:
    """List object names already converted under result_dir (残りリスト判定用).

    Names are upper case without the schema prefix (e.g. "PROC_A" for
    "SCHEMA.proc_a"); compare them with the target names the same way.
    """
    return _list_converted_objects(result_dir)


@mcp.tool()
def write_skill_draft(
    project_root: str,
    object_name: str,
    pattern_summary: str,
) -> dict:
    """Append a discovered conversion pattern to workshop-custom-rules/SKILL.md.

    The text is appended immediately. Show the proposed text to the participant
    first and call this tool only after they approve it.
    """
    return _write_skill_draft(project_root, object_name, pattern_summary)


# ---- Lookup -----------------------------------------------------------------

@mcp.tool()
def load_custom_rules(project_root: str) -> dict:
    """Load workshop-custom-rules/SKILL.md content for prompt injection."""
    return _load_custom_rules(project_root)


@mcp.tool()
def format_custom_rules_for_prompt(content: str) -> str:
    """Wrap raw workshop-custom-rules markdown into a prompt-ready appendix."""
    return _format_custom_rules_for_prompt(content)


if __name__ == "__main__":
    mcp.run(transport="stdio")
