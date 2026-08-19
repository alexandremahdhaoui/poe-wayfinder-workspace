# poe-wayfinder-factory

Owns the files that sit at the root of the `poe-wayfinder` workspace.

The workspace root is not a git repo. Without this repo, `Cargo.toml`,
`go.work` and `workspace.yaml` would belong to nobody and drift silently.

## Files it owns

| File | Job |
|---|---|
| `workspace/workspace.yaml` | maps a module path to a local checkout |
| `workspace/Cargo.toml` | the virtual Cargo workspace |
| `workspace/go.work` | the Go workspace |
| `workspace/pnpm-workspace.yaml` | the pnpm workspace |
| `workspace/CLAUDE.md` | workspace wide rules |

## Sync them to the root

```sh
forge build sync
```

That copies `workspace/*` to `..`. Run it after adding a repo.

## Adding a repo

1. Clone it into `~/workspaces/poe-wayfinder/`.
2. Add it to `workspace/Cargo.toml` members if it is Rust.
3. Add it to `workspace/go.work` if it is Go.
4. Add it to `workspace/workspace.yaml` if anything resolves specs from it.
5. `forge build sync`
6. `forge test-all`

The validate stage fails if you skip step 2 or 3.

## Why workspace.yaml and not go.work

`go.work` maps Go modules. `workspace.yaml` maps any module to a directory so
`resolve-spec.sh` can find a spec in a sibling checkout instead of over the
network. A local checkout always wins. The version tag is the fallback.

## sync.sh copies one direction only

`hack/sync.sh` copies `workspace/` **to** the workspace root. It never reads the
root back. Edit a root file in place and the change is untracked, and the next
sync silently destroys it.

Edit `workspace/<file>` and sync down, or copy the root file back up before
committing:

```sh
cp ../CLAUDE.md ../Cargo.toml workspace/
```

This has already cost one session's documentation once.
