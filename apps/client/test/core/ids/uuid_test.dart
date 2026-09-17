import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/ids/uuid.dart';

void main() {
  test('mints RFC 4122 version 4 identifiers', () {
    for (var i = 0; i < 200; i++) {
      expect(newUuid(), matches(uuidV4Pattern));
    }
  });

  test('never repeats itself in practice', () {
    final ids = {for (var i = 0; i < 5000; i++) newUuid()};
    expect(ids, hasLength(5000));
  });

  test('is driven by the random source it is given', () {
    expect(newUuid(Random(1)), newUuid(Random(1)));
  });

  test('isUuid accepts only the canonical lowercase form', () {
    expect(isUuid('0f8fad5b-d9cb-469f-a165-70867728950e'), isTrue);
    expect(isUuid('0F8FAD5B-D9CB-469F-A165-70867728950E'), isFalse);
    expect(isUuid('7'), isFalse);
    expect(isUuid(null), isFalse);
  });
}
