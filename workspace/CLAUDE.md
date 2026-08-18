# CLAUDE.md — poe-wayfinder workspace

A Rust overlay for Path of Exile 1 and 2. A port of Awakened PoE Trade and
Exiled Exchange 2.

Read ~/.claude/CLAUDE.md first. Those rules apply here.

## The CLAUDE.md files are the source of truth

This one, and the one in each repo. Nothing else is authority. Any loose
document at the workspace root is a personal note, and a rule that matters
belongs here instead.

Behaviour is checked against the reference checkouts under `reference/`.

## Hard rules for this workspace

**English only.** `www.pathofexile.com` and nothing else. No regional domains.

**No private third party.** The reference ships `api.exiledexchange2.dev` in
its allowlist. That is the fork maintainer's own server. We never use it. It
stays banned. This is not reconsidered.

**Only the user adds a host to the allowlist.** Never widen the allowlist,
never add an outbound host, and never design a feature whose core needs one,
without the user approving that specific host by name first. Propose it, name
what it costs and what breaks without it, and wait. A host nobody agreed to is
a dependency on someone else's server and a change to what this app tells the
world about its users.

**filterblade.xyz is settled: local only, permanently.** The user decided on
2026-08-14. We never call it and we never ask its maintainer. FilterBlade
publishes no API, and its terms require explicit permission to redistribute or
modify. Loot filters are local files, so nothing needs it: `/itemfilter <name>`
switches filters in both games and the filter directory is the one
`game_config_adapter` already resolves.

**Working out a private API from a site's frontend is not research.** Do not
fetch JavaScript bundles to extract endpoints and do not probe undocumented
paths. Read what a project publishes: documentation, source, licence, terms.
"They did not document it" is an answer, not an obstacle.

**No Python.** The reference data pipeline is 7623 lines of Python. It ports
to Rust in `poe-wayfinder-app/src/bin/poe-wayfinder-datagen.rs`.

**One socket.** Every outbound request goes through `http_adapter.rs` which
holds the allowlist and refuses everything else.

**The rate limiter is not optional.** GGG bans for violations. It is server
driven: `x-rate-limit-rules` names the active rules and each carries
`max:window:penalty` triplets, so the client reshapes itself to match. Every
window is padded by `api_latency_seconds` because a client that thinks a window
expired before the server does gets a 429.

## Parity is measured, not claimed

```sh
cd poe-wayfinder-app && forge test-all
```

Four parity stages, one per part of the two references. Each reports what
fraction is ported and lists every missing function by file. Every floor is
pinned at 100 and only ever goes up.

| Stage | Measures |
|---|---|
| `parity` | Exiled Exchange 2, the PoE2 reference |
| `parity-overlay` | Awakened PoE Trade's Electron shell |
| `parity-widgets` | Exiled Exchange 2's widgets, the panels beside the price check |
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
cd poe-wayfinder-app && forge test run datacheck
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

It needs `data-poe1/` and `data-poe2/`, built by `poe-wayfinder-datagen`. It
passes with neither, so a fresh checkout still builds.

## Repos

| Repo | Owns |
|---|---|
| poe-wayfinder-workspace | the workspace root files |
| poe-wayfinder-spec | config keys and network policy |
| poe-wayfinder-data | the built ndjson |
| poe-wayfinder-core | the domain. No I/O. |
| poe-wayfinder-app | adapters, drivers, binaries |

`golden-configgen` from the playground workspace is reused unchanged.

## Running it with nothing

`poe-wayfinder.exe` takes no arguments. Copy it anywhere and start it.

- **The game data is inside it.** `poe-wayfinder-data` is a crate whose `src/lib.rs`
  is `include_bytes!` over `data/<game>/*.ndjson`, both games, about 5.5 MB. The
  exe is 27 MB instead of 22 MB and needs no folder beside it.
- **`--data-dir` is an override, not a requirement.** A directory named there
  always wins, and a bad one is a startup failure rather than a silent
  fallback, because the user asked for that directory by name.
- **`--game` defaults to `auto`.** The overlay reads the open window titles and
  keeps reading them. Alt tab from PoE2 to PoE1 and the parser, the trade
  endpoint, the window it attaches to and the Client.txt it tails all follow.
  Naming a game or a `--window-title` pins it and stops the following.
- **The league is learned.** `--client-log-path` defaults to the first
  `Client.txt` found in the usual install locations, per game.
- **POESESSID is not needed.** It stays a config key for people who want it.

Precedence for the data is `--data-dir`, then the refreshed cache in the config
directory, then the copy built into the binary. The origin is on the
`loaded the game data` log line, so a support question is answerable from a log.

