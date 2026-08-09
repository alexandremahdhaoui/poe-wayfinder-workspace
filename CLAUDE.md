# CLAUDE.md — poe-wayfinder-workspace

Read `~/.claude/CLAUDE.md` then `workspace/CLAUDE.md`. Both apply.

## What this repo is

The version controlled home of the workspace root files.

`~/workspaces/poe-wayfinder/` is not a git repo. `forge build sync` copies
`workspace/*` up to it.

## Edit under workspace/ and never at the root

A change made directly at the workspace root is lost on the next sync and
nobody will know why.

## Adding a repo means four edits

`workspace/Cargo.toml`, `workspace/go.work`, `workspace/workspace.yaml` and
then `forge build sync`.

`hack/validate.sh` fails if a sibling repo has a `Cargo.toml` or a `go.mod`
and is missing from the matching workspace file. That check exists because
the error you get otherwise is confusing and arrives much later.

## Version pins live in workspace.yaml

Each module gets a `path` and a `version`. `resolve-spec.sh` prefers the
local path and falls back to the tag.

Bump the tag when you publish a spec. Do not point a consumer at `main`.
