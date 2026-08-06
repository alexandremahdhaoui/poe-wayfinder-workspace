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

## Parity is measured, not claimed

```sh
cd poe-trader-app && forge test run parity
```

It reports what fraction of the reference is ported and lists every missing
function by reference file. The floor in `forge.yaml` only ever goes up.

**It reads 100% as of the port's completion.** The floor is pinned there, so
any new reference function shows up as a failing test rather than as a number
quietly drifting down.

100% counts functions, not behaviour. An alias must point at a real
implementation of the same thing. Four aliases were stretches when first
written and were replaced with actual ports rather than left to inflate the
number.

A rename goes in `ALIASES`. A deliberate omission goes in `WAIVED` with a
reason. Anything else is a gap and shows up as one.

**Do not report progress without running it.** Eyeballing parity with greps
produced confident wrong answers more than once.

## Repos

| Repo | Owns |
|---|---|
| poe-trader-workspace | the workspace root files |
| poe-trader-spec | config keys and network policy |
| poe-trader-data | the built ndjson |
| poe-trader-core | the domain. No I/O. |
| poe-trader-app | adapters, drivers, binaries |

`golden-configgen` from the playground workspace is reused unchanged.
