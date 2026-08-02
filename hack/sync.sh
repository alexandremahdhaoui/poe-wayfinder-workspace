#!/bin/sh
# Copy the workspace files to the workspace root.
#
# The root of ~/workspaces/<name>/ is not a git repo. These files live here and
# get copied up. Losing the root directory costs nothing. Clone this repo and
# run the sync.
set -eu

DEST="${1:-..}"

for f in workspace.yaml go.work Cargo.toml pnpm-workspace.yaml CLAUDE.md; do
    cp "workspace/$f" "$DEST/$f"
    echo "sync: wrote $DEST/$f"
done
