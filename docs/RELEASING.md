# Releasing

APKs are built and signed on the maintainer's machine and attached to the
GitHub release with `apps/client/tool/release_apk.sh`; the keystore never
reaches CI. Keystore location, backup, `key.properties` and the recorded
certificate fingerprint are in [`SIGNING.md`](SIGNING.md). The general
procedure is the shared standard,
[`FIRMA-ANDROID.md`](https://github.com/iezappa/standardizer_multiplatform/blob/main/FIRMA-ANDROID.md).

## Android APK

Requirements: the Android SDK with build-tools (`apksigner` on `PATH` or under
`$ANDROID_HOME`), Flutter, an authenticated `gh`, and the signing setup in
[`SIGNING.md`](SIGNING.md).

1. Bump `version:` in `apps/client/pubspec.yaml`, set the same version in
   `apps/client/web/update.json` (with `schemaChange: true` if `schemaVersion`
   moved), add the release to `assets/release_notes/en.json` and `es.json`,
   commit. The tests fail if any of them disagree.
2. Tag and push the tag: `git tag vX.Y.Z && git push origin vX.Y.Z`.
3. `.github/workflows/release.yml` checks the versions and the legal docs,
   builds Linux, Windows, macOS and the web zip, creates the GitHub release
   with `update.json`, and pushes `ghcr.io/iezappa/memini`. Wait for it.
4. With a clean tree checked out at the tag:

   ```bash
   git fetch --tags && git checkout vX.Y.Z
   cd apps/client
   tool/release_apk.sh --dry-run vX.Y.Z   # builds and verifies, no upload
   tool/release_apk.sh vX.Y.Z
   ```

   It checks the tree, the tag, the pubspec version, `key.properties` and the
   keystore it points to, `apksigner`, `gh` and the release; builds; compares
   the certificate with `docs/SIGNING.md` (or `APK_CERT_SHA256`) and stops on a
   mismatch; and uploads `memini-vX.Y.Z-android.apk` plus its `.sha256`
   (the name install instructions and Obtainium expect).

The script's pure checks are covered by `tool/release_apk_test.sh`.