`--config-dir` defaults to `%APPDATA%\poe-wayfinder`. It was `.` which, for a
double clicked exe, is whatever directory Explorer happened to start it in.

### The refresh

On start, any game whose cache is more than seven days old is refreshed on a
background thread. Three requests per game to
`www.pathofexile.com/api/trade*/data/{stats,items,static}`, GGG's own endpoints,
already on the allowlist. It never blocks startup and the result is used from
the next launch. The tray's **Rebuild data** forces it now, instead of failing
because `poe-wayfinder-datagen.exe` is not shipped beside the overlay.

`augments.ndjson` cannot be refreshed. It comes from the game bundles and no API
serves it, so the built in copy is the only source and a refresh must not delete
it. `resolve` puts the built in augments back when a cache has none.

### The substring trap

`"Path of Exile 2"` contains `"Path of Exile"`. Detection is exact equality
after trimming, in `core::controller::game_detect`. Never `contains`, never
`starts_with`. The foreground window decides when both games are open.

## Running it on Windows

`cd poe-wayfinder-app && bash hack/deploy.sh` writes
`poe-wayfinder-<commit>-<hash>.exe` to `$WIN_OUTPUT_PATH`. Never overwrite a
working exe. Smart App Control allows by hash and Rust builds are not
reproducible, so an allowed binary cannot be recovered.

SAC blocks most new unsigned builds. From WSL the symptom is
`Invalid argument`. From PowerShell it is
`An Application Control policy has blocked this file`. Roughly one in three
clears.

**Retrying is useless unless the binary actually changes.** `deploy.sh` names
the file by content hash and cargo will not relink an unchanged tree, so a
retry loop redeploys the identical blocked exe forever. Five attempts once
produced the same name five times. `touch` a source file first: the relink
moves the PE timestamp, which moves the hash.

**`deploy.sh` copies, it does not build.** Build first or you deploy the last
binary and test nothing.

```sh
cd poe-wayfinder-app
for i in 1 2 3 4; do
    touch src/bin/poe-wayfinder.rs
    cargo build --release --target x86_64-pc-windows-gnu \
        -p poe-wayfinder-app --bin poe-wayfinder || break
    cp ../target/x86_64-pc-windows-gnu/release/poe-wayfinder.exe \
        "$WIN_OUTPUT_PATH/poe-wayfinder.exe"
    bash hack/deploy.sh > /tmp/dep.log 2>&1
    name=$(grep -oE 'poe-wayfinder-[a-z0-9-]*\.exe' /tmp/dep.log | tail -1)
    (cd "$WIN_OUTPUT_PATH" && ./"$name" --list-windows >/dev/null 2>&1) && break
done
```

`--list-windows` is the cheapest thing that proves the exe is allowed to run.

Signing: self signed does not work. SAC needs a cert chaining to the Microsoft
Root Program. Azure Artifact Signing is $9.99/mo but individual onboarding is
paused and limited to US and Canada orgs. Sectigo Individual Validation at
about $220/yr plus a hardware token is the only route open from France.

## Cleaning up

`cd poe-wayfinder-app && bash hack/cleanup.sh` reports and removes nothing.
`--yes` acts. `--keep N` sets how many deployed exes survive, newest first,
default 3. `--builds` also drops the 8G cargo target directory.

It refuses to remove an exe that a `.cmd` in the deploy directory launches,
because `run-live.cmd` names one build by hash and deleting it breaks the
launcher silently. It never touches `golden-*.exe`, `data*/`, any `.cmd`, or
any log that is not from press-check.

`forge build poe-wayfinder-windows` writes `poe-wayfinder.exe` into the deploy
directory and `deploy.sh` then copies it to a hashed name, so there are always
two files per build and only the hashed one accumulates.

**Other overlays fight ours.** Discord Overlay and NVIDIA GeForce Overlay both
run as always-on-top windows. When the panel flickers or sits behind the game,
check those before suspecting this code.

## Testing without the game

`hack/press-check.sh <exe> [data-dir] [game] [item-file]` runs the whole price
check with nobody at the keyboard: press, copy, parse, filter, search.

It works because `--fake-game` opens a window with the game's title that
answers Ctrl+C with item text. That is the whole contract the overlay has with
the game. The stand-in lives in the main binary because SAC blocks new ones.

**The stand-in answers Ctrl+C whether or not the show mods key is held.** The
overlay nests Alt around the copy so the roll ranges come with the item, and the
real game answers that. The stand-in watched for a bare Ctrl+C only, so on
2026-08-17 it stopped answering and all four press harnesses failed at the copy.
Anything that changes the key sequence changes this contract too.

