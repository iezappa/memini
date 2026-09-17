import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/versioning/app_version.dart';

void main() {
  group('AppVersion.tryParse', () {
    test('reads a plain, a tagged and a built version', () {
      expect(AppVersion.tryParse('1.2.3'), const AppVersion(1, 2, 3));
      expect(AppVersion.tryParse('v1.2.3'), const AppVersion(1, 2, 3));
      expect(AppVersion.tryParse('1.2.3+45'), const AppVersion(1, 2, 3));
    });

    test('gives null for anything else', () {
      expect(AppVersion.tryParse('garbage'), isNull);
      expect(AppVersion.tryParse('1.2'), isNull);
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse(null), isNull);
    });
  });

  group('ordering', () {
    test('compares numbers, not strings', () {
      expect(const AppVersion(1, 10, 0) > const AppVersion(1, 9, 9), isTrue);
    });

    test('major wins over everything below it', () {
      expect(const AppVersion(2, 0, 0) > const AppVersion(1, 99, 99), isTrue);
    });

    test('equal versions are neither greater nor smaller', () {
      const a = AppVersion(1, 0, 0);
      expect(a.compareTo(const AppVersion(1, 0, 0)), 0);
      expect(a > const AppVersion(1, 0, 0), isFalse);
      expect(a < const AppVersion(1, 0, 0), isFalse);
    });

    test('prints as major.minor.patch', () {
      expect('${const AppVersion(1, 4, 0)}', '1.4.0');
    });
  });
}
