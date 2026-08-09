#!/bin/sh
# Check the workspace files stay in step with the repos on disk.
#
# A repo added to the workspace and forgotten here fails to build with a
# confusing error much later. Catch it now.
set -eu

fail=0

for f in workspace.yaml go.work Cargo.toml pnpm-workspace.yaml CLAUDE.md; do
    [ -f "workspace/$f" ] || { echo "missing workspace/$f" >&2; fail=1; }
done

# Every sibling repo holding a go.mod must appear in go.work.
for d in ../poe-wayfinder-*; do
    name=$(basename "$d")
    [ "$name" = "poe-wayfinder-workspace" ] && continue

    if [ -f "$d/go.mod" ] && ! grep -q "\./$name" workspace/go.work; then
        echo "$name has a go.mod but is missing from go.work" >&2
        fail=1
    fi

    if [ -f "$d/Cargo.toml" ] && ! grep -q "\"$name\"" workspace/Cargo.toml; then
        echo "$name has a Cargo.toml but is missing from the Cargo workspace" >&2
        fail=1
    fi
done

[ "$fail" -eq 0 ] && echo "workspace files are consistent with the repos on disk"

exit "$fail"
