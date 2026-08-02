# CLAUDE.md — poe-trader workspace

A Rust overlay for Path of Exile 1 and 2. A port of Awakened PoE Trade and
Exiled Exchange 2.

Read ~/.claude/CLAUDE.md first. Those rules apply here.

## Read before touching anything

`STUDY.md` at the workspace root. 676 lines. Every claim carries a file and
line reference into the reference checkouts under `reference/`.

`DESIGN.md` maps every reference file to its Rust destination.

## Hard rules for this workspace

**English only.** `www.pathofexile.com` and nothing else. No regional domains.

**No private third party.** The reference ships `api.exiledexchange2.dev` in
its allowlist. That is the fork maintainer's own server. We never use it.

**No Python.** The reference data pipeline is 7623 lines of Python. It ports
to Rust in `poe-trader-app/src/bin/poe-trader-datagen.rs`.

**One socket.** Every outbound request goes through `http_adapter.rs` which
holds the allowlist and refuses everything else.

**The rate limiter is not optional.** GGG bans for violations. See STUDY 2.

## Repos

| Repo | Owns |
|---|---|
| poe-trader-workspace | the workspace root files |
| poe-trader-spec | config keys and network policy |
| poe-trader-data | the built ndjson |
| poe-trader-core | the domain. No I/O. |
| poe-trader-app | adapters, drivers, binaries |

`golden-configgen` from the playground workspace is reused unchanged.
