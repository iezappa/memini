import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// The bytes of the SQLite file as drift's IndexedDB file system last
/// persisted them — what survives the drift worker going away, as opposed to
/// what the worker still holds in memory and answers queries from.
///
/// Returns null when the store does not live in IndexedDB (OPFS, in memory).
Future<List<int>?> browserStoredBytes(String storeName) async {
  final open = web.window.indexedDB.open(storeName);
  final db = await _request(open) as web.IDBDatabase;
  try {
    final stores = db.objectStoreNames;
    if (!stores.contains('files') || !stores.contains('blocks')) return null;

    final tx = db.transaction(['files'.toJS, 'blocks'.toJS].toJS);
    final fileKeys = await _request(tx.objectStore('files').getAllKeys());
    final files = await _request(tx.objectStore('files').getAll());
    final blockKeys = await _request(tx.objectStore('blocks').getAllKeys());
    final blocks = await _request(tx.objectStore('blocks').getAll());

    int? fileId;
    final keys = (fileKeys! as JSArray<JSAny?>).toDart;
    final entries = (files! as JSArray<JSAny?>).toDart;
    for (var i = 0; i < keys.length; i++) {
      final entry = entries[i]! as JSObject;
      final name = (entry.getProperty('name'.toJS) as JSString?)?.toDart;
      if (name == '/database') {
        fileId = (keys[i]! as JSNumber).toDartInt;
      }
    }
    if (fileId == null) return null;

    final bytes = <int>[];
    final allBlockKeys = (blockKeys! as JSArray<JSAny?>).toDart;
    final allBlocks = (blocks! as JSArray<JSAny?>).toDart;
    for (var i = 0; i < allBlockKeys.length; i++) {
      final key = (allBlockKeys[i]! as JSArray<JSAny?>).toDart;
      if ((key[0]! as JSNumber).toDartInt != fileId) continue;
      bytes.addAll(await _bytesOf(allBlocks[i]!));
    }
    return bytes;
  } finally {
    db.close();
  }
}

/// A block is stored as a Blob by some sqlite3 versions and as raw binary by
/// others.
Future<List<int>> _bytesOf(JSAny block) async {
  if (block.isA<web.Blob>()) {
    final buffer = await (block as web.Blob).arrayBuffer().toDart;
    return buffer.toDart.asUint8List();
  }
  if (block.isA<JSArrayBuffer>()) {
    return (block as JSArrayBuffer).toDart.asUint8List();
  }
  return (block as JSUint8Array).toDart;
}

Future<JSAny?> _request(web.IDBRequest request) {
  final done = Completer<JSAny?>();
  request.onsuccess = ((web.Event _) => done.complete(request.result)).toJS;
  request.onerror = ((web.Event _) => done.completeError(
    request.error ?? 'IndexedDB request failed',
  )).toJS;
  return done.future;
}
