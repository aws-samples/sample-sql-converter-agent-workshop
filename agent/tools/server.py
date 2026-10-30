"""SCAW2.0 convert-phase MCP tool server.

Exposes the SCAW2.0 MCP tools via FastMCP.

Run:
    uv run server.py
"""
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
    files are kept unless overwrite=True. After downloading, pass the returned
    local file paths to parse_sct_csv / parse_dms_sc_converted_sql.
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
    ない。object_name なしの inline 応答は、上限サイズを超えると code を
    省略した一覧（code_omitted: true）になる。See parse_sct_converted_sql.py.
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
    こと。大きいファイルでもファイルを手動で分割する必要はない。
    object_name なしの inline 応答は、上限サイズを超えると code を省略した
    一覧（name / status / action_item_ids、code_omitted: true）になる。
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
    """Check converted SQL for Oracle residuals and PostgreSQL syntax errors."""
    return _validate_pg_sql(sql)


@mcp.tool()
def validate_bind_integrity(source_sql: str, converted_sql: str) -> dict:
    """Compare bind-placeholder counts between source and converted SQL."""
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


# ---- Write ------------------------------------------------------------------

@mcp.tool()
def write_app_convert_outputs(
    out_dir: str,
    output_items: list[dict] | None = None,
    per_file_replacements: dict | None = None,
    project_root: str = '',
    mode: str = 'diff',
    output_items_path: str | None = None,
    per_file_replacements_path: str | None = None,
) -> dict:
    """Write app-convert diff/patch outputs (mode: inplace/diff/patch)."""
    return _write_app_convert_outputs(
        out_dir,
        output_items=output_items,
        per_file_replacements=per_file_replacements,
        project_root=project_root,
        mode=mode,
        output_items_path=output_items_path,
        per_file_replacements_path=per_file_replacements_path,
    )


@mcp.tool()
def write_db_result(
    result_dir: str,
    object_name: str,
    oracle_sql: str,
    postgres_sql: str,
    test_result: str = '',
    status: str = '',
    summary: str = '',
) -> dict:
    """Write one db-track conversion result to ./result/<object_name>/.

    Pass status (review-status vocabulary, e.g. "pass"/"fail" — see
    tool-db-inventory-schema skill) and summary to also write OK.txt /
    NG.txt (SCAW1.0-derived format, see tool-output-layout skill).
    """
    return _write_db_result(
        result_dir, object_name, oracle_sql, postgres_sql, test_result,
        status=status, summary=summary,
    )


@mcp.tool()
def list_converted_objects(result_dir: str) -> list[str]:
    """List object names already converted under result_dir (残りリスト判定用)."""
    return _list_converted_objects(result_dir)


@mcp.tool()
def write_skill_draft(
    project_root: str,
    object_name: str,
    pattern_summary: str,
) -> dict:
    """Append a discovered conversion pattern to workshop-custom-rules/SKILL.md."""
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
