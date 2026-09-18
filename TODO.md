# TODO

What is open in Memini, and what to re-check against the standard.

The standard is
[standardizer_multiplatform](https://github.com/iezappa/standardizer_multiplatform).
It is the canonical copy: the `Estandarización/` folder here is a working
copy, ignored by git, and loses to that repository on any disagreement.

Last checked against it: **2026-09-17**.

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
      | Series | TVmaze | Clean win. Public, documented, no key. Returns summary, genres and cast. |
      | Games | Steam storefront | Trade-off. No key, rich data, but only Steam's catalogue: "zelda tears of the kingdom" and "bloodborne" both return zero. RAWG has them. |
      | Films | IMDb suggestion | Works, but it is imdb.com's own undocumented search endpoint — unsupported and outside their terms. |
      | Films | Wikidata | Clean and open, descriptions even come in Spanish. |
      | Concerts | MusicBrainz | Already keyless. Nothing to change. |

      iTunes Search was tried and dropped: zero results on every query.

      The shape that fits what is already built: `EnrichmentSuggestion` is a
      port with swappable sources, so the keyless ones can be the default and
      TMDB/RAWG stay an optional upgrade. The app would then work on install
      with no key at all, and a key would buy console coverage. That also closes the missing "get a key" affordance above.

- [ ] **P1 — Create the release keystore and record its fingerprint.**
      `docs/SIGNING.md` still says `SHA-256: PENDING`; until it is filled in,
      `tool/release_apk.sh` stops after printing the certificate it built with.
      The failing release build without `key.properties` has not been run
      here (no Android SDK on the machine that made the change).

- [ ] **P1 — Check the data-safety flows in a real browser.** The storage
      banner, `navigator.storage.persist()`, and saving/picking the JSON
      backup through `share_plus` / `file_picker` on the web are covered by
      widget tests with fakes only. Walk them on the published site.

- [ ] **P1 — Walk the service worker checklist (§8.2) on the published site.**
      `tool/generate_sw_test.sh` only reads the generated `web/sw.js` as text:
      it proves the version and the precache manifest were injected, and
      nothing about what a browser does with them. There is no browser
      harness and none is planned for now, so these four are manual, in
      order, on the published site:

      1. **Offline launch.** Load the site, then go offline (DevTools →
         Network → Offline, or airplane mode) and reload. The shell and its
         fonts must come up from the cache, with no network error page.
      2. **Update and reload.** Publish a build with a new version, reload
         once: the update banner appears, and the reload it offers lands on
         the new version — not the cached old one.
      3. **iOS add to Home Screen.** Safari → Share → Add to Home Screen,
         launch from the icon: standalone, correct name and icon, and it
         still opens offline after step 1.
      4. **Kill-switch drill.** Serve `web/sw-killswitch.js` in place of
         `sw.js`, reload twice, and confirm the worker unregisters and the
         caches are emptied — the way out if a bad worker ships.

- [ ] **P1 — First tagged release.** `release.yml` is YAML-valid but has never
      run. Its new `check` job (format, analysis, tests, script tests) has not
      run on a tag either, only its steps as ci.yml runs them. The Windows
      and macOS runners were generated for it and never built here, the
      pinned `ghcr.io/cirruslabs/flutter:3.47.1` tag is assumed to
      exist, and the Docker image and nginx config were not built or run (no
      Docker daemon access). 1.1.0 is prepared (`update.json` says
      `schemaChange: true`) but not tagged.

- [ ] **P1 — Load the Content-Security-Policy in a browser.**
      `deploy/nginx.conf` now sends a CSP, `X-Frame-Options: DENY` and
      `Referrer-Policy: no-referrer`. The policy was reasoned from what the
      build contains; neither nginx nor a Docker daemon is reachable here, so
      it has never been served. Serve the image, watch the console for
      "Refused to ...", and walk one lookup per source (TMDB, RAWG,
      MusicBrainz) plus a title in a script the bundled fonts do not cover,
      which is what `fonts.gstatic.com` is in the policy for.

- [ ] **P2 — macOS keychain.** The sandboxed macOS build has the network
      entitlement for lookups and the update check; whether
      `flutter_secure_storage` (the PIN) needs a keychain entitlement there is
      unverified.

- [ ] **P2 — Support card title (§2.2).** `SupportProjectsCard` still prints
      its own title under the SUPPORT label, which the standard asks to drop.

- [ ] **P2 — Schema v1 dump is reconstructed.** No commit ever had
      `schemaVersion` 1; `drift_schema_v1.json` is v2's franchises and rooms,
      which is what the v1 → v2 migration assumes. If a real v1 store had a
      different rooms table, only a real v1 file would show it.

- [ ] **P2 — Integration coverage for erase and import.** Both are widget-
      and unit-tested; neither is driven end to end on a real database file.

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
      tables, PIN and every preference but language/theme/accent.
- [x] **P0 — Export before import.** The import confirmation offers it.
- [x] **Photos removed.** Memini keeps no photos. Schema v3 drops every
      `photo_path` and deletes the old `room_photos` folder once; backups are
      plain JSON again, and older ones that still name a `photoPath` import
      with the field ignored.
- [x] **Legal (§2.3).** `PRIVACY.md` and `TERMS.md` (EN at the root, ES as `.es.md`, EN/ES
      bundled and readable offline), disclosing the lookups; ABOUT carries
      privacy, terms, developer contact (the issue tracker) and licences,
      including the bundled fonts' OFL.
- [x] **Accessibility (CUMPLIMIENTO 1.4).** `meetsGuideline` for tap targets,
      labels and contrast on settings and the main screens, light and dark
      (`test/accessibility/`). Fixed: 40 px accent swatches, invisible menu
      chip labels, and the selected-segment contrast.
- [x] **UUID + updatedAt (§1.1).** Schema v4, migration tested from v1, v2 and
      v3 with relation integrity; backup format v3, v1/v2 files remapped.
- [x] **Updates and What's new (§8.2).** GitHub Releases on native (6 h
      throttle), `version.json` + waiting service worker on the web, banner
      with backup hint on `schemaChange`; bundled release notes per version,
      asserted against pubspec.
- [x] **Own service worker (§8.2)**, wired into Pages, the release web zip and
      the Docker image.
- [x] **Release workflow (§5.A)** with version, release-notes and compliance
      checks; GHCR image `ghcr.io/iezappa/memini`; ZimaOS compose and guide.

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
      in settings, backup import/export (plain JSON), export reminder, delete all data.
- [ ] **§5 CI.** `ci.yml` runs format, analyse, test, the shell script tests
      and a web build; `release.yml` builds Linux, Windows, macOS, web and the
      image from a tag.

**§2.2 Ajustes** — Conforme: sí, with the support-card title open (P2 above) ·
Última revisión: 2026-09-17 · Afirmado por:
`test/features/settings/settings_screen_test.dart`,
`test/features/settings/settings_about_test.dart`,
`test/accessibility/main_screens_accessibility_test.dart`
- [ ] **§7 Testing.** Widget tests for the screens, `integration_test` for the
      critical flows.

A change decided here and not carried back to the canonical repository is not
a standard — it is an exception the next project will never hear about.
