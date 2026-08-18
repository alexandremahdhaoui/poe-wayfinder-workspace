# FOLLOWUP

## Mission

Make PoE Wayfinder good enough that a player keeps it open while playing.
Price check an item fast. Read the answer. Adjust it. Never fight the overlay.

## Now

- [ ] Exclude `unit-windows` and `windows-smoke` from the generated CI. Both
      need a Windows host and WSL interop, so both are green here and red on
      a Linux runner. Added 2026-08-16.

## Next

- [ ] Run `bash hack/check-all.sh <exe>` on Windows with the game closed.
      Only `pad-check` has ever run, on 2026-08-17. The other nine have not
      run since `attach_console`, the paint signature, the close button and
      the game window adapter all changed under them.
- [ ] Make the parity stages fail when there is no `reference/` checkout.
      A fresh clone printed "no reference checkout" four times and passed, so
      CI would report 100 percent while measuring zero functions. Proven on a
      clone of main, 2026-08-16.
- [ ] Look at the mod line toggle, the gauge and the greying on screen. The
      panel itself was seen on 2026-08-17 and the pad drove it, but those
      three were not exercised.
- [ ] Build the loot filter feature. `docs/loot-filters/` holds scope and
      experience. Local files only. No third party.

## Waiting on a human

Delete an entry here once the user confirms it works in the game.

- [ ] The five behaviours wired out of dead code on 2026-08-17, none seen in
      the game: a Price button on a search hit, the maps tab warning about
      decisions the data no longer has, the line saying what an item gained
      and lost since the last check, the span on a property row, and a
      Mageblood asking for the legacies it cannot print.
- [ ] The redesigned panel, 2026-08-18. Photographed at every step and all ten
      harnesses pass, but nobody has played with it. The pad rail, the greyed
      rows, the leader lines and the new tab strip are all unseen in a real
      session.

- [ ] A whole PoE2 session on a pad. Confirmed on 2026-08-17: the DualSense
      enumerated, every button decoded against its own report descriptor, the
      chord fired, the dpad and the stick navigated, and Circle closed it.
      Unconfirmed is living with it while the game acts on the same buttons.
- [ ] The focus outline is visible enough to follow. Nobody has said.
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
- Stash scroll. Hold Ctrl and roll the wheel to flip stash tabs, skipped when
  the cursor is over the grid. Dropped 2026-08-17 rather than faked: it needs a
  WH_MOUSE_LL hook, which sees every wheel event on the desktop, and a
  stash_scroll config key. The grid test was ported and is now waived in
  parity. Reopen the whole thing together.

## Decided

- L1+R1+Triangle is the default chord, on out of the box. 2026-08-17. The
  game acts on those buttons too and always will.
- No third party crate reads a pad. We call hid.dll and setupapi.dll
  ourselves, as hidapi would. 2026-08-16.
- The XInput adapter was built rather than Steam Input documentation, on
  2026-08-15. Windows cannot hide a pad button from the game and Steam Input
  takes the pad when it runs. Both accepted. `docs/controllers/scope.md`.
- filterblade.xyz stays out. Local files only. 2026-08-14.
- No end to end harness in `forge test-all` if it hits GGG or needs the game.
  `windows-smoke` is in because it is hermetic: no network, no game window,
  no key press. 2026-08-16.
- A pad script counts in polls of the frame loop, never in seconds, so a
  harness means the same thing on a slow machine. 2026-08-17.
- `hack/logo.py` and `png.py` are untracked and stay on disk.
- The panel has one token set and one style pass as of 2026-08-18. Colours are
  not picked at call sites. Gold is focus, teal is a value in use, ember is an
  unsent change.
- Every public function has a caller as of 2026-08-17. 53 were dead when the
  `architecture` blind spot was fixed. All are wired, or waived in `WAIVED`
  with the reason. `likelyFinishedItem` is the last waive: it gates a second
  search preset we do not offer.
