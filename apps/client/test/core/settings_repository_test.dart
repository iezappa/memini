import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsRepository settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsRepository(await SharedPreferences.getInstance());
  });

  test('defaults to system locale, system theme and unseen onboarding', () {
    expect(settings.locale, isNull);
    expect(settings.themeMode, ThemeMode.system);
    expect(settings.tutorialSeen, isFalse);
    expect(settings.disclaimerAccepted, isFalse);
    expect(settings.displayName, isNull);
  });

  test('round trips the locale and can fall back to system', () async {
    await settings.setLocale(const Locale('es'));
    expect(settings.locale?.languageCode, 'es');

    await settings.setLocale(null);
    expect(settings.locale, isNull);
  });

  test('round trips the theme mode', () async {
    await settings.setThemeMode(ThemeMode.dark);

    expect(settings.themeMode, ThemeMode.dark);
  });

  test('marks the tutorial seen and the disclaimer accepted', () async {
    await settings.markTutorialSeen();
    await settings.acceptDisclaimer();

    expect(settings.tutorialSeen, isTrue);
    expect(settings.disclaimerAccepted, isTrue);
  });

  test('trims the display name and clears it when blank', () async {
    await settings.setDisplayName('  Zeke  ');
    expect(settings.displayName, 'Zeke');

    await settings.setDisplayName('   ');
    expect(settings.displayName, isNull);
  });

  group('lookup keys', () {
    test('are unset on a fresh install', () async {
      expect(settings.tmdbApiKey, isNull);
      expect(settings.rawgApiKey, isNull);
    });

    test('round trip, trimmed', () async {
      await settings.setTmdbApiKey('  abc123  ');

      expect(settings.tmdbApiKey, 'abc123');
    });

    test(
      'a blank key reads as no key, since it would only produce 401s',
      () async {
        await settings.setTmdbApiKey('abc123');
        await settings.setTmdbApiKey('   ');

        expect(settings.tmdbApiKey, isNull);
      },
    );

    test('the two keys are stored independently', () async {
      await settings.setTmdbApiKey('tmdb');
      await settings.setRawgApiKey('rawg');

      expect(settings.tmdbApiKey, 'tmdb');
      expect(settings.rawgApiKey, 'rawg');

      await settings.setTmdbApiKey(null);

      expect(settings.tmdbApiKey, isNull);
      expect(settings.rawgApiKey, 'rawg');
    });
  });
}
