import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Minimal key-value port so the PIN logic can be tested without touching the
/// platform keychain channel.
abstract interface class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureStore implements SecureStore {
  const FlutterSecureStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// App-launch PIN lock.
///
/// The PIN is never stored: only a random salt and the SHA-256 of
/// `salt + pin`. Biometrics are deliberately absent as the sole mechanism —
/// the PIN is the universal fallback across Linux, Web and Android.
class PinService {
  PinService(this._store, {Random? random})
    : _random = random ?? Random.secure();

  final SecureStore _store;
  final Random _random;

  static const _saltKey = 'security.pin_salt';
  static const _hashKey = 'security.pin_hash';
  static const minLength = 4;

  Future<bool> get isEnabled async => await _store.read(_hashKey) != null;

  /// Sets or replaces the PIN. Returns false when [pin] is too short or is
  /// not made of digits only.
  Future<bool> setPin(String pin) async {
    if (!_isValid(pin)) return false;

    final salt = _newSalt();
    await _store.write(_saltKey, salt);
    await _store.write(_hashKey, _hash(salt, pin));
    return true;
  }

  Future<bool> verify(String pin) async {
    final salt = await _store.read(_saltKey);
    final hash = await _store.read(_hashKey);
    if (salt == null || hash == null) return false;

    return _hash(salt, pin) == hash;
  }

  /// Removes the lock. Requires the current PIN so a bystander with the app
  /// open cannot simply turn it off.
  Future<bool> disable(String currentPin) async {
    if (!await verify(currentPin)) return false;

    await _store.delete(_saltKey);
    await _store.delete(_hashKey);
    return true;
  }

  bool _isValid(String pin) =>
      pin.length >= minLength && RegExp(r'^\d+$').hasMatch(pin);

  String _newSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Encode(bytes);
  }

  String _hash(String salt, String pin) =>
      base64Encode(sha256.convert(utf8.encode('$salt$pin')).bytes);
}
