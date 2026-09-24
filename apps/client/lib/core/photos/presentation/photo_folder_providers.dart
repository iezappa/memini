import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/photo_folder_platform.dart';
import '../domain/entry_photo.dart';
import '../domain/photo_folder.dart';
import 'photo_providers.dart';

/// The folder this build can write pictures into.
final photoFolderProvider = Provider<PhotoFolder>(
  (ref) => photoFolderFor(ref.watch(sharedPreferencesProvider)),
);

/// Where the copies go, and whether they are getting there.
///
/// One value rather than three flags: a folder is either off, working, or
/// in trouble for a reason the owner can act on, and the tile says which.
class PhotoFolderStatus {
  const PhotoFolderStatus({this.name, this.problem});

  /// What to call the folder on screen — a path on the desktop, the folder's
  /// own name in a browser, which is all a browser will say.
  final String? name;

  /// Set when a folder was chosen and cannot be written to right now.
  final PhotoFolderProblem? problem;

  /// Copies are being made.
  bool get isOn => name != null && problem == null;
}

class PhotoFolderController extends AsyncNotifier<PhotoFolderStatus> {
  PhotoFolder get _folder => ref.read(photoFolderProvider);

  @override
  Future<PhotoFolderStatus> build() => _read();

  Future<PhotoFolderStatus> _read() async {
    if (!_folder.isSupported) return const PhotoFolderStatus();

    try {
      return PhotoFolderStatus(name: await _folder.remembered());
    } on PhotoFolderException catch (error) {
      return PhotoFolderStatus(problem: error.problem);
    }
  }

  /// Asks for a folder and, if one is given, fills it with what is already
  /// stored.
  ///
  /// The catch-up matters: a folder chosen after a year of use would
  /// otherwise hold only the pictures added from tomorrow on, which is not
  /// what the word backup means to anybody.
  Future<void> choose() async {
    // The first read may still be in flight — nothing has to have watched
    // this provider before the owner opens settings — and its answer would
    // land on top of the folder they just picked.
    await future;

    final name = await _folder.choose();
    if (name == null) return;

    state = AsyncData(PhotoFolderStatus(name: name));
    await copyEverything();
  }

  /// Writes every stored picture into the folder, skipping nothing.
  ///
  /// Re-copying a picture that is already there costs a write and keeps the
  /// code honest: the alternative is a list of what has been copied, which
  /// is a second thing to keep in step with the folder and would be wrong
  /// the first time somebody tidied it by hand.
  Future<void> copyEverything() async {
    final photos = await ref.read(photoRepositoryProvider).all();

    await copy(photos);
  }

  /// Copies [photos] in. Does nothing when no folder was ever chosen.
  ///
  /// Never throws: this runs behind adding a picture, and a folder that has
  /// been unplugged must not turn attaching a photo into a failure. The
  /// trouble is recorded in the status, where the settings tile shows it.
  Future<void> copy(Iterable<EntryPhoto> photos) async {
    // Awaited rather than read: adding the first picture of a session is
    // usually what asks this provider for the first time, and reading a
    // state that is still loading would silently skip the copy.
    final current = state.valueOrNull ?? await future;
    if (current.name == null) return;

    for (final photo in photos) {
      try {
        await _folder.write(photo.fileName, photo.bytes);
      } on PhotoFolderException catch (error) {
        state = AsyncData(
          PhotoFolderStatus(name: current.name, problem: error.problem),
        );
        return;
      } catch (_) {
        state = AsyncData(
          PhotoFolderStatus(
            name: current.name,
            problem: PhotoFolderProblem.failed,
          ),
        );
        return;
      }
    }

    state = AsyncData(PhotoFolderStatus(name: current.name));
  }

  /// Stops copying. What is already in the folder stays there — it is the
  /// owner's folder and their pictures, and deleting from it would be the
  /// one surprise a backup must never spring.
  Future<void> forget() async {
    await future;
    await _folder.forget();
    state = const AsyncData(PhotoFolderStatus());
  }
}

final photoFolderStatusProvider =
    AsyncNotifierProvider<PhotoFolderController, PhotoFolderStatus>(
      PhotoFolderController.new,
    );
