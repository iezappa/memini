import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/app/app_restart.dart';
import 'core/database/persistent_storage.dart';
import 'features/legal/data/font_licenses.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();

  // Preferences are read synchronously all over the app, so they are resolved
  // once here instead of leaking a FutureProvider into every widget.
  final prefs = await SharedPreferences.getInstance();

  // Not awaited: the browser may take its time, or prompt, and a launch must
  // not wait on either. A no-op outside the web.
  unawaited(requestPersistentStorage());

  runApp(
    AppRestartScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MeminiApp(),
    ),
  );
}
