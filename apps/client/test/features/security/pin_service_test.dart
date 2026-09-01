import 'package:flutter_test/flutter_test.dart';
import 'package:memini/features/security/data/pin_service.dart';

class InMemorySecureStore implements SecureStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  late InMemorySecureStore store;
  late PinService service;

  setUp(() {
    store = InMemorySecureStore();
    service = PinService(store);
  });

  test('is disabled until a PIN is set', () async {
    expect(await service.isEnabled, isFalse);
    expect(await service.verify('1234'), isFalse);
  });

  test('accepts a valid PIN and verifies it', () async {
    expect(await service.setPin('1234'), isTrue);

    expect(await service.isEnabled, isTrue);
    expect(await service.verify('1234'), isTrue);
    expect(await service.verify('4321'), isFalse);
  });

  test('never stores the PIN in clear text', () async {
    await service.setPin('195387');

    expect(store.values.values, everyElement(isNot(contains('195387'))));
  });

  test('salts each PIN so identical PINs hash differently', () async {
    await service.setPin('1234');
    final firstHash = store.values['security.pin_hash'];

    await service.setPin('1234');

    expect(store.values['security.pin_hash'], isNot(firstHash));
  });

  test('rejects a PIN shorter than the minimum', () async {
    expect(await service.setPin('123'), isFalse);
    expect(await service.isEnabled, isFalse);
  });

  test('rejects a PIN with non-digit characters', () async {
    expect(await service.setPin('12a4'), isFalse);
    expect(await service.isEnabled, isFalse);
  });

  test('replacing the PIN invalidates the old one', () async {
    await service.setPin('1234');
    await service.setPin('9999');

    expect(await service.verify('1234'), isFalse);
    expect(await service.verify('9999'), isTrue);
  });

  group('disable', () {
    test('clears the lock when the current PIN is right', () async {
      await service.setPin('1234');

      expect(await service.disable('1234'), isTrue);
      expect(await service.isEnabled, isFalse);
      expect(store.values, isEmpty);
    });

    test('keeps the lock when the current PIN is wrong', () async {
      await service.setPin('1234');

      expect(await service.disable('0000'), isFalse);
      expect(await service.isEnabled, isTrue);
    });
  });
}
