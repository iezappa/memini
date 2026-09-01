import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/providers.dart';
import '../../../core/enrichment/data/enrichment_providers.dart';
import '../../../core/enrichment/presentation/enrichment_sheet.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/tracking/presentation/form_fields.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/gig.dart';
import 'gig_providers.dart';

class GigFormScreen extends ConsumerStatefulWidget {
  const GigFormScreen({super.key, this.gig});

  /// Null when adding, the existing entry when editing.
  final Gig? gig;

  bool get isEditing => gig != null;

  @override
  ConsumerState<GigFormScreen> createState() => _GigFormScreenState();
}

class _GigFormScreenState extends ConsumerState<GigFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _venue;
  late final TextEditingController _city;
  late final TextEditingController _supportActs;
  late final TextEditingController _setlist;
  late final TextEditingController _company;
  late final TextEditingController _description;
  late final TextEditingController _review;

  late DateTime _happenedOn;
  double? _rating;
  String? _photoPath;
  String? _externalId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final gig = widget.gig;

    _title = TextEditingController(text: gig?.title ?? '');
    _venue = TextEditingController(text: gig?.venue ?? '');
    _city = TextEditingController(text: gig?.city ?? '');
    _supportActs = TextEditingController(text: gig?.supportActs ?? '');
    _setlist = TextEditingController(text: gig?.setlist ?? '');
    _company = TextEditingController(text: gig?.company ?? '');
    _description = TextEditingController(text: gig?.description ?? '');
    _review = TextEditingController(text: gig?.review ?? '');

    _happenedOn = gig?.happenedOn ?? DateTime.now();
    _rating = gig?.rating;
    _photoPath = gig?.photoPath;
    _externalId = gig?.externalId;
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _venue,
      _city,
      _supportActs,
      _setlist,
      _company,
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
  /// already wrote. MusicBrainz carries no cover art, so a gig photo stays
  /// the owner's own.
  Future<void> _lookUp() async {
    final source = ref.read(musicBrainzSourceProvider);

    final picked = await showEnrichmentSheet(
      context: context,
      source: source,
      initialQuery: _title.text.trim(),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _title.text = picked.title;
      _externalId = picked.externalId;
      if (_description.text.trim().isEmpty && picked.description != null) {
        _description.text = picked.description!;
      }
      if (_city.text.trim().isEmpty && picked.origin != null) {
        _city.text = picked.origin!;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final repository = ref.read(gigRepositoryProvider);

    final existing = widget.gig;
    if (existing == null) {
      await repository.create(
        GigDraft(
          title: _title.text.trim(),
          happenedOn: _happenedOn,
          photoPath: _photoPath,
          description: _trimmedOrNull(_description),
          rating: _rating,
          review: _trimmedOrNull(_review),
          venue: _trimmedOrNull(_venue),
          city: _trimmedOrNull(_city),
          supportActs: _trimmedOrNull(_supportActs),
          setlist: _trimmedOrNull(_setlist),
          company: _trimmedOrNull(_company),
          externalId: _externalId,
        ),
      );
    } else {
      await repository.update(
        Gig(
          id: existing.id,
          title: _title.text.trim(),
          happenedOn: _happenedOn,
          photoPath: _photoPath,
          description: _trimmedOrNull(_description),
          rating: _rating,
          review: _trimmedOrNull(_review),
          venue: _trimmedOrNull(_venue),
          city: _trimmedOrNull(_city),
          supportActs: _trimmedOrNull(_supportActs),
          setlist: _trimmedOrNull(_setlist),
          company: _trimmedOrNull(_company),
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
      title: widget.isEditing ? l10n.editGig : l10n.newGig,
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
          placeholderIcon: Icons.music_note_outlined,
        ),
        Gap.vLg,
        TextFormField(
          controller: _title,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.fieldBand),
          validator: (value) =>
              (value ?? '').trim().isEmpty ? l10n.fieldBandRequired : null,
        ),
        Gap.vMd,
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _venue,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.fieldVenue),
              ),
            ),
            Gap.hMd,
            Expanded(
              child: TextFormField(
                controller: _city,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.fieldCity),
              ),
            ),
          ],
        ),
        Gap.vMd,
        DateField(
          label: l10n.fieldSawOn,
          value: _happenedOn,
          onChanged: (value) => setState(() => _happenedOn = value),
        ),
        Gap.vMd,
        TextFormField(
          controller: _supportActs,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.fieldSupportActs,
            helperText: l10n.fieldSupportActsHint,
          ),
        ),
        Gap.vMd,
        TextFormField(
          controller: _company,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.fieldCompany),
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
          controller: _setlist,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.fieldSetlist,
            helperText: l10n.fieldSetlistHint,
            alignLabelWithHint: true,
          ),
        ),
        Gap.vMd,
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
