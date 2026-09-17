# Serving Memini from ZimaOS

How to serve Memini's web/PWA build from a home ZimaOS server
(STACK-APPS-DINAMICAS.md 5.A).

**Before anything else:** the server **only serves the app**. Each person's
entries live in **their own browser or device**, not on ZimaOS. Two people
using the same server share nothing, and anyone who clears the site data or
removes the app loses whatever they had not exported. The backup is the JSON
export in Settings → Your data → Export.

## 1. The image

Each `v*` tag builds and pushes `ghcr.io/iezappa/memini:<version>` and
`:latest` for `amd64` and `arm64` (`.github/workflows/release.yml`).

The first time, make the package **public**: GitHub → Packages → `memini` →
Package settings → Change visibility → Public. A private package cannot be
pulled by ZimaOS without credentials.

## 2. Install on ZimaOS

1. `deploy/docker-compose.yml` is already filled in. Change port `8082` (both
   `published` and `port_map`) only if it is taken on your server.
2. ZimaOS → **App Store** → **"+"** → **Install a customized app**.
3. **Import** the `docker-compose.yml` and check the image and port.
4. **Install**. The Memini icon appears on the ZimaOS desktop.
5. Check it loads at `http://<zimaos-ip>:8082`. **That URL is only for
   checking**, not for everyday use (see step 3).

Menu names change between ZimaOS versions; look for the custom install or
docker-compose import option if these are not there.

## 3. HTTPS with Tailscale

Installing the PWA, its service worker and OPFS storage all need HTTPS.
`http://IP:port` loads, but cannot be installed and may lose those features.

1. Install **Tailscale** from the ZimaOS App Store and sign in.
2. In the Tailscale admin console enable **MagicDNS** and **HTTPS
   Certificates**.
3. On ZimaOS (SSH):

   ```bash
   tailscale serve --bg http://127.0.0.1:8082
   tailscale serve status
   ```

   If Tailscale runs as a container, run it inside that container against the
   server's LAN IP instead of `127.0.0.1`.
4. Memini is then at `https://<server>.<tailnet>.ts.net/`.
5. Everyone who uses it installs Tailscale and joins the tailnet.

**Always use the `ts.net` URL, at home too.** Browser storage is per origin:
entries saved through the LAN IP do not show up through `ts.net`, and the
other way round.

## 4. Install on each device

| Device | How |
|---|---|
| iPhone / iPad | Open the `ts.net` URL in **Safari** → Share → **Add to Home Screen**. Always open it from that icon. |
| Android | Chrome → menu → **Install app**. Or the APK from GitHub Releases, which needs no server. |
| Windows / macOS / Linux | Chrome or Edge → install icon in the address bar. Or the release build. |

Open it once with a connection, then check that Settings → Your data → Export
works.

## 5. Lookups, headers and what the browser allows

nginx sends `Cross-Origin-Opener-Policy: same-origin` and
`Cross-Origin-Embedder-Policy: require-corp`, so Drift can use OPFS.

- The lookups (TMDB, RAWG, MusicBrainz) are `fetch` requests in CORS mode.
  COEP does not block those: it only blocks *no-cors* subresources (such as
  `<img>` from another host) that do not send `Cross-Origin-Resource-Policy`.
  The APIs answer with `Access-Control-Allow-Origin`, which is what makes the
  lookups work in a browser at all, with or without these headers.
- Memini loads no remote images and bundles its fonts; CanvasKit is bundled
  too (`--no-web-resources-cdn`). If a future change shows remote images, test
  it here: COEP would block them.
- Not verified on a real ZimaOS box by this change. If a lookup fails only in
  the container, open the browser console: a COEP or CORS error names the
  blocked request.

## 6. Data and backups

- Everyone exports their JSON regularly (the app reminds them) and keeps it
  off the browser.
- To move to another device: export on the old one, import on the new one.
- Reinstalling or updating the container does not touch anyone's data.

## 7. Updating

1. Tag a new version; the workflow updates `:latest`.
2. In ZimaOS, update or re-pull the app, or over SSH:

   ```bash
   docker pull ghcr.io/iezappa/memini:latest
   ```

   and restart the app from ZimaOS so the container is recreated.
3. Opened with a connection, the service worker downloads the new version and
   Memini shows **"A new version is available"**. **Update** reloads into it.

If the release changes the database schema (`update.json` says
`"schemaChange": true`, as 1.1.0 does), the banner asks for a backup first and
the migration runs on each device when the app opens. Ask everyone to export
**before** you publish it.
