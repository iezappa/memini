import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../backup/domain/backup_document.dart';

String backupDocumentFingerprint(BackupDocument document) {
  final json = Map<String, dynamic>.from(document.toJson())
    ..remove('exportedAt');
  final canonical = _canonicalize(json);
  return sha256.convert(utf8.encode(jsonEncode(canonical))).toString();
}

Object? _canonicalize(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return {for (final key in keys) key: _canonicalize(value[key])};
  }
  if (value is List) {
    final items = [for (final item in value) _canonicalize(item)];
    items.sort((a, b) => jsonEncode(a).compareTo(jsonEncode(b)));
    return items;
  }
  return value;
}
