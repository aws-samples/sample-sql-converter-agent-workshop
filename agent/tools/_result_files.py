"""Write the test and summary files shared by the db track and the app track.

Each converted object (db track) or source file (app track) gets its own
directory with the same set of files:

    prerequisites.txt        # pre-checks (db track only)
    oracle_test.sql          # test SQL run on Oracle
    oracle_test.txt          # Oracle results
    postgres_test.sql        # the same tests rewritten for PostgreSQL
    postgres_test.txt        # PostgreSQL results
    comparison_result.txt    # comparison of the two, and analysis of differences
    OK.txt or NG.txt         # summary (template in tool-output-layout/SKILL.md)
"""
import os

TEST_FILES = (
    ('oracle_test_sql', 'oracle_test.sql'),
    ('oracle_test_result', 'oracle_test.txt'),
    ('postgres_test_sql', 'postgres_test.sql'),
    ('postgres_test_result', 'postgres_test.txt'),
    ('comparison_result', 'comparison_result.txt'),
)

_NOT_RUN = '(テストは実行していません。理由は OK.txt / NG.txt を参照)\n'


def write_test_files(target_dir: str, tests: dict) -> dict:
    """Write the five test files into ``target_dir``. Missing or empty
    values get a short placeholder so that every directory has the same
    files. Returns {key: path}."""
    paths = {}
    for key, name in TEST_FILES:
        path = os.path.join(target_dir, name)
        text = (tests or {}).get(key) or ''
        with open(path, 'w', encoding='utf-8') as f:
            f.write(text if text.strip() else _NOT_RUN)
        paths[key + '_path'] = path
    # The single-file layout used before is replaced by the files above.
    legacy = os.path.join(target_dir, 'test_result.txt')
    if os.path.exists(legacy):
        os.remove(legacy)
    return paths


def write_summary(target_dir: str, is_ok: bool, body: str) -> str:
    """Write OK.txt or NG.txt and remove the other one (left over from an
    earlier attempt with the opposite outcome). Returns the path."""
    path = os.path.join(target_dir, 'OK.txt' if is_ok else 'NG.txt')
    with open(path, 'w', encoding='utf-8') as f:
        f.write(body)
    other = os.path.join(target_dir, 'NG.txt' if is_ok else 'OK.txt')
    if os.path.exists(other):
        os.remove(other)
    return path
