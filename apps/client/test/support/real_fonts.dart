import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled families, so a screenshot shows type rather than the
/// test binding's square placeholder glyphs.
Future<void> loadRealFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final family in const ['Inter', 'Fraunces']) {
    final loader = FontLoader(family)
      ..addFont(
        File('assets/fonts/$family.ttf').readAsBytes().then(
          (bytes) => ByteData.sublistView(bytes),
        ),
      );
    await loader.load();
  }
}
