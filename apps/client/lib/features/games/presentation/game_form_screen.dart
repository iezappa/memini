import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/providers.dart';
import '../../../core/enrichment/data/enrichment_providers.dart';
import '../../../core/enrichment/presentation/enrichment_sheet.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/tracking/presentation/form_fields.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/game.dart';
import 'game_labels.dart';
import 'game_providers.dart';

class GameFormScreen extends ConsumerStatefulWidget {
  const GameFormScreen({super.key, this.game});

  /// Null when adding, the existing entry when editing.
  final Game? game;

  bool get isEditing => game != null;

  @override
  ConsumerState<GameFormScreen> createState() => _GameFormScreenState();
}

class _GameFormScreenState extends ConsumerState<GameFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _platform;
  late final TextEditingController _hoursPlayed;
  late final TextEditingController _releaseYear;
  late final TextEditingController _description;
  late final TextEditingController _review;

  late DateTime _happenedOn;
  late GameStatus _status;
  double? _rating;
  String? _photoPath;
  String? _externalId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final game = widget.game;

    _title = TextEditingController(text: game?.title ?? '');
    _platform = TextEditingController(text: game?.platform ?? '');
    _hoursPlayed = TextEditingController(
      text: game?.hoursPlayed?.toString() ?? '',
    );
    _releaseYear = TextEditingController(
      text: game?.releaseYear?.toString() ?? '',
    );
    _description = TextEditingController(text: game?.description ?? '');
    _review = TextEditingController(text: game?.review ?? '');

    _happenedOn = game?.happenedOn ?? DateTime.now();
    _status = game?.status ?? GameStatus.finished;
    _rating = game?.rating;
    _photoPath = game?.photoPath;
    _externalId = game?.externalId;
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _platform,
      _hoursPlayed,
      _releaseYear,
      _description,
      _review,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _trimmedOrNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _pickPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    final failure = AppLocalizations.of(context).photoFailed;

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
      );
      if (picked == null) return;

      final stored = await ref.read(photoStorageProvider).store(picked.path);
      if (mounted) setState(() => _photoPath = stored);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failure)));
    }
  }

  /// Fills in what the lookup knows, without clobbering what the owner
  /// already wrote: only empty fields are filled, and the rating and review
  /// are never touched. The title is the exception — they searched for it.
  Future<void> _lookUp() async {
    final source = ref.read(rawgSourceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final missingKey = AppLocalizations.of(context).enrichMissingKey;

    if (!source.isConfigured) {
      messenger.showSnackBar(SnackBar(content: Text(missingKey)));
      return;
    }

    final picked = await showEnrichmentSheet(
      context: context,
      source: source,
      initialQuery: _title.text.trim(),
    );
    if (picked == null || !mounted) return;

    if (_description.text.trim().isEmpty && picked.description != null) {
      _description.text = picked.description!;
    }
    if (_releaseYear.text.trim().isEmpty && picked.releaseYear != null) {
      _releaseYear.text = '${picked.releaseYear}';
    }
    // RAWG lists every platform a game runs on; the owner played it on one,
    // so this only helps when the field is still blank.
    if (_platform.text.trim().isEmpty && picked.platforms != null) {
      _platform.text = picked.platforms!;
    }

    final cover = picked.imageUrl;
    final stored = (_photoPath == null && cover != null)
        ? await ref.read(photoStorageProvider).storeFromUrl(cover)
        : null;

    if (!mounted) return;
    setState(() {
      _title.text = picked.title;
      _externalId = picked.externalId;
      if (stored != null) _photoPath = stored;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final repository = ref.read(gameRepositoryProvider);
    // A comma is the decimal separator here, and a stray one would otherwise
    // silently drop the hours rather than record them.
    final hours = double.tryParse(
      _hoursPlayed.text.trim().replaceAll(',', '.'),
    );
    final releaseYear = int.tryParse(_releaseYear.text.trim());

    final existing = widget.game;
    if (existing == null) {
      await repository.create(
        GameDraft(
          title: _title.text.trim(),
          happenedOn: _happenedOn,
          status: _status,
          photoPath: _photoPath,
          description: _trimmedOrNull(_description),
          rating: _rating,
          review: _trimmedOrNull(_review),
          platform: _trimmedOrNull(_platform),
          hoursPlayed: hours,
          releaseYear: releaseYear,
          externalId: _externalId,
        ),
      );
    } else {
      await repository.update(
        Game(
          id: existing.id,
          title: _title.text.trim(),
          happenedOn: _happenedOn,
          status: _status,
          photoPath: _photoPath,
          description: _trimmedOrNull(_description),
          rating: _rating,
          review: _trimmedOrNull(_review),
          platform: _trimmedOrNull(_platform),
          hoursPlayed: hours,
          releaseYear: releaseYear,
          externalId: _externalId,
        ),
      );
    }

    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TrackerFormScaffold(
      title: widget.isEditing ? l10n.editGame : l10n.newGame,
      formKey: _formKey,
      saving: _saving,
      onSave: _save,
      children: [
        PhotoField(
          path: _photoPath,
          onPick: _pickPhoto,
          onRemove: _photoPath == null
              ? null
              : () => setState(() => _photoPath = null),
          placeholderIcon: Icons.sports_esports_outlined,
        ),
        Gap.vLg,
        TextFormField(
          controller: _title,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.fieldTitle),
          validator: (value) =>
              (value ?? '').trim().isEmpty ? l10n.fieldTitleRequired : null,
        ),
        Gap.vLg,
        ChoiceField<GameStatus>(
          label: l10n.fieldStatus,
          value: _status,
          values: GameStatus.values,
          labelOf: (status) => gameStatusLabel(l10n, status),
          onChanged: (status) => setState(() => _status = status),
        ),
        Gap.vMd,
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _platform,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.fieldPlatform),
              ),
            ),
            Gap.hMd,
            Expanded(
              child: TextFormField(
                controller: _hoursPlayed,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.fieldHoursPlayed),
              ),
            ),
          ],
        ),
        Gap.vMd,
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _releaseYear,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.fieldReleaseYear),
              ),
            ),
          ],
        ),
        Gap.vMd,
        DateField(
          label: l10n.fieldPlayedUntil,
          value: _happenedOn,
          onChanged: (value) => setState(() => _happenedOn = value),
        ),
        Gap.vSm,
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _lookUp,
            icon: const Icon(Icons.travel_explore_outlined, size: 18),
            label: Text(l10n.enrich),
          ),
        ),
        Gap.vSm,
        RatingField(
          value: _rating,
          onChanged: (value) => setState(() => _rating = value),
        ),
        Gap.vLg,
        TextFormField(
          controller: _description,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.fieldDescription),
        ),
        Gap.vMd,
        TextFormField(
          controller: _review,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.fieldReview),
        ),
      ],
    );
  }
}
