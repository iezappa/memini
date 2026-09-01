# Memini

A personal tracker for the things you have actually done — an IMDb of your own
record, not a public catalogue. Escape rooms, meals out, concerts, films and
series, and games: five logs, one shared spine.

Everything lives on the device that runs it: no account, no server, no sync.

## Stack

Local-first Flutter, following `Estandarización/STACK-APPS-DINAMICAS.md` for
everything that applies and deliberately dropping the parts that assume a
backend.

| Layer | Choice |
|---|---|
| UI | Flutter (Linux, Web, Android) · Material 3 with a custom theme |
| State | Riverpod |
| Navigation | go_router |
| Storage | Drift (SQLite) behind domain repositories |
| Photos | Copied into the app documents directory |
| Preferences | shared_preferences · PIN hash in flutter_secure_storage |
| Lookups | TMDB, RAWG and MusicBrainz, with the owner's own keys |

There is **no backend**. NestJS, PostgreSQL, Redis, Keycloak, Docker and the
OpenAPI-generated SDK are all dropped: a single-user offline tracker has
nothing for them to do. A remote data source can be added later behind the
existing repository ports without touching the domain.

## Standard product patterns

The five patterns from section 2.1 of the stack standard, plus the support
links from section 9:

- **i18n** — `flutter_localizations` + ARB files, Spanish and English.
- **Onboarding** — three slides on first run, re-openable from Settings.
- **Disclaimer** — explicit acceptance on first run, always visible in Settings.
- **PIN lock** — salted SHA-256 in secure storage, no biometrics-only path.
- **Import / export** — JSON is the source of truth, CSV for spreadsheets.
- **Support links** — Cafecito and Patreon, always shown side by side.

## Layout

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

## Running

```bash
cd apps/client
flutter run -d linux    # or: -d chrome, -d <android device>
flutter test
```

Linux desktop needs `libsecret-1-dev` for the PIN lock plugin:

```bash
sudo apt-get install -y libsecret-1-dev libjsoncpp-dev
```

## Data model

Every entry shares seven fields — title, photo, description, rating (0–10),
review, the date it happened, and its id — and then adds its own:

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

## Lookups

Films, series, games and concerts can be filled in from an external source
instead of by hand. TMDB and RAWG need a personal API key, pasted in Settings
and never shipped with the app; MusicBrainz needs none. Every lookup is
optional — the form works fully offline without a key.
