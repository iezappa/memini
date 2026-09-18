# Memini privacy policy

**English** · [Español](PRIVACY.es.md)

Last updated: 2026-09-17

Memini is a free app developed by Zeke Zappa Developments (iezappa). This policy explains, in plain words, what happens to your data.

## What data the app keeps

- Everything you log in the app (escape rooms, meals, concerts, films and series, games, scores and reviews) is stored **only on your device**.
- It is **not stored on any server**: not on the developer's, and not on the server that delivers the web version.
- The developer **cannot see, recover or delete** your data.
- There are no accounts, no analytics and no advertising.

## Storage on your device

The app uses your device or browser storage (a local database and, in the web version, `localStorage`, IndexedDB, OPFS and the service worker cache) **only to work**: to keep your entries, your settings and to open without a connection. It uses no tracking cookies.

The TMDB and RAWG keys you paste in Settings are kept in the app's local settings on this device, in plain text (in the browser, in `localStorage`). They are only ever sent to the service they belong to.

## Internet connections

The app works fully offline. It only goes online in these cases:

- **Lookups, only when you tap the lookup button in a form.** The text you typed in the search box is sent to the matching service to fill in details:
  - films and series: [TMDB](https://www.themoviedb.org/) (together with your own TMDB key);
  - games: [RAWG](https://rawg.io/) (together with your own RAWG key);
  - bands and artists: [MusicBrainz](https://musicbrainz.org/) (no key; the request identifies the app by name).

  Those services receive the search text, your key where one applies, and what any web request carries (such as your IP address), and handle it under their own privacy policies. **Nothing else you logged — scores, reviews, dates, places or any other entry — is ever sent.** If you never use lookups, no request is made.
- **Update check.** The app asks GitHub (`api.github.com`) whether a newer release exists, at most once every six hours; the web version reads `version.json` from the site it was loaded from. That request carries none of your data.

## Your rights and how to delete your data

- **Delete everything:** Settings → Your data → **Delete all my data**. Your data is also removed when you uninstall the app or clear the site data in your browser.
- **A copy of your data:** Settings → Your data → **Export**.
- Since the developer does not have your data, they cannot hand it over or delete it for you.

## Children

Memini is not directed at children under 13.

## Changes

If this policy changes, the date above is updated and the change is mentioned in the app's release notes.

## Contact

Zeke Zappa Developments (iezappa) — https://github.com/iezappa/memini/issues
