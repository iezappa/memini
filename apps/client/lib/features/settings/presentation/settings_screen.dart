import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../backup/domain/backup_document.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../shared/support_actions.dart';
import '../../shared/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: SafeArea(
        child: ContentColumn(
          child: ListView(
            padding: const EdgeInsets.only(bottom: Gap.xl),
            children: const [
              Gap.vMd,
              _AppearanceSection(),
              Gap.vSection,
              _ProfileSection(),
              Gap.vSection,
              _LanguageSection(),
              Gap.vSection,
              _SecuritySection(),
              Gap.vSection,
              _LookupsSection(),
              Gap.vSection,
              _DataSection(),
              Gap.vSection,
              _SupportSection(),
              Gap.vSection,
              _AboutSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// A settings section: an uppercase label, then its controls sitting straight
/// on the page.
///
/// Deliberately not a card. Grouping every section in its own box adds a
/// border and an inset for each one, and on a screen that is mostly one-line
/// rows that reads as clutter rather than structure. The label and the page
/// gutter carry the grouping instead.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [SectionLabel(title), ...children],
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return _Section(
      title: l10n.settingsAppearance,
      children: [
        // Three fixed choices, so the whole set is visible at once instead of
        // hidden behind a dropdown that has to be opened to be read.
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(l10n.themeSystem),
            ),
            ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
            ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
          ],
          selected: {themeMode},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              ref.read(themeModeProvider.notifier).set(selection.first),
        ),
      ],
    );
  }
}

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    return _Section(
      title: l10n.settingsLanguage,
      children: [
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'system', label: Text(l10n.languageSystem)),
            const ButtonSegment(value: 'es', label: Text('Español')),
            const ButtonSegment(value: 'en', label: Text('English')),
          ],
          selected: {locale?.languageCode ?? 'system'},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => ref
              .read(localeProvider.notifier)
              .set(
                selection.first == 'system' ? null : Locale(selection.first),
              ),
        ),
      ],
    );
  }
}

class _ProfileSection extends ConsumerWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(displayNameProvider);

    return _Section(
      title: l10n.settingsProfile,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: Text(l10n.settingsDisplayName),
          subtitle: Text(name ?? l10n.settingsDisplayNameHint),
          onTap: () => _editName(context, ref, name),
        ),
      ],
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current ?? '');

    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsDisplayName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    controller.dispose();
    if (value != null) await ref.read(displayNameProvider.notifier).set(value);
  }
}

class _SecuritySection extends ConsumerWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final enabled = ref.watch(pinEnabledProvider).valueOrNull ?? false;

    return _Section(
      title: l10n.settingsSecurity,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.lock_outline),
          title: Text(l10n.settingsPinLock),
          subtitle: Text(
            enabled ? l10n.settingsPinLockOn : l10n.settingsPinLockOff,
          ),
          onTap: () => _managePin(context, ref, enabled),
        ),
      ],
    );
  }

  Future<void> _managePin(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _PinDialog(enabled: enabled),
    );
    if (changed == true) ref.invalidate(pinEnabledProvider);
  }
}

/// Sets, changes or clears the PIN. Changing or clearing asks for the current
/// PIN first, so someone holding an unlocked phone cannot take the lock off.
class _PinDialog extends ConsumerStatefulWidget {
  const _PinDialog({required this.enabled});

  final bool enabled;

  @override
  ConsumerState<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends ConsumerState<_PinDialog> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _apply({required bool disable}) async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(pinServiceProvider);
    final navigator = Navigator.of(context);

    if (widget.enabled && !await service.verify(_current.text)) {
      setState(() => _error = l10n.pinWrong);
      return;
    }

    if (disable) {
      await service.disable(_current.text);
      navigator.pop(true);
      return;
    }

    if (_next.text != _confirm.text) {
      setState(() => _error = l10n.pinMismatch);
      return;
    }

    if (!await service.setPin(_next.text)) {
      if (mounted) setState(() => _error = l10n.pinTooShort);
      return;
    }

