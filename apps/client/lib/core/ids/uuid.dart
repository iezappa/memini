import 'dart:math';

/// The canonical lowercase form of an RFC 4122 version 4 UUID.
final uuidV4Pattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

bool isUuid(String? value) => value != null && uuidV4Pattern.hasMatch(value);

final _secure = Random.secure();

/// Mints a random (version 4) UUID.
///
/// Every record is born with one instead of an autoincrement id: two devices
/// can create records independently without their ids colliding, which is
/// what a later sync would need (STACK-APPS-DINAMICAS.md 1.1). Written out
/// rather than pulled in as a package: it is sixteen random bytes and two
/// fixed nibbles.
String newUuid([Random? random]) {
  final source = random ?? _secure;
  final bytes = List<int>.generate(16, (_) => source.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 variant

  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