Other flags: `--self-test-hook`, `--press-hotkey`, `--list-windows`,
`--check-clipboard`.

`hack/both-games-check.sh <exe>` opens a stand-in for **each** game at once and
starts the overlay with no arguments. It asserts the exe starts bare, holds both
tables, follows the foreground window, and that the follow reaches the trade
API. That last one is the point: flipping a `GameVersion` while the price
controller keeps its old `TradeUrls` looks perfect in a log and searches the
wrong endpoint. That exact bug was live for `league`.

`hack/refresh-check.sh <exe>` runs three launches: one that fetches, one that
must read the cache and must NOT fetch again, and one against a deliberately
corrupted cache that must fall back rather than refuse to start.

A low level keyboard hook sees injected input. `RegisterHotKey` does not, which
is why the hook is what makes the press path testable. Both watch the hotkey.

### The whole suite

```sh
bash hack/check-all.sh <exe>
```

Ten runs of seven harness scripts, in order, keeps going after a failure, exits
with the number that failed. press-check runs four times, once per item file. It refuses to start when a real Path of Exile window is open,
because the harnesses open stand-ins carrying the game's own title and inject
keys at whatever holds the foreground. `--anyway` overrides that, `--only NAME`
runs one.

It kills leftover overlays between harnesses as well as before. Each harness
traps for itself, but a harness killed from outside never reaches its own trap.

Read the exit code from `PIPESTATUS[0]`, never `$?`, when a harness is piped
through `tee`. `$?` is tee's and is always 0, which makes every harness pass.

An empty data dir is the normal case: it proves the exe finds its own data.
Each item file exercises a different path. Currency goes through the exchange
and has no stat rows, `item-runable.txt` is the only one with an empty rune
socket, so it is the only one that can prove the item editor works.

press-check asserts the panel is up within 1200ms of the press, using the
`elapsed_ms` field. That is the assertion that stops the panel drifting back
behind the network.

Every harness kills `poe-wayfinder*` on entry AND from a `trap ... EXIT`, so an
interrupted run cleans up after itself. `hack/harness.sh` holds that, the
bounded waits and the shared assertions, so the rules live in one copy.

**`hack/harness-lint.sh` is the one gate worth automating.** It is hermetic,
needs no Windows and no network, and runs in a second. It checks every message
a harness greps for still exists in the Rust source. Rename a log line and
every assertion built on it silently becomes a grep for a string that cannot
appear, and the suite goes green while testing nothing.

**No end-to-end harness belongs in `forge test-all`.** They need a Windows host,
six of them hit GGG, and the rate limiter is not optional. A gate that fires
them on every change is a ban risk.

### Looking at the UI

`hack/shot.ps1 -Out <path> -Wait <seconds>` captures the screen from WSL. Use
it rather than shipping a window unseen: the splash shipped twice, once as a
deadlock and once as a white square, because it was never looked at.

**Check what is on screen before capturing.** One capture caught a live game
session rather than the overlay.

## Windows traps, all measured

- Windows never repaints a hidden window. eframe runs the frame loop from a
  repaint, so hiding the overlay stops the loop and kills the hotkey. Park it
  off screen instead.
- egui coordinates are logical points. Win32 reports physical pixels. At 150%
  a right anchored panel lands off screen. Divide by the scale factor.
- Moving a window also reorders it, so always-on-top is re-asserted every
  frame, not set once.
- `RegisterHotKey` and the hook both report one press, a frame apart. Coalesce
  or every check costs two searches.
- PoE2 needs borderless windowed. Exclusive fullscreen blocks any overlay.
- A windows subsystem exe launched from WSL detaches from the interop proxy, so
  `timeout` kills the proxy and the Windows process runs on forever. Every
  harness kills `poe-wayfinder*` on entry AND from a `trap ... EXIT`. Without
  the trap one orphan reached 26900 frames against a 120 second timeout, and a
  leftover overlay owns the hotkey and answers the next run's press itself.

## Editing traps that cost the most time here

**A scripted string replace that does not match fails silently.** `cargo fmt`
runs in the `format-code` build step and reflows what you were about to match,
so a `replace()` written against the old wrapping does nothing and the build
still succeeds. **Grep for the new text after every scripted edit.** Half a
dozen edits in one session were silently lost this way, including two whole
match arms.

**Replace by line range, not by long literal**, once a block is bigger than a
few lines.

**Commit before a wide edit.** One over-wide slice deleted `follow_game` and
`git show HEAD:<path>` put it straight back. That is the only reason it cost
minutes rather than an hour.

## Trade API traps

