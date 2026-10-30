#!/usr/bin/env bash
# install-agents.sh — wire the scaw-migration-* agents into the user's
# Kiro CLI so `kiro-cli chat --agent scaw-migration-db` (and the other
# 3 agents) resolves from any working directory.
#
# What it does:
#   1. Resolves the absolute path to this repo (PROJECT_ROOT).
#   2. Reads each template under agent/kiro/, substitutes
#      {PROJECT_ROOT} with the absolute path, and writes the result
#      to the target agents directory.
#   3. Target directory defaults to .kiro/agents inside this repo
#      (workspace-scoped) so the agents don't leak into unrelated
#      projects. Use --global to install into ~/.kiro/agents instead
#      so the agents are discoverable from any cwd.
#   4. Idempotent: existing agent files are overwritten only with
#      --force.
#
# Verified against kiro-cli v2.21.4: `{PROJECT_ROOT}` must be
# substituted BEFORE the JSON is placed in .kiro/agents — Kiro CLI
# does not resolve placeholders itself.
#
# Requires: `uv` on PATH (agent/tools/server.py and agent/mcpserver/
# are both launched via `uv run --project <PROJECT_ROOT>/agent python ...`,
# see agent/kiro/*.json).

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC_DIR="$PROJECT_ROOT/agent/kiro"
TARGET="$PROJECT_ROOT/.kiro/agents"
FORCE=0
UNINSTALL=0

usage() {
    cat <<EOF
Usage: $0 [--global] [--target DIR] [--force] [--uninstall]

  --global       Install into ~/.kiro/agents instead of
                 <repo>/.kiro/agents (discoverable from any cwd).
  --target DIR   Override target directory.
  --force        Overwrite existing agent files without prompting.
  --uninstall    Remove the scaw-migration-* agent files from the
                 target directory.

By default installs 4 agents:
  scaw-migration-db           (db worker: workshop front-half, interactive)
  scaw-migration-app          (app worker: workshop front-half, interactive)
  scaw-migration-db-batch     (db batch: workshop back-half and real projects, parallel)
  scaw-migration-app-batch    (app batch: workshop back-half and real projects, parallel)
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --global)      TARGET="$HOME/.kiro/agents"; shift ;;
        --target)      TARGET="$2"; shift 2 ;;
        --force)       FORCE=1; shift ;;
        --uninstall)   UNINSTALL=1; shift ;;
        -h|--help)     usage; exit 0 ;;
        *)             echo "Unknown arg: $1"; usage; exit 2 ;;
    esac
done

AGENTS=(
    scaw-migration-db.json
    scaw-migration-app.json
    scaw-migration-db-batch.json
    scaw-migration-app-batch.json
)

# Agents that earlier versions installed but this version no longer
# ships. --uninstall also removes these, and a normal install removes
# them so a stale definition does not linger in `kiro-cli agent list`.
RETIRED_AGENTS=(
    scaw-migration.json
)

# --- uninstall path -------------------------------------------------
if [[ $UNINSTALL -eq 1 ]]; then
    for a in "${AGENTS[@]}" "${RETIRED_AGENTS[@]}"; do
        if [[ -f "$TARGET/$a" ]]; then
            rm -- "$TARGET/$a"
            echo "removed $TARGET/$a"
        fi
    done
    exit 0
fi

mkdir -p "$TARGET"

# --- remove agents retired in this version ---------------------------
for a in "${RETIRED_AGENTS[@]}"; do
    if [[ -f "$TARGET/$a" ]]; then
        rm -- "$TARGET/$a"
        echo "removed retired agent $TARGET/$a"
    fi
done

# --- verify uv is available ------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
    echo "warning: 'uv' not found on PATH. agent/kiro/*.json launches" >&2
    echo "         MCP servers via 'uv run --project ...' — install uv first:" >&2
    echo "         curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
fi

# --- install each agent JSON ---------------------------------------
for a in "${AGENTS[@]}"; do
    src="$SRC_DIR/$a"
    dst="$TARGET/$a"
    if [[ ! -f "$src" ]]; then
        echo "error: template not found: $src" >&2
        exit 2
    fi
    if [[ -e "$dst" ]] && [[ $FORCE -eq 0 ]]; then
        echo "skip (exists): $dst — rerun with --force to overwrite" >&2
        continue
    fi
    sed "s|{PROJECT_ROOT}|$PROJECT_ROOT|g" "$src" > "$dst"
    echo "installed $dst"
done

echo
echo "Installed into: $TARGET"
echo
echo "Verify with:"
echo "  kiro-cli agent list | grep scaw-migration"
echo
echo "Workshop front-half (interactive, one object/file at a time):"
echo "  kiro-cli chat --agent scaw-migration-db"
echo "  kiro-cli chat --agent scaw-migration-app"
echo
echo "Workshop back-half and real projects (parallel batch conversion):"
echo "  kiro-cli settings chat.enableSubagent true   # once, if not already enabled"
echo "  kiro-cli chat --agent scaw-migration-db-batch"
echo "  kiro-cli chat --agent scaw-migration-app-batch"
