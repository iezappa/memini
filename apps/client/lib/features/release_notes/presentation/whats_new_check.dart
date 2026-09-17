import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/versioning/app_version.dart';
import '../domain/release_notes.dart';
import 'release_notes_dialog.dart';
import 'release_notes_providers.dart';

/// Shows what changed the first time a newer version opens (§8.2 Novedades).
///
/// The version is stamped as seen whether or not anything was shown, so a
/// first install starts on this version instead of catching up on history.
class WhatsNewCheck extends ConsumerStatefulWidget {
  const WhatsNewCheck({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<WhatsNewCheck> createState() => _WhatsNewCheckState();
}

class _WhatsNewCheckState extends ConsumerState<WhatsNewCheck> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (!mounted) return;
    final settings = ref.read(settingsRepositoryProvider);

    // The backup notice owns this launch; the notes wait for the next one.
    if (!settings.backupNoticeAccepted) return;

    final language = Localizations.localeOf(context).languageCode;
    final ReleaseNotes notes;
    try {
      notes = await ref.read(releaseNotesProvider(language).future);
    } catch (_) {
      // Bundled with the app: a failure is a broken build, never a reason to
      // stop a launch. There is simply nothing to announce.
      return;
    }
    if (!mounted) return;

    final unseen = notes.toAnnounce(
      lastSeen: AppVersion.tryParse(settings.lastSeenVersion),
    );
    await settings.setLastSeenVersion('${notes.current}');

    if (unseen.isEmpty || !mounted) return;
    await showReleaseNotesDialog(context, releases: unseen, announcing: true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
