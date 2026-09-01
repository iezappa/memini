import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/settings/settings_repository.dart';
import 'package:memini/core/theme/theme.dart';
import 'package:memini/core/theme/tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsRepository settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsRepository(await SharedPreferences.getInstance());
  });

  test('starts on brass, which is the palette the app was designed in', () {
    expect(settings.accent, AppAccent.brass);
  });

  test('remembers the chosen accent', () async {
    await settings.setAccent(AppAccent.violet);

    expect(settings.accent, AppAccent.violet);
  });

  test('falls back to brass when the stored name is not one we know', () async {
    SharedPreferences.setMockInitialValues({'settings.accent': 'chartreuse'});
    settings = SettingsRepository(await SharedPreferences.getInstance());

    // A renamed or removed accent must not leave the app without a primary.
    expect(settings.accent, AppAccent.brass);
  });

  test('every accent carries a seed, so none can render as transparent', () {
    for (final accent in AppAccent.values) {
      expect(accent.seed.a, 1.0, reason: '${accent.name} must be opaque');
    }
  });

  test('the accent actually reaches the scheme, in both brightnesses', () {
    expect(
      MeminiTheme.dark(AppAccent.brass).colorScheme.primary,
      MeminiColors.brass,
    );
    expect(
      MeminiTheme.dark(AppAccent.violet).colorScheme.primary,
      AppAccent.violet.seed,
    );
    expect(
      MeminiTheme.light(AppAccent.violet).colorScheme.primary,
      AppAccent.violet.deepSeed,
    );
  });

  test('the warm surfaces do not move with the accent', () {
    final brass = MeminiTheme.dark(AppAccent.brass).colorScheme;
    final violet = MeminiTheme.dark(AppAccent.violet).colorScheme;
    expect(violet.surface, brass.surface);
    expect(violet.onSurface, brass.onSurface);
  });
}