    navigator.pop(true);
  }

  Widget _field(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(widget.enabled ? l10n.pinChange : l10n.pinSet),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.enabled) ...[_field(_current, l10n.pinCurrent), Gap.vSm],
          _field(_next, l10n.pinNew),
          Gap.vSm,
          _field(_confirm, l10n.pinConfirm),
          if (_error != null) ...[
            Gap.vSm,
            Text(
              _error!,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (widget.enabled)
          TextButton(
            onPressed: () => _apply(disable: true),
            child: Text(l10n.pinDisable),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => _apply(disable: false),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// Where the owner pastes their own lookup keys.
///
/// The keys are personal because neither TMDB nor RAWG lets an app ship one
/// for everybody, and because a key baked into a local-first app would be
/// readable by anyone who opened the bundle.
class _LookupsSection extends ConsumerWidget {
  const _LookupsSection();

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String? current,
    required Future<void> Function(String?) onSave,
  }) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current ?? '');

    final saved = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(hintText: l10n.settingsKeyNotSet),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    controller.dispose();
    if (saved != null) await onSave(saved);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tmdb = ref.watch(tmdbApiKeyProvider);
    final rawg = ref.watch(rawgApiKeyProvider);

    return _Section(
      title: l10n.settingsLookups,
      children: [
        Text(
          l10n.settingsLookupsBody,
          style: context.text.bodySmall?.copyWith(
            color: context.semantics.muted,
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.movie_outlined),
          title: Text(l10n.settingsTmdbKey),
          // The key itself is never echoed back: knowing it is set is all the
          // owner needs, and a shoulder-surfer gets nothing.
          subtitle: Text(
            tmdb == null ? l10n.settingsKeyNotSet : l10n.settingsKeySet,
          ),
          onTap: () => _edit(
            context,
            ref,
            title: l10n.settingsTmdbKey,
            current: tmdb,
            onSave: ref.read(tmdbApiKeyProvider.notifier).set,
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.sports_esports_outlined),
          title: Text(l10n.settingsRawgKey),
          subtitle: Text(
            rawg == null ? l10n.settingsKeyNotSet : l10n.settingsKeySet,
          ),
          onTap: () => _edit(
            context,
            ref,
            title: l10n.settingsRawgKey,
            current: rawg,
            onSave: ref.read(rawgApiKeyProvider.notifier).set,
          ),
        ),
        Text(
          l10n.settingsMusicBrainzNote,
          style: context.text.bodySmall?.copyWith(
            color: context.semantics.muted,
          ),
        ),
      ],
    );
  }
}

class _DataSection extends ConsumerWidget {
  const _DataSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return _Section(
      title: l10n.settingsData,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.download_outlined),
          title: Text(l10n.exportJson),
          onTap: () => _export(context, ref, asCsv: false),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.table_chart_outlined),
          title: Text(l10n.exportCsv),
          onTap: () => _export(context, ref, asCsv: true),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.upload_outlined),
          title: Text(l10n.importJson),
          onTap: () => _import(context, ref),
        ),
      ],
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref, {
    required bool asCsv,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(backupServiceProvider);
    final stamp = DateTime.now().toIso8601String().split('T').first;

    try {
      // JSON is one document; CSV is one sheet per domain, because five
      // shapes cannot share a header without inventing empty columns.
      final files = asCsv
          ? {
              for (final entry in (await service.exportCsv()).entries)
                'memini-${entry.key}-$stamp.csv': entry.value,
            }
          : {'memini-backup-$stamp.json': await service.exportJson()};

      if (kIsWeb) {
        // No file system to write to; hand the text to the share sheet, with
        // each sheet named so a multi-file CSV export stays readable.
        await SharePlus.instance.share(
          ShareParams(
            text: files.length == 1
                ? files.values.first
                : files.entries.map((e) => '# ${e.key}\n${e.value}').join('\n'),
            subject: files.keys.first,
          ),
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final written = <XFile>[];
        for (final entry in files.entries) {
          final file = File('${directory.path}/${entry.key}');
          await file.writeAsString(entry.value);
          written.add(XFile(file.path));
        }
        await SharePlus.instance.share(
          ShareParams(files: written, subject: files.keys.first),
        );
      }

      messenger.showSnackBar(SnackBar(content: Text(l10n.exportDone)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importWarningTitle),
        content: Text(l10n.importWarningBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.importConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (file == null) return;

      final contents = utf8.decode(await file.readAsBytes());
      final document = await ref.read(backupServiceProvider).import(contents);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importDone(document.rooms.length))),
      );
    } on BackupFormatException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed)));
    }
  }
}

/// The support links, under their own heading like every other section.
///
/// The card stays a card here: it is one block of copy plus two buttons, not
/// a list of rows, so it does not fight the flat layout around it.
class _SupportSection extends StatelessWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: AppLocalizations.of(context).settingsSupport,
      children: const [SupportProjectsCard()],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _Section(
      title: l10n.settingsAbout,
      children: [
        // Printed in full rather than hidden behind a tile: a disclaimer the
        // owner has to tap to read is a disclaimer they never read.
        Text(
          l10n.disclaimerBody,
          style: context.text.bodySmall?.copyWith(
            color: context.semantics.muted,
            height: 1.45,
          ),
        ),
        Gap.vSm,
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.school_outlined),
          title: Text(l10n.tutorialAgain),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const OnboardingScreen(tutorialOnly: true),
            ),
          ),
        ),
      ],
    );
  }
}
