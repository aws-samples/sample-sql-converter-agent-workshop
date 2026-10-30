"""Load the workshop's custom conversion rules from ``workshop-custom-rules/SKILL.md``.

Reads ``agent/skills/workshop-custom-rules/SKILL.md``, a skill that grows
during the interactive (first-half) conversions. No fixed precedence is
imposed — rule conflicts are left for the participant to resolve (all
files are editable by the participant).

Load errors (missing file, unreadable bytes, oversized) are NOT raised —
the tool returns ``found=False`` / a warning so convert work continues
without custom rules.
"""
from __future__ import annotations

import os


# Soft cap — chars, not bytes. Anything larger likely isn't a rule
# catalogue and would just bloat every LLM prompt in the convert loop.
_SOFT_SIZE_CAP = 50_000

_DEFAULT_RELATIVE_PATH = os.path.join(
    'agent', 'skills', 'workshop-custom-rules', 'SKILL.md'
)


def load_custom_rules(project_root: str) -> dict:
    """Load ``<project_root>/agent/skills/workshop-custom-rules/SKILL.md``.

    Args:
        project_root: Absolute path to the SCAW2.0 repository root
            (or any ancestor of ``agent/skills/workshop-custom-rules/``).

    Returns:
        Dict with:
          - ``found`` (bool): True when the file exists and was read
            successfully.
          - ``path`` (str | None): Absolute path to the file when found,
            else None.
          - ``content`` (str): Markdown content. Empty string when not
            found or read failed.
          - ``size`` (int): Content length in characters.
          - ``warnings`` (list[str]): Human-readable notes.

    Raises:
        Never. Load errors surface via ``found=False`` + ``warnings``.
    """
    if not project_root:
        return {
            'found': False, 'path': None, 'content': '', 'size': 0,
            'warnings': ['project_root is empty'],
        }

    project_root = os.path.abspath(project_root)
    path = os.path.join(project_root, _DEFAULT_RELATIVE_PATH)
    warnings: list[str] = []

    if not os.path.isfile(path):
        return {
            'found': False, 'path': None, 'content': '', 'size': 0,
            'warnings': warnings,
        }

    try:
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError as exc:
        warnings.append(
            f'workshop-custom-rules/SKILL.md is not valid UTF-8: {exc}; '
            f'skipping custom rules for this run'
        )
        return {
            'found': False, 'path': path, 'content': '', 'size': 0,
            'warnings': warnings,
        }
    except OSError as exc:
        warnings.append(
            f'workshop-custom-rules/SKILL.md could not be read: {exc}; '
            f'skipping custom rules for this run'
        )
        return {
            'found': False, 'path': path, 'content': '', 'size': 0,
            'warnings': warnings,
        }

    size = len(content)
    if size == 0:
        # Expected state early in the workshop — the file starts as a
        # heading-only template and grows as patterns are found.
        warnings.append('workshop-custom-rules/SKILL.md is empty (not yet populated)')
        return {
            'found': False, 'path': path, 'content': '', 'size': 0,
            'warnings': warnings,
        }
    if size > _SOFT_SIZE_CAP:
        warnings.append(
            f'workshop-custom-rules/SKILL.md is {size} chars (soft cap '
            f'{_SOFT_SIZE_CAP}); it will still be loaded, but injecting '
            f'this much text into every LLM convert call makes the run '
            f'slow and expensive.'
        )

    return {
        'found': True, 'path': path, 'content': content, 'size': size,
        'warnings': warnings,
    }


def format_custom_rules_for_prompt(content: str) -> str:
    """Wrap raw markdown into a prompt-ready appendix section.

    This does NOT assert that a fixed CRITICAL CONVERSION POLICY always
    wins over these rules — SCAW2.0 treats all rules as equally
    editable. If a rule here
    conflicts with `domain-conversion-rules`, the agent should surface
    the conflict to the participant rather than silently overriding
    one side.

    Args:
        content: Raw markdown read from ``workshop-custom-rules/SKILL.md``.

    Returns:
        A string ready to append to the LLM prompt. Empty string when
        ``content`` is empty — callers can unconditionally append it.
    """
    if not content or not content.strip():
        return ''
    return (
        '\n\n## Workshop custom rules (workshop-custom-rules/SKILL.md)\n\n'
        'These rules were discovered and reviewed during this workshop '
        'session. Apply them when converting. If a rule here conflicts '
        'with the general conversion rules (domain-conversion-rules), '
        'flag the conflict to the user rather than silently picking a '
        'side — both files are equally editable in SCAW2.0.\n\n'
        f'{content.strip()}\n'
    )
