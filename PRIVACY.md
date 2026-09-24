# Memini privacy policy

**English** · [Español](PRIVACY.es.md)

Last updated: 2026-09-24

Memini is a free app developed by Zeke Zappa Developments (iezappa). This policy explains, in plain words, what happens to your data.

## What data the app keeps

- Everything you log in the app (escape rooms, meals, concerts, films and series, games, scores, reviews and the photos you add) is stored **only on your device**.
- It is **not stored on any server**: not on the developer's, and not on the server that delivers the web version.
- The developer **cannot see, recover or delete** your data.
- There are no accounts, no analytics and no advertising.

## Storage on your device

The app uses your device or browser storage (a local database and, in the web version, `localStorage`, IndexedDB, OPFS and the service worker cache) **only to work**: to keep your entries, your settings and to open without a connection. It uses no tracking cookies.

Photos you add to an entry are kept **as the picture itself** inside that local database, so they show up on every screen of the app and work offline. They are never uploaded anywhere.

If you choose a photo folder in Settings → Your data → **Photo folder**, the app also writes a copy of each photo into that folder, as an ordinary image file you can open with anything. It writes only into the folder you picked, and only pictures; it never reads what is already in it. Choosing **Stop copying** ends it, and the copies already written stay where they are — they are your files, in your folder, and removing the app does not remove them.

The TMDB and RAWG keys you paste in Settings are kept in the app's local settings on this device, in plain text (in the browser, in `localStorage`). They are only ever sent to the service they belong to.

## Internet connections

The app works fully offline. It only goes online in these cases:

- **Lookups, only when you tap the lookup button in a form.** The text you typed in the search box is sent to the matching service to fill in details:
  - films and series: [TMDB](https://www.themoviedb.org/) (together with your own TMDB key);
  - games: [RAWG](https://rawg.io/) (together with your own RAWG key);
  - bands and artists: [MusicBrainz](https://musicbrainz.org/) (no key; the request identifies the app by name).

  Those services receive the search text, your key where one applies, and what any web request carries (such as your IP address), and handle it under their own privacy policies. **Nothing else you logged — scores, reviews, dates, places or any other entry — is ever sent.** If you never use lookups, no lookup request is made — but note the suggestions below, which are asked for on their own once a key is set.
- **Suggestions on the home screen, when you have a key set.** If a TMDB or RAWG key is set, opening the home screen asks that service what is popular this week and shows one at random. The request carries your key and what any web request carries (such as your IP address) — never anything you logged. Nothing that comes back is stored: it is gone when you close the app. With no key set, nothing is asked and the shelf says so.
- **Filling in a cover that is missing, once per entry.** An entry that was filled in from TMDB or RAWG before the app kept artwork has an id from that service and no picture. Opening it asks that service for the cover of the same title, once, and saves it. It tells the service nothing it was not told the day that entry was created, and an entry you typed in by hand is never asked about.
- **Artwork, when an entry has a cover.** A film or series filled in from TMDB keeps the *address* of its poster and its backdrop, and a game filled in from RAWG keeps the address of its cover — never the picture itself, so the image is fetched from that service's image host (`image.tmdb.org`, `media.rawg.io`) each time the card or page is on screen. That request carries no key and none of your data — only what any web request carries, such as your IP address. An entry you typed in by hand has no artwork and fetches nothing.
- **Update check.** The app asks GitHub (`api.github.com`) whether a newer release exists, at most once every six hours; the web version reads `version.json` from the site it was loaded from. That request carries none of your data.

## Your rights and how to delete your data

- **Delete everything:** Settings → Your data → **Delete all my data**. Your data is also removed when you uninstall the app or clear the site data in your browser.
- **A copy of your data:** Settings → Your data → **Export**. The export file does not carry your photos — a file you can mail yourself stops being one once it has pictures in it. The photo folder above is what keeps those.
- Since the developer does not have your data, they cannot hand it over or delete it for you.

## Children

Memini is not directed at children under 13.

## Changes

If this policy changes, the date above is updated and the change is mentioned in the app's release notes.

## Contact

Zeke Zappa Developments (iezappa) — https://github.com/iezappa/memini/issues
