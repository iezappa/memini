# Memini

[![CI](https://github.com/iezappa/memini/actions/workflows/ci.yml/badge.svg)](https://github.com/iezappa/memini/actions/workflows/ci.yml)

A personal log of the things you have actually done — escape rooms, meals out,
concerts, films and series, and games — each with a score and your own review.

- **Downloads:** https://github.com/iezappa/memini/releases/latest
- **Web version (iPhone, iPad and any browser):** https://iezappa.github.io/memini/

> [!WARNING]
> **Your data lives ONLY on your device.**
>
> - It is not stored on the developer's servers, nor on any server that delivers the web version: those only hand out the app.
> - If you uninstall the app, lose or reset the device, or clear your browser or Safari data, **your data is gone for good**.
> - The only backup is the one you make.
>
> **Back up often (a weekly habit is a good one):**
>
> 1. Open the app → **Settings** → **Your data** → **Export backup (JSON)**.
> 2. Keep the `.json` file somewhere **off this device**: iCloud Drive, Google Drive, OneDrive, an email to yourself or another device.
>
> **To get your data back** (new device, reinstall):
>
> 1. Install the app and open it.
> 2. **Settings** → **Your data** → **Import backup** → pick your latest `.json` file.
> 3. Confirm. What is in the file replaces what is in the app.

## Contents

- [Own server (ZimaOS)](#own-server-zimaos)
- [Windows](#windows)
- [Ubuntu (Linux)](#ubuntu-linux)
- [macOS](#macos)
- [iPhone and iPad](#iphone-and-ipad)
- [Android](#android)
- [Updates](#updates)
- [Privacy](#privacy)
- [For developers](#for-developers)

---

## Own server (ZimaOS)

Only **whoever runs the server** needs this; everyone else skips to their device.

The server publishes the web version so the family can use it in a browser or install it as an app (PWA). In short:

1. A version tag (`vX.Y.Z`) makes GitHub build `ghcr.io/iezappa/memini`. The first time, make the package public on GitHub.
2. Import `deploy/docker-compose.yml` (already filled in; port 8082) in ZimaOS: **App Store** → **+** → **Install a customized app** → **Import**.
3. Install **Tailscale** on ZimaOS, enable HTTPS and expose the app with `tailscale serve`. It is then at `https://<server>.<tailnet>.ts.net/`.
4. Everyone installs Tailscale on their device and joins the tailnet.

**Full guide:** [`deploy/ZIMAOS.md`](deploy/ZIMAOS.md), including why the lookups keep working behind the container's isolation headers.

**Your data:** updating, reinstalling or removing the container does **not** touch anyone's data, because none of it is on the server. Always use **the same URL**, at home too: through the LAN IP the browser sees another site and the app looks empty.

---

## Windows

**Requirements:** 64-bit Windows 10 or 11.

**Install:**

1. Go to https://github.com/iezappa/memini/releases/latest.
2. Under **Assets**, download `memini-vX.Y.Z-windows-x64.zip`.
3. Right-click the `.zip` → **Extract All** → choose a permanent folder, such as `Documents\Memini`. Do not run it from inside the `.zip`.
4. Open the folder and double-click `memini.exe`.
5. Windows shows **"Windows protected your PC"** because the app is unsigned. Click **More info** → **Run anyway**. Only the first time.

> Keep the other files next to the `.exe` (`.dll` files, the `data` folder): it needs them.

**Update:** back up (**Settings → Your data → Export backup (JSON)**), close the app, and extract the new `.zip` **into the same folder**, replacing the files.

**Your data:** kept in your Windows user profile, outside the app folder, so replacing the folder does not erase it. Formatting the PC or changing Windows user does.

---

## Ubuntu (Linux)

**Requirements:** 64-bit (x86_64) Ubuntu 22.04 or later. There is no ARM build.

**Install:**

1. System libraries, once (`libsecret` holds the PIN):

   ```bash
   sudo apt update
   sudo apt install libgtk-3-0 libsecret-1-0
   ```

2. Download `memini-vX.Y.Z-linux-x64.tar.gz` from https://github.com/iezappa/memini/releases/latest.
3. Extract it to a permanent folder and run it:

   ```bash
   mkdir -p ~/Apps/memini
   tar -xzf ~/Downloads/memini-vX.Y.Z-linux-x64.tar.gz -C ~/Apps/memini
   ~/Apps/memini/memini
   ```

**Update:** back up, close the app, empty `~/Apps/memini` and extract the new `.tar.gz` there.

**Your data:** kept under your home folder (normally `~/.local/share/`), not in `~/Apps/memini`. Reinstalling Ubuntu or deleting your home folder erases it.

---

## macOS

**Requirements:** a Mac with a recent macOS (Intel or Apple Silicon).

**Install:**

1. Download `memini-vX.Y.Z-macos.zip` from https://github.com/iezappa/memini/releases/latest.
2. Double-click the `.zip` and drag the app into **Applications**.
3. The app is unsigned, so macOS blocks it the first time: **right-click** (or Control-click) → **Open** → **Open**. If that option is missing, try to open it, then **System Settings** → **Privacy & Security** → **Open Anyway**.
4. If macOS says the app **"is damaged"**, run in **Terminal**:

   ```bash
   xattr -dr com.apple.quarantine "/Applications/memini.app"
   ```

**Update:** back up, close the app, replace it in **Applications** with the new one and repeat step 3 if needed.

**Your data:** kept in your macOS user (under `~/Library`), not inside the app. Deleting your user or resetting the Mac erases it.

---

## iPhone and iPad

There is no App Store version. You use the **web version added to the Home Screen**, which behaves like an app. **It works offline after opening it once with a connection** (close it and open it again before trying offline).

**Requirements:** iOS or iPadOS 17 or later (recommended), **Safari**.

**Install:**

1. Open **Safari** (it has to be Safari).
2. Go to https://iezappa.github.io/memini/.
3. Tap **Share** (the square with an arrow).
4. Tap **Add to Home Screen** → **Add**.
5. **Always open Memini from that icon**, never from a Safari tab.

> The icon and a Safari tab keep separate data. Safari may also clear the data of sites you have not used for days; an icon you use regularly is not cleared that way.

**Update:** open the app with a connection; when **"A new version is available"** shows, tap **Update**. If it does not, close the app completely and open it again.

**Your data:** kept only on this iPhone or iPad, inside the icon's app. Removing the icon, clearing website data in **Settings → Safari**, or resetting the device erases it. Removing the icon is uninstalling: **export first**.

---

## Android

Two options. Pick **one** and stay with it: the APK and the Chrome app keep separate data. To switch, export in the old one and import in the new one.

### Option 1: APK (recommended; no server, no connection needed)

**Requirements:** Android 7 or later (recommended).

**Install:**

1. On the phone, open https://github.com/iezappa/memini/releases/latest.
2. Under **Assets**, download `memini-vX.Y.Z-android.apk`. It is attached by hand shortly after each release is created; if it is not there yet, check back later.
3. Open the downloaded file. Allow installing from this source when Android asks.
4. Tap **Install**. If Google Play Protect warns, choose **Install anyway**.

**Update:** with a connection, Memini shows **"A new version is available"**. Tap **Download**, back up if the banner asks for it, and install the APK over the existing app. **Do not uninstall first**: uninstalling erases your data. Every release is signed with the same key, so it installs on top; if Android ever reports a conflict, **do not uninstall** — export your data and open an issue.

**Automatic updates (optional) with Obtainium:** install Obtainium (https://github.com/ImranR98/Obtainium/releases or F-Droid), tap **Add app**, paste `https://github.com/iezappa/memini` and tap **Add**.

**Your data:** kept inside the app. Uninstalling it, **Clear storage** in its settings, or resetting the phone erases it.

### Option 2: install from Chrome (PWA)

1. Open **Chrome** at https://iezappa.github.io/memini/.
2. Menu **⋮** → **Install app**.
3. Open it from its icon, always from the same URL.

It works offline after opening it once with a connection. **Update** with the in-app banner. **Your data** is kept by Chrome for that URL.

---

## Updates

Memini checks for a new version when it opens with a connection, and again when it comes back to the foreground (on desktop and the APK, at most every 6 hours). Offline nothing changes.

| Device | How you find out | How you update |
|---|---|---|
| iPhone and iPad | "A new version is available" | Tap **Update**. |
| Android (APK) | "A new version is available" | **Download** and install on top, or Obtainium. |
| Android (Chrome) and browsers | "A new version is available" | Tap **Update**. |
| Windows, Ubuntu, macOS | "A new version is available" | **Download** opens the release page; follow your system's **Update** steps. |

- **If the banner asks for a backup**, the new version changes how data is stored (1.1.0 does): tap **Export** and keep the file **before** updating.
- After an update, Memini shows **What's new** for that version. The full history is under **Settings → About → Version**.

---

## Privacy

Memini has no accounts, analytics or advertising. What you log stays on your device. It only goes online in two cases:

- **Lookups**, and only when you tap the lookup button in a form: the text you typed in the search box goes to TMDB (films and series, with your own TMDB key), RAWG (games, with your own RAWG key) or MusicBrainz (bands, no key). Nothing else you logged is sent. The keys you paste are stored in the app's local settings, in plain text.
- **The update check**: GitHub's releases API on desktop and Android, the site's own `version.json` on the web. It carries none of your data.

To erase everything: **Settings → Your data → Delete all my data**.

- [Privacy policy](PRIVACY.md)
- [Terms of use](TERMS.md)

Developer: Zeke Zappa Developments (iezappa) — questions and reports at https://github.com/iezappa/memini/issues

---

## For developers

Memini follows `STACK-APPS-DINAMICAS.md` (profile A) from the Estandarizador
standard. The Flutter project is in `apps/client`.

```bash
cd apps/client
flutter pub get
dart run build_runner build      # Drift generated code
flutter test
bash tool/generate_sw_test.sh
flutter run -d chrome            # or linux / windows / macos / an Android device
```

Try the web image locally:

```bash
docker build -f deploy/Dockerfile -t memini .
docker run --rm -p 8080:8080 memini    # http://localhost:8080
```

**Releasing** (details in [`docs/RELEASING.md`](docs/RELEASING.md)):

```bash
# pubspec.yaml (x.y.z+build), web/update.json and assets/release_notes/*.json
# must all name the tag's version; release.yml refuses the tag otherwise.
git tag vX.Y.Z && git push origin vX.Y.Z
```

`release.yml` builds `memini-vX.Y.Z-linux-x64.tar.gz`, `-windows-x64.zip`,
`-macos.zip`, `-web.zip`, attaches `update.json`, and pushes
`ghcr.io/iezappa/memini`. GitHub Pages is published from `master` by
`pages.yml`. The APK is not built in CI: the maintainer signs it locally with
the release keystore and uploads `memini-vX.Y.Z-android.apk` plus its `.sha256`
with `tool/release_apk.sh vX.Y.Z` (from `apps/client`). The expected
certificate fingerprint lives in [`docs/SIGNING.md`](docs/SIGNING.md) — still
pending until the keystore is created.

The web build ships its own service worker (`web/sw.js`, registered by
`web/flutter_bootstrap.js`); CI, Pages and the Dockerfile run
`tool/generate_sw.sh` after `flutter build web`. If a release breaks the
worker, publish the kill switch (`web/sw-killswitch.js`, instructions inside).

When a release changes the Drift schema: bump `schemaVersion`, dump the schema,
add the migration test, and set `"schemaChange": true` in `web/update.json` so
the update banner asks for a backup first.

### Stack

Local-first Flutter, following `Estandarización/STACK-APPS-DINAMICAS.md` for
everything that applies and deliberately dropping the parts that assume a
backend.

| Layer | Choice |
|---|---|
| UI | Flutter (Linux, Web, Android) · Material 3 with a custom theme |
| State | Riverpod |
| Navigation | go_router |
| Storage | Drift (SQLite) behind domain repositories |
| Preferences | shared_preferences · PIN hash in flutter_secure_storage |
| Lookups | TMDB, RAWG and MusicBrainz, with the owner's own keys |

There is **no backend**. NestJS, PostgreSQL, Redis, Keycloak and the
OpenAPI-generated SDK are all dropped: a single-user offline tracker has
nothing for them to do. Docker only serves the web build (`deploy/`). A remote data source can be added later behind the
existing repository ports without touching the domain.

### Standard product patterns

The five patterns from section 2.1 of the stack standard, plus the support
links from section 9:

- **i18n** — `flutter_localizations` + ARB files, Spanish and English.
- **Onboarding** — three slides on first run, re-openable from Settings.
- **Disclaimer** — explicit acceptance on first run, always visible in Settings.
- **PIN lock** — salted SHA-256 in secure storage, no biometrics-only path.
- **Import / export** — JSON is the source of truth, CSV for spreadsheets.
- **Support links** — Cafecito and Patreon, always shown side by side.

### Layout

```
apps/client/lib/
├── app/            # providers, router, MaterialApp
├── core/
│   ├── database/   # aggregates every feature's tables
│   ├── enrichment/ # TMDB / RAWG / MusicBrainz lookups
│   ├── theme/
│   └── tracking/   # the shared spine: Trackable, filters, repo port, shared UI
├── features/
│   ├── rooms/      # domain / data / presentation
│   ├── dining/
│   ├── concerts/
│   ├── screen/
│   ├── games/
│   ├── franchises/
│   ├── stats/
│   ├── backup/
│   ├── security/
│   ├── onboarding/
│   ├── settings/
│   └── shared/
└── l10n/
```

Each feature owns its Drift tables, its domain port and the adapter that
implements it. `core/database/app_database.dart` only aggregates the tables.

`core/tracking/` is what keeps five domains from being five copies: the
`Trackable` interface, `TrackingFilter` and its sort order, the generic
`TrackingRepository`, the Drift column mixin and the shared search/order SQL,
plus the list, card, detail and form widgets every domain reuses.

### Running

```bash
cd apps/client
flutter run -d linux    # or: -d chrome, -d <android device>
flutter test
```

Linux desktop needs `libsecret-1-dev` for the PIN lock plugin:

```bash
sudo apt-get install -y libsecret-1-dev libjsoncpp-dev
```

### Data model

Every entry shares its id (a UUID), title, description, rating (0–10),
review, the date it happened and when it was last changed (`updatedAt`), and
then adds its own:

| Domain | Entity | Own fields |
|---|---|---|
| Escape rooms | `Room` | escaped, minutes left, franchise |
| Dining | `Meal` | dish, price, company, location |
| Concerts | `Gig` | venue, city, support acts, setlist, company |
| Screen | `Viewing` | kind (film/series/miniseries/documentary), release year, director, cast, season |
| Games | `Game` | status (playing/finished/100%/dropped), platform, hours played, release year |

```
Franchise ──< Room
```

Deleting a franchise detaches its rooms instead of deleting them.

The database is at schema v4 (`drift_schemas/`, with a migration test from
every earlier version). Backups are JSON format v3; v1 and v2 files still
import, with fresh UUIDs and their links remapped.

### Lookups

Films, series, games and concerts can be filled in from an external source
instead of by hand. TMDB and RAWG need a personal API key, pasted in Settings
and never shipped with the app; MusicBrainz needs none. Every lookup is
optional — the form works fully offline without a key.
