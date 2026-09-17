import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the OFL licences of the bundled fonts to the licence page.
///
/// Fonts are not pub packages, so Flutter does not collect their licences on
/// its own (CUMPLIMIENTO.md item 19).
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final family in ['Fraunces', 'Inter']) {
      final text = await rootBundle.loadString('assets/fonts/OFL-$family.txt');
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });
}