- Property filters are `item.armour`, `item.evasion_rating`,
  `item.energy_shield`, never `pseudo.pseudo_total_*`.
- They must not travel in `stats`. The answer is
  `Unsupported stat domain provided`.
- PoE2 groups them under `equipment_filters`. PoE1 splits them into
  `armour_filters` and `weapon_filters`. The wrong shape is refused outright.
- `rune_sockets`, `spirit`, `reload_time` are PoE2 only.
- **An internal id must never reach the wire.** `item.has_empty_modifier` is
  upstream's own marker, not a filter. It is translated into a count group of one
  over the pseudo stat for the empty slot, and the marker is stripped before the
  request. Sending it answers `Invalid filter: has_empty_modifier` and the whole
  search fails, for every craftable rare and magic item. A unit test asserted the
  broken shape, so only the end to end harness against the real API caught it.
- Guarded by `poe-wayfinder-core/tests/upstream_property_ids.rs`, which reads the
  ids out of both reference checkouts.
- thiserror Display prints only the outermost message. Render the chain with
  `util::error_chain::render` or the cause is lost.

## Overlay UX, ported from the reference

`core::controller::overlay_lifecycle` holds the state machine, from
`WidgetAreaTracker.ts` and `OverlayVisibility.ts`:

- opens not interactive, so the first click still reaches the game
- mouse moves more than ~38px from where you pressed, it closes
- mouse enters the panel, it becomes interactive
- mouse leaves it, the game gets clicks back
- holding the hotkey's modifier suppresses the close
- Alt alone hides everything after 85ms interactive, 275ms watching, because
  Alt is the game's show-modifiers key
- Escape and click outside close it

## UI parity is measured too

```sh
cd poe-wayfinder-app && forge test run uiparity
```

`poe-wayfinder-uiparity` holds a catalogue of what the user can do, each entry
naming the upstream `.vue` it came from. An entry counts only when **both**
halves are present: domain code somewhere in the workspace, and a symbol used
inside `src/driver/`. Domain code nobody can reach does not count.

The floor is 100. Ten entries are waived, each with a reason: everything that
needs a third party or a CDN image.

Function parity read 100% while half the panel was missing, because a ported
function nobody calls still counts as ported. This stage is what catches that.

## No unwired code

The `architecture` stage fails on any `pub fn` that no production code calls.
It reads both crates. It read 100 percent while 53 functions were dead, because
the checker counted a name inside a string literal as a caller, and counted a
bare word that matched a struct field as one too. `finished()` passed on the log
line "price check finished". `bounds::negate` passed on a field called `negate`.

All 53 are resolved as of 2026-08-17. Most became real behaviour. Four are
waived in `WAIVED` with a reason, because the only thing upstream calls them
from is a feature we do not offer.

A helper used only inside its own file should not be `pub`. A helper used
nowhere is either wired or it is a parity fiction.

## The filter panel

`core::controller::filter_view` is the editable view of a `TradeQuery`, ported
from `FiltersBlock.vue`, `FilterModifier.vue` and `FilterBtnNumeric.vue`.

`build(check)` turns a `PriceCheck` into rows. `apply(view, query)` folds the
edits back. Both are pure, so the whole filter block is unit tested without a
window.

Three kinds of row:

- **stat**, one per trade filter, labelled with the line the game printed,
  carrying the roll and the bounds of its tier
- **numeric**, one per item property the trade site can filter on, offered even
  when nothing constrains it yet so the user can turn it on
- **flag**, corrupted, mirrored, veiled and the rest. Left click toggles it,
  right click flips it to "not"

A row that is off writes an empty range rather than being dropped, so turning
it back on restores what it had.

Labels and rolls come from `StatFilters::sources`, filled in by
`build_stat_filters` at the same place each filter is built. The trade id alone
cannot be turned back into readable text, so anything that adds a filter must
add its source beside it or the row shows a raw id.

`press-check.sh` asserts `stat_rows` on the `price check finished` line. A panel
that finishes with no rows is a panel nobody can adjust, and no unit test sees
it. Its item files live in `hack/items/` and are copied next to the exe.

## The item editor

`core::controller::item_editor` sockets a rune or soul core into the item
before searching, from `ItemEditor.vue`. `preview_filters` raises the filter the
augment would grant, `FilterEdit` keeps the original so it can be taken back off.

The augment data is not in GGG's API. It comes from the game bundles, which is
what the reference generates with its Python pipeline. `poe-wayfinder-datagen
--augments-only <data-dir>` reads the reference checkout and writes
`augments.ndjson`. 253 records. Without that file the picker offers nothing and
everything else still works.

