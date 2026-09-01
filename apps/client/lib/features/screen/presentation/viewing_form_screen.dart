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
import '../domain/viewing.dart';
import 'viewing_labels.dart';
import 'viewing_providers.dart';

class ViewingFormScreen extends ConsumerStatefulWidget {
  const ViewingFormScreen({super.key, this.viewing});

  /// Null when adding, the existing entry when editing.
  final Viewing? viewing;

  bool get isEditing => viewing != null;

  @override
  ConsumerState<ViewingFormScreen> createState() => _ViewingFormScreenState();
}

class _ViewingFormScreenState extends ConsumerState<ViewingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _releaseYear;
  late final TextEditingController _director;
  late final TextEditingController _cast;
  late final TextEditingController _season;
  late final TextEditingController _description;
  late final TextEditingController _review;

  late DateTime _happenedOn;
  late ViewingKind _kind;
  double? _rating;
  String? _photoPath;
  String? _externalId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final viewing = widget.viewing;

    _title = TextEditingController(text: viewing?.title ?? '');
    _releaseYear = TextEditingController(
      text: viewing?.releaseYear?.toString() ?? '',
    );
    _director = TextEditingController(text: viewing?.director ?? '');
    _cast = TextEditingController(text: viewing?.cast ?? '');
    _season = TextEditingController(text: viewing?.season?.toString() ?? '');
    _description = TextEditingController(text: viewing?.description ?? '');
    _review = TextEditingController(text: viewing?.review ?? '');

    _happenedOn = viewing?.happenedOn ?? DateTime.now();
    _kind = viewing?.kind ?? ViewingKind.film;
    _rating = viewing?.rating;
    _photoPath = viewing?.photoPath;
    _externalId = viewing?.externalId;
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _releaseYear,
      _director,
      _cast,
      _season,
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

  /// A season only means something for a series; keeping it on a film would
  /// leave a stale number behind after switching the kind.
  bool get _takesSeason =>
      _kind == ViewingKind.series || _kind == ViewingKind.miniseries;

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
    final source = ref.read(tmdbSourceProvider);
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
    if (_director.text.trim().isEmpty && picked.director != null) {
      _director.text = picked.director!;
    }
    if (_cast.text.trim().isEmpty && picked.cast != null) {
      _cast.text = picked.cast!;
    }

    final poster = picked.imageUrl;
    final stored = (_photoPath == null && poster != null)
        ? await ref.read(photoStorageProvider).storeFromUrl(poster)
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
    final repository = ref.read(viewingRepositoryProvider);
    final season = _takesSeason ? int.tryParse(_season.text.trim()) : null;
    final releaseYear = int.tryParse(_releaseYear.text.trim());

    final existing = widget.viewing;
    if (existing == null) {
      await repository.create(
        ViewingDraft(
          title: _title.text.trim(),
          happenedOn: _happenedOn,
          kind: _kind,
          photoPath: _photoPath,
          description: _trimmedOrNull(_description),
          rating: _rating,
          review: _trimmedOrNull(_review),
          releaseYear: releaseYear,
          director: _trimmedOrNull(_director),
          cast: _trimmedOrNull(_cast),
          season: season,
          externalId: _externalId,
        ),
      );
    } else {
      await repository.update(
        Viewing(
          id: existing.id,
          title: _title.text.trim(),
          happenedOn: _happenedOn,
          kind: _kind,
          photoPath: _photoPath,
          description: _trimmedOrNull(_description),
          rating: _rating,
          review: _trimmedOrNull(_review),
          releaseYear: releaseYear,
          director: _trimmedOrNull(_director),
          cast: _trimmedOrNull(_cast),
          season: season,
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
      title: widget.isEditing ? l10n.editViewing : l10n.newViewing,
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
          placeholderIcon: Icons.movie_outlined,
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
        ChoiceField<ViewingKind>(
          label: l10n.fieldKind,
          value: _kind,
          values: ViewingKind.values,
          labelOf: (kind) => viewingKindLabel(l10n, kind),
          onChanged: (kind) => setState(() => _kind = kind),
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
            if (_takesSeason) ...[
              Gap.hMd,
              Expanded(
                child: TextFormField(
                  controller: _season,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: l10n.fieldSeason),
                ),
              ),
            ],
          ],
        ),
        Gap.vMd,
        DateField(
          label: l10n.fieldWatchedOn,
          value: _happenedOn,
          onChanged: (value) => setState(() => _happenedOn = value),
        ),
        Gap.vMd,
        TextFormField(
          controller: _director,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.fieldDirector),
        ),
        Gap.vMd,
        TextFormField(
          controller: _cast,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.fieldCast,
            helperText: l10n.fieldCastHint,
          ),
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
