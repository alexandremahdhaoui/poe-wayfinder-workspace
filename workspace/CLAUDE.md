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
cd poe-trader-app && forge test-all
```

Three parity stages, one per part of the two references. Each reports what
fraction is ported and lists every missing function by file. Every floor is
pinned at 100 and only ever goes up.

| Stage | Measures |
|---|---|
| `parity` | Exiled Exchange 2, the PoE2 reference |
| `parity-overlay` | Awakened PoE Trade's Electron shell |
| `parity-poe1` | Awakened PoE Trade's renderer, the PoE1 price check |

**Measure both references or PoE1 rots quietly.** Exiled Exchange 2 is a PoE2
fork. Its influence filter is commented out, its heist rules are gone and nine
PoE1 parser stages went with them. Measuring only that reference read 100
percent while PoE1 was missing 23 functions and could not filter on influence,
read a heist contract or resolve a map whose name carried its tier.

100% counts functions, not behaviour. An alias must point at a real
implementation of the same thing. Four aliases were stretches when first
written and were replaced with actual ports rather than left to inflate the
number.

A rename goes in `ALIASES`. A deliberate omission goes in `WAIVED` with a
reason. Anything else is a gap and shows up as one.

**Do not report progress without running it.** Eyeballing parity with greps
produced confident wrong answers more than once.

## The data is measured too

```sh
cd poe-trader-app && forge test run datacheck
```

Parity counts functions. `datacheck` counts stats and bases, which is what a
wrong parser actually costs.

It renders the line the game would print from every matcher in a data file,
feeds it back through the parser and checks it comes back as its own stat. It
does the same for every base. It also checks no table the parser reads is
empty.

Both games read 92 percent on stats while every test passed, because the trade
data keys some stats with a leading `+` and the parser dropped it. A missed
stat is a missing filter, not an error, so the item priced against the whole
market and nothing reported a problem.

The empty table check is separate on purpose. 873 gems were filed under `ITEM`,
so a gem-shaped clipboard still found them there and coverage read 100 percent
while the gem table sat empty.

It needs `data-poe1/` and `data-poe2/`, built by `poe-trader-datagen`. It
passes with neither, so a fresh checkout still builds.

## Repos

| Repo | Owns |
|---|---|
| poe-trader-workspace | the workspace root files |
| poe-trader-spec | config keys and network policy |
| poe-trader-data | the built ndjson |
| poe-trader-core | the domain. No I/O. |
| poe-trader-app | adapters, drivers, binaries |

`golden-configgen` from the playground workspace is reused unchanged.
