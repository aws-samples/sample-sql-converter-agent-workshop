"""Download conversion input files (e.g. AWS DMS Schema Conversion output)
from Amazon S3 into this repository's ``input/`` directory.

New tool for SCAW2.0. Deterministic — no LLM.

AWS DMS Schema Conversion writes its results to S3 as ZIP files:

- ``ORACLE_POSTGRESQL_<timestamp>.zip``: assessment CSVs
  (``<endpoint>.csv`` / ``<endpoint>_Summary.csv`` /
  ``<endpoint>_Action_Items_Summary.csv``)
- ``Oracle-<timestamp>.zip``: the original Oracle DDL (``Oracle-<timestamp>.sql``)
- ``PostgreSQL-<timestamp>.zip``: the converted PostgreSQL DDL
  (``PostgreSQL-<timestamp>.sql``)

This tool downloads the requested objects, extracts ZIP files, and writes
every file flat (by file name only) into ``<repo>/input/<dest_subdir>/``.
Directory names inside the ZIPs (DMS SC uses the source host and target
endpoint as folder names) are dropped.

Safety limits:

- The destination is always inside ``<repo>/input/`` (``dest_subdir`` that
  resolves outside it is rejected), so downloaded customer data stays in the
  git-ignored directory.
- At most ``MAX_OBJECTS`` S3 objects and ``MAX_TOTAL_BYTES`` bytes per call.
- Existing files are not overwritten unless ``overwrite=True``.
"""
from __future__ import annotations

import fnmatch
import os
import tempfile
import zipfile
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
INPUT_ROOT = PROJECT_ROOT / 'input'

MAX_OBJECTS = 50
MAX_TOTAL_BYTES = 1024 * 1024 * 1024  # 1 GiB


def _parse_s3_uri(s3_uri: str) -> tuple[str, str, str | None]:
    """Return ``(bucket, prefix_or_key, glob_pattern)``.

    ``s3://bucket/path/*.zip`` -> ``("bucket", "path/", "*.zip")``;
    ``s3://bucket/path/file.zip`` -> ``("bucket", "path/file.zip", None)``;
    ``s3://bucket/path/`` -> ``("bucket", "path/", None)``.
    """
    if not s3_uri.startswith('s3://'):
        raise ValueError(f'download_s3_input: not an s3:// URI: {s3_uri!r}')
    rest = s3_uri[len('s3://'):]
    bucket, _, key = rest.partition('/')
    if not bucket:
        raise ValueError(f'download_s3_input: bucket is missing: {s3_uri!r}')
    base = key.rsplit('/', 1)[-1]
    if any(ch in base for ch in '*?['):
        prefix = key[: len(key) - len(base)]
        return bucket, prefix, base
    return bucket, key, None


def _resolve_dest(dest_subdir: str) -> Path:
    dest = (INPUT_ROOT / dest_subdir).resolve()
    if dest != INPUT_ROOT.resolve() and INPUT_ROOT.resolve() not in dest.parents:
        raise ValueError(
            f'download_s3_input: dest_subdir must stay inside {INPUT_ROOT}: '
            f'{dest_subdir!r}'
        )
    return dest


def _list_keys(s3, bucket: str, prefix: str, pattern: str | None,
               exact_key: bool) -> list[dict]:
    if exact_key:
        from botocore.exceptions import ClientError
        try:
            head = s3.head_object(Bucket=bucket, Key=prefix)
            return [{'Key': prefix, 'Size': head['ContentLength']}]
        except ClientError as e:
            if e.response.get('Error', {}).get('Code') not in ('404', 'NoSuchKey', 'NotFound'):
                raise
            # Not an object: treat it as a "folder" given without a trailing slash.
            prefix = prefix + '/'
    objs = []
    paginator = s3.get_paginator('list_objects_v2')
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for o in page.get('Contents', []):
            key = o['Key']
            if key.endswith('/'):
                continue
            # Only objects directly under the prefix when a glob is used;
            # all objects under the prefix otherwise.
            name = key[len(prefix):]
            if pattern is not None:
                if '/' in name or not fnmatch.fnmatch(name, pattern):
                    continue
            objs.append({'Key': key, 'Size': o['Size']})
    return objs


def _write_file(dest: Path, name: str, data: bytes, overwrite: bool,
                source: str, files: list, skipped: list) -> None:
    name = os.path.basename(name)
    if not name or name in ('.', '..'):
        return
    target = dest / name
    if target.exists() and not overwrite:
        skipped.append({'path': str(target), 'from': source,
                        'reason': 'already exists (pass overwrite=True to replace)'})
        return
    target.write_bytes(data)
    files.append({'path': str(target), 'size': len(data), 'from': source})


def download_s3_input(
    s3_uri: str,
    dest_subdir: str = 'db-object/assessment',
    overwrite: bool = False,
) -> dict:
    """Download S3 objects into ``<repo>/input/<dest_subdir>/``, extracting ZIPs.

    Args:
        s3_uri: ``s3://bucket/key`` (one object), ``s3://bucket/prefix/``
            (every object under the prefix), or ``s3://bucket/prefix/*.zip``
            (objects directly under the prefix that match the pattern).
        dest_subdir: Sub-directory of ``<repo>/input/`` to write into.
            Default ``db-object/assessment``. Must stay inside ``input/``.
        overwrite: Replace files that already exist. Default False.

    Returns:
        ``{"dest_dir": str, "downloaded": [s3 keys], "files": [{path, size,
        from}], "skipped": [{path, from, reason}]}``.
    """
    import boto3  # imported lazily so the other tools load without AWS libs

    bucket, prefix, pattern = _parse_s3_uri(s3_uri)
    exact_key = pattern is None and prefix != '' and not prefix.endswith('/')
    dest = _resolve_dest(dest_subdir)

    s3 = boto3.client('s3')
    objs = _list_keys(s3, bucket, prefix, pattern, exact_key)
    if not objs:
        raise ValueError(f'download_s3_input: no objects found at {s3_uri!r}')
    if len(objs) > MAX_OBJECTS:
        raise ValueError(
            f'download_s3_input: {len(objs)} objects found (limit {MAX_OBJECTS}). '
            'Narrow the prefix or use a pattern such as s3://bucket/prefix/*.zip.'
        )
    total = sum(o['Size'] for o in objs)
    if total > MAX_TOTAL_BYTES:
        raise ValueError(
            f'download_s3_input: total size {total} bytes exceeds the limit '
            f'({MAX_TOTAL_BYTES} bytes).'
        )

    dest.mkdir(parents=True, exist_ok=True)
    files: list[dict] = []
    skipped: list[dict] = []
    for o in objs:
        key = o['Key']
        source = f's3://{bucket}/{key}'
        with tempfile.TemporaryDirectory() as tmp:
            local = Path(tmp) / 'obj'
            s3.download_file(bucket, key, str(local))
            if zipfile.is_zipfile(local):
                with zipfile.ZipFile(local) as zf:
                    for info in zf.infolist():
                        if info.is_dir() or info.filename.startswith('__MACOSX/'):
                            continue
                        _write_file(dest, info.filename, zf.read(info),
                                    overwrite, f'{source}!{info.filename}',
                                    files, skipped)
            else:
                _write_file(dest, key.rsplit('/', 1)[-1], local.read_bytes(),
                            overwrite, source, files, skipped)

    return {
        'dest_dir': str(dest),
        'downloaded': [o['Key'] for o in objs],
        'files': files,
        'skipped': skipped,
    }
