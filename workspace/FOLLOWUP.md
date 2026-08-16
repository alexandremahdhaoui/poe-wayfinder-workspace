# FOLLOWUP

## Mission

Make PoE Wayfinder good enough that a player keeps it open while playing.
Price check an item fast. Read the answer. Adjust it. Never fight the overlay.

## Now

- [ ] Hold the show mods key while copying. `keys_to_hold_for_copy` and
      `show_mods_key` are ported, tested, and called by nothing. The overlay
      reads the key, logs it, then never holds it. Every price check loses
      roll ranges, for every player. Found 2026-08-15.
- [ ] Fix the `architecture` stage blind spot that hid it. A name written as
      a string in the parity alias table counts as a caller.

## Next

- [ ] Run `bash hack/check-all.sh <exe>` on Windows with the game closed.
      No harness has ever run end to end. Two shipped permanently broken.
- [ ] Look at the panel on screen. Nothing in the last two days was seen.
      The mod line toggle, the gauge, the greying are all unverified.
- [ ] Build the loot filter feature. `docs/loot-filters/` holds scope and
      experience. Local files only. No third party.

## Waiting on a human

Delete an entry here once the user confirms it works in the game.

- [ ] The pad drives the panel end to end in a real game. A DualSense was
      confirmed on 2026-08-17: enumerated, every button decoded, the chord
      fired, the panel navigated, closed and handed the game back. What is
      unconfirmed is a whole session in PoE2 with the game reacting to the
      same buttons.
- [ ] The DualShock 4 path. Written from SDL, never run. Nobody here has one.
- [ ] Panel stays put and its buttons take clicks.
- [ ] League and game swap from the status window with no restart.
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

- L1+R1+Triangle is the default chord, on out of the box. 2026-08-17. The
  game acts on those buttons too and always will.
- No third party crate reads a pad. We call hid.dll and setupapi.dll
  ourselves, as hidapi would. 2026-08-16.
- The XInput adapter was built rather than Steam Input documentation, on
  2026-08-15. Windows cannot hide a pad button from the game and Steam Input
  takes the pad when it runs. Both accepted. `docs/controllers/scope.md`.
- filterblade.xyz stays out. Local files only. 2026-08-14.
- No end to end harness in `forge test-all`. They need Windows and hit GGG.
- `hack/logo.py` and `png.py` are untracked and stay on disk.