The filter id is the **trade id**, never the stat text. `AugmentEffect` carries
both because the text is what the user reads and the id is what the site
searches.

An item whose sockets already hold runes has no empty socket, so it is offered
nothing. That is why the harness has `item-runable.txt`, the same armour with
the rune line removed.

## Prices without a third party

`core::controller::price_summary` computes the estimate from the listings the
trade site already returned. Median of the most common currency, with prices
more than 4x the median dropped once there are at least five of them.

Upstream's prediction calls poeprices.info. This needs no one.

The listings come from the fetch endpoint for a search, and from the search
response itself for an exchange, because a bulk exchange returns its offers
inline. Getting that wrong showed as currency having a count but no price.

## The trade API decides what "no filter" means, and it is never what you want

**An empty `have` list on an exchange means "price it in anything".** The trade
site answered an Orb of Augmentation in tier 3 waystones, so the panel read
`~99 waystone-3`. `bulk::currencies_to_price_in` names exalted or divine for
PoE2, chaos or divine for PoE1, and never prices a currency in itself.

**The league must be asked for, not defaulted.** It defaulted to `Standard`
and the only thing that could change it was `league_from_whisper`, which needs
a trade whisper in Client.txt. A player who has not been whispered a trade had
every item priced against Standard, where dead listings sit at absurd prices,
and nothing in the log said it was a guess. An empty `league` now means "read
the trade site's own league list"; naming one still pins it.

Both bugs looked like bad prices and were bad requests. **Log the request
before blaming the answer.**

## Windows deploy loop, two ways it wastes minutes

**A running overlay holds the exe.** `cp` onto it fails with
`Permission denied`. Kill `poe-wayfinder*` before deploying, every time.

**`hack/deploy.sh` and the relink loop only work from `poe-wayfinder-app/`.**
Run them from the workspace root and `touch src/bin/poe-wayfinder.rs` fails,
so cargo never relinks, so the hash never changes, so the retry loop redeploys
the same blocked binary until it gives up.

## Never compute screen coordinates in a harness

The rect on a log line is in **logical points**. `--move-mouse` takes logical
coordinates and scales them by the real DPI. Aiming at a logged rect centre of
1282,912 put the cursor at 1923,1368 on a 150% display.

Prefer an assertion that needs no pointer at all. The locked hotkey
(`Ctrl+Alt+D`) focuses the panel deliberately, with no mouse involved, which is
the deterministic way to reproduce a focus bug.

## cargo test is not the gate. forge test-all is.

Three stages were red on a commit that had passed `cargo test --workspace`
and the Windows cross build. `lint`, `architecture` and `uiparity` all failed
and none of them runs under cargo. **Run `forge test-all` in every touched repo
before saying anything is done.** The rule was already written down. It was
skipped because the tests were green, which is exactly when it feels safe.

**Deleting a function can break two stages at once.** Removing `fn checkbox`
stranded `roll_caption` with no production caller, which failed `architecture`,
and left the uiparity catalogue naming a symbol that no longer existed, which
failed `uiparity`. Grep for the name of anything you delete, in `src/` and in
`poe-wayfinder-uiparity.rs`.

**Fixing a sentinel at one call site moves it, it does not close it.** The
`f64::INFINITY as i64` fix landed on `overlay_ui_driver::format_value` while
`filter_view::modifier_text` renders the line the user actually reads, and kept
printing `9223372036854775807`. Fix the cast everywhere it appears, then grep
for `as i64`, `as usize` and `as u32` on a float to prove it.

## A harness that has never been run is not a test

`press_until` could never return true, so `focus-check` and `exchange-check`
failed on every run. Both were written, reviewed and committed without once
being executed.

```sh
count=$(grep -c "$needle" "$log")     # prints 0 AND exits 1 when nothing matches
count=$(grep -c "$needle" "$log" || echo 0)   # so this yields "0\n0"
```

The two line string then aborts every `[ "$a" -gt "$b" ]` with
`integer expected` and return code 2, which reads as false forever. Use
`count=${count:-0}` and never `|| echo 0` after `grep -c`.

**Assert on the wire, not on a re-derivation.** `exchange-check` reads a log
field that the driver computes by calling the same function the request
builder calls, separately. Delete the argument from the request and every
assertion still passes.

**An assertion slower than the run it lives in can never pass.** press-check
greps for the frame heartbeat to prove the loop still ticks. The heartbeat fired
every 600 frames, which at a 100ms frame is 60 seconds, and the harness finishes
in 10. It failed on every run since it was written. It is every 20 frames now.
When a harness asserts on something periodic, compare the period against the
length of the run.
