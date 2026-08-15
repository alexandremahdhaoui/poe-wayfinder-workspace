# FOLLOWUP

## Mission

Make PoE Wayfinder good enough that a player keeps it open while playing.
Price check an item fast. Read the answer. Adjust it. Never fight the overlay.

## Now

- [ ] Switch league and game from the UI, with no restart. Agent building it.
- [ ] Research controller support for price check shortcuts. Agent running.

## Next

- [ ] Run `bash hack/check-all.sh <exe>` on Windows with the game closed.
      No harness has ever run end to end. Two shipped permanently broken.
- [ ] Look at the panel on screen. Nothing in the last two days was seen.
      The mod line toggle, the gauge, the greying are all unverified.
- [ ] Build the loot filter feature. `docs/loot-filters/` holds scope and
      experience. Local files only. No third party.

## Waiting on a human

Delete an entry here once the user confirms it works in the game.

- [ ] Panel stays put and its buttons take clicks.
- [ ] A filter row switches off and stays off.
- [ ] Numbers read as numbers. No `9223372036854775807`.
- [ ] The gauge sets a value by click and by drag.
- [ ] Prices come from the played league, not Standard.
- [ ] Currency prices read in exalted or divine, not `waystone-3`.

## Deferred

- Fetch the league for a game switched to for the first time. It needs a
  background thread and a channel. Today it keeps the current league and
  warns.
- Install `shellcheck` and add it to `hack/harness-lint.sh`. Needs sudo.

## Decided

- filterblade.xyz stays out. Local files only. 2026-08-14.
- No end to end harness in `forge test-all`. They need Windows and hit GGG.
- `hack/logo.py` and `png.py` are untracked and stay on disk.
