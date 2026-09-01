# Memini — Flutter client

The whole app. See the [root README](../../README.md) for what Memini is, the
stack and the data model.

```bash
flutter pub get
flutter run -d linux    # or: -d chrome, -d <android device>
flutter test
```

After changing a Drift table or an ARB file, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```
