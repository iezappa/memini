# TODO

What is open in Memini, and what to re-check against the standard.

The standard is
[standardizer_multiplatform](https://github.com/iezappa/standardizer_multiplatform).
It is the canonical copy: the `Estandarización/` folder here is a working
copy, ignored by git, and loses to that repository on any disagreement.

Last checked against it: **2026-09-01**.

---

## Open

- [ ] The working copy under `Estandarización/` is stale — it predates §2.2,
      the settings layout. It could not be refreshed from here because the
      files belong to `root` (they arrived through the Windows mount), so it
      needs one command with privileges:

      sudo cp ~/projects/standardizer_multiplatform/*.md Estandarización/
      sudo rm -f Estandarización/*:Zone.Identifier
      sudo chown -R "$USER" Estandarización

      Until then, read the standard from the canonical repository, not from
      that folder.

- [ ] No `integration_test/`. §7 of the standard asks for critical flows
      end to end on at least one platform; the widget tests do not start the
      app.

---

## To re-check against the standard

Not a list of known faults — a list of what drifts silently. Walk it when the
standard changes, or before a release.

- [ ] **§2.2 Settings layout.** One flat column, sections in the fixed order,
      no card per section, every `ListTile` at `contentPadding: EdgeInsets.zero`,
      the disclaimer printed in full. `test/features/settings/settings_screen_test.dart`
      asserts this, so a drift fails the suite rather than waiting to be noticed.
- [ ] **§2.1 Product patterns.** i18n through ARB files, onboarding shown once,
      local PIN, disclaimer accepted at onboarding and visible in settings,
      JSON import/export.
- [ ] **§5 CI.** `ci.yml` runs format, analyse, test and a web build. Add a
      platform to the matrix when a new target starts shipping.
- [ ] **§7 Testing.** Widget tests for the screens, `integration_test` for the
      critical flows.

A change decided here and not carried back to the canonical repository is not
a standard — it is an exception the next project will never hear about.
