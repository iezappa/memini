import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Docker web CSP allows configured Memini Server origins', () {
    final config = File('../../deploy/nginx.conf').readAsStringSync();

    expect(config, contains("connect-src 'self' http: https:"));
  });
}
