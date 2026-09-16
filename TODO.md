# TODO

What is open in Memini, and what to re-check against the standard.

The standard is
[standardizer_multiplatform](https://github.com/iezappa/standardizer_multiplatform).
It is the canonical copy: the `Estandarización/` folder here is a working
copy, ignored by git, and loses to that repository on any disagreement.

Last checked against it: **2026-09-01**.

---

## Open

- [ ] The integration test boots the app and walks the bottom bar. The flow
      worth adding next is a title looked up and saved.

      Not the PIN, yet. `flutter_secure_storage` needs the
      `org.freedesktop.secrets` daemon at runtime, and there is none on WSL or
      on `ubuntu-latest`. Installing `libsecret-1-dev` is enough to link the
      Linux build and not enough to run it, so the test would fail on the
      environment rather than on the code. It needs gnome-keyring started and
      unlocked in the workflow first. The widget tests cover the lock screen
      itself in the meantime.

- [ ] Settings tells the owner to paste a TMDB or RAWG key but offers no way to
      get one. A `settingsGetKey` string existed for exactly this and was never
      wired to anything; it was removed with the rest of the dead copy, so this
      line is the only record left that the affordance is missing.

- [ ] **Pick the lookup sources.** The forms use TMDB and RAWG, both of which
      need a key the owner has to register for, and settings offers no way to
      get one. Keyless alternatives were tested against the live endpoints:

      | Domain | Keyless option | Verdict |
      |---|---|---|
      | Series | TVmaze | Clean win. Public, documented, no key. Returns summary, genres, image and cast. |
      | Games | Steam storefront | Trade-off. No key, rich data, but only Steam's catalogue: "zelda tears of the kingdom" and "bloodborne" both return zero. RAWG has them. |
      | Films | IMDb suggestion | Works, posters included, but it is imdb.com's own undocumented search endpoint — unsupported and outside their terms. |
      | Films | Wikidata | Clean and open, descriptions even come in Spanish, but P18 is empty for most films (posters are under copyright), so no cover art. |
      | Concerts | MusicBrainz | Already keyless. Nothing to change. |

      iTunes Search was tried and dropped: zero results on every query.

      The shape that fits what is already built: `EnrichmentSuggestion` is a
      port with swappable sources, so the keyless ones can be the default and
      TMDB/RAWG stay an optional upgrade. The app would then work on install
      with no key at all, and a key would buy console coverage and guaranteed
      posters. That also closes the missing "get a key" affordance above.

- [ ] **P1 — Create the release keystore and record its fingerprint.**
      `docs/SIGNING.md` still says `SHA-256: PENDING`; until it is filled in,
      `tool/release_apk.sh` stops after printing the certificate it built with.
      The failing release build without `key.properties` has not been run
      here (no Android SDK on the machine that made the change).

- [ ] **P1 — Check the data-safety flows in a real browser.** The storage
      banner, `navigator.storage.persist()`, and saving/picking the `.zip`
      backup through `share_plus` / `file_picker` on the web are covered by
      widget tests with fakes only. Walk them on the published site.

- [ ] **P1 — Release workflow.** GitHub releases are still created by hand
      (`docs/RELEASING.md`), and CI does not run `tool/release_apk_test.sh`.

- [ ] **P2 — Integration coverage for erase and import.** Both are widget-
      and unit-tested; neither is driven end to end on a real database file.

- [ ] **P2 — Backup memory use.** The zip is built and read in memory, photos
      included. Fine for a personal log; a very large photo library would want
      a streamed archive.

- [ ] **P2 — Franchise logos in the backup.** `logoPath` still travels as a
      device path; nothing in the app sets it today, so no file is copied.

## Resolved

- [x] **P0 — Release signing.** Releases are signed with a fixed keystore and
      the build refuses to produce one without `android/key.properties`
      (`docs/SIGNING.md`, `docs/RELEASING.md`, `tool/release_apk.sh`).
- [x] **P0 — Web storage durability.** The storage drift lands on is reported,
      a banner warns on IndexedDB or memory, and persistence is requested.
- [x] **P0 — A store that will not open.** A recovery screen offers importing a
      backup or resetting the database, both confirmed, never automatic.
- [x] **P0 — Backup notice (§5.A).** Acknowledged in onboarding, shown once to
      existing users, always visible in Settings → Your data.
- [x] **P0 — Export reminder.** After 30 days without an export (or never,
      once there is data), snoozable for 7 days.
- [x] **P0 — Delete all my data.** Typed confirmation, export first, wipes
      tables, photos, PIN and every preference but language/theme/accent.
- [x] **P0 — Export before import.** The import confirmation offers it.
- [x] **P0 — Photos in the backup.** One `.zip` with `backup.json` and
      `photos/`; old plain JSON backups still import.

---

## To re-check against the standard

Not a list of known faults — a list of what drifts silently. Walk it when the
standard changes, or before a release.

- [ ] **§2.2 Settings layout.** One flat column, sections in the fixed order,
      no card per section, every `ListTile` at `contentPadding: EdgeInsets.zero`,
      the disclaimer printed in full. `test/features/settings/settings_screen_test.dart`
      asserts this, so a drift fails the suite rather than waiting to be noticed.
- [ ] **§2.1 Product patterns.** i18n through ARB files, onboarding shown once,
      local PIN, disclaimer and backup notice accepted at onboarding and visible
      in settings, backup import/export (zip with photos; plain JSON still
      imports), export reminder, delete all data.
- [ ] **§5 CI.** `ci.yml` runs format, analyse, test and a web build. Add a
      platform to the matrix when a new target starts shipping.
- [ ] **§7 Testing.** Widget tests for the screens, `integration_test` for the
      critical flows.

A change decided here and not carried back to the canonical repository is not
a standard — it is an exception the next project will never hear about.
