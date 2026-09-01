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
