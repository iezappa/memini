import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../time/clock.dart';
import '../data/drift_photo_repository.dart';
import '../domain/entry_photo.dart';
import 'photo_folder_providers.dart';

final photoRepositoryProvider = Provider<PhotoRepository>(
  (ref) => DriftPhotoRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

/// Bumped after every write so the pictures on screen refetch.
final photoRevisionProvider = StateProvider<int>((ref) => 0);

/// One entry's pictures, oldest first.
final photosProvider = FutureProvider.family<List<EntryPhoto>, String>((
  ref,
  ownerId,
) {
  ref.watch(photoRevisionProvider);

  return ref.watch(photoRepositoryProvider).forOwner(ownerId);
});

/// Picks a picture and keeps it.
///
/// Overridden in tests, which have no file dialog to open.
final photoPickerProvider = Provider<Future<PickedPhoto?> Function()>(
  (ref) => pickPhoto,
);

/// What a picker hands back: the bytes and what kind of picture they are.
typedef PickedPhoto = ({Uint8List bytes, String mimeType});

/// The native and browser file dialogs, narrowed to images.
///
/// Bytes, not a path. A path is what this app kept before v3 and it is why
/// photos were dropped: the picture vanished when the file moved, and in a
/// browser there is no path to keep at all.
Future<PickedPhoto?> pickPhoto() async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'heic', 'gif'],
  );
  if (file == null) return null;

  return (bytes: await file.readAsBytes(), mimeType: _mimeOf(file.name));
}

/// Read off the name, because neither dialog reliably reports the type.
String _mimeOf(String name) => switch (name.split('.').last.toLowerCase()) {
  'png' => 'image/png',
  'webp' => 'image/webp',
  'heic' => 'image/heic',
  'gif' => 'image/gif',
  _ => 'image/jpeg',
};

/// Adding and removing pictures, kept out of the widgets.
class PhotoActions {
  PhotoActions(this._ref);

  final Ref _ref;

  /// Picks a picture and attaches it to [ownerId].
  ///
  /// Returns false when the dialog was dismissed, which is not a failure.
  Future<bool> attach(String ownerId) async {
    final picked = await _ref.read(photoPickerProvider)();
    if (picked == null) return false;

    final photo = await _ref
        .read(photoRepositoryProvider)
        .add(ownerId: ownerId, bytes: picked.bytes, mimeType: picked.mimeType);
    _bump();

    // The copy, right behind the picture the owner just picked: this is the
    // click the browser needs to allow a write, and waiting for a weekly
    // sweep would mean a photo taken today is only safe next week. It never
    // throws — a folder that has been unplugged is reported in settings,
    // not in the owner's face while they are adding pictures.
    await _ref.read(photoFolderStatusProvider.notifier).copy([photo]);

    return true;
  }

  Future<void> remove(String id) async {
    await _ref.read(photoRepositoryProvider).delete(id);
    _bump();
  }

  void _bump() =>
      _ref.read(photoRevisionProvider.notifier).update((value) => value + 1);
}

final photoActionsProvider = Provider<PhotoActions>(PhotoActions.new);
