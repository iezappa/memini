import 'package:flutter_test/flutter_test.dart';
import 'package:memini/features/backup/domain/backup_document.dart';
import 'package:memini/features/rooms/domain/room.dart';
import 'package:memini/features/server_account/domain/backup_fingerprint.dart';

void main() {
  test('ignores exportedAt when content is unchanged', () {
    final first = _backup(exportedAt: DateTime(2026, 1, 1));
    final second = _backup(exportedAt: DateTime(2026, 1, 2));

    expect(backupDocumentFingerprint(first), backupDocumentFingerprint(second));
  });

  test('changes when entries are deleted', () {
    final full = _backup(exportedAt: DateTime(2026, 1, 1));
    final deleted = BackupDocument.of(
      franchises: const [],
      rooms: const [],
      exportedAt: DateTime(2026, 1, 2),
    );

    expect(
      backupDocumentFingerprint(full),
      isNot(backupDocumentFingerprint(deleted)),
    );
  });
}

BackupDocument _backup({required DateTime exportedAt}) => BackupDocument.of(
  franchises: const [],
  rooms: [
    Room(
      id: '123e4567-e89b-42d3-a456-426614174000',
      updatedAt: DateTime(2026, 1, 1),
      title: 'Room one',
      happenedOn: DateTime(2026, 1, 1),
      escaped: true,
    ),
  ],
  exportedAt: exportedAt,
);
