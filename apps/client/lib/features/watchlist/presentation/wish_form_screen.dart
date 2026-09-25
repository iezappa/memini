import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enrichment/presentation/enrichment_sheet.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/tracking/presentation/form_fields.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/save_failure.dart';
import '../domain/wish.dart';
import 'wish_labels.dart';
import 'wish_providers.dart';

/// Adding something to the watchlist, or editing what is already on it.
///
/// Shorter than any of the five tracked forms, and deliberately: there is no
/// score, no review and no date to pick. What it was, what kind of thing it
/// is, and why it is on the list.
class WishFormScreen extends ConsumerStatefulWidget {
  const WishFormScreen({super.key, this.wish});

  /// Null when adding, the existing wish when editing.
  final Wish? wish;

  bool get isEditing => wish != null;

  @override
  ConsumerState<WishFormScreen> createState() => _WishFormScreenState();
}

class _WishFormScreenState extends ConsumerState<WishFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _note;
  late final TextEditingController _description;
  late final TextEditingController _releaseYear;

  late WishKind _kind;
  String? _externalId;
  String? _posterUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final wish = widget.wish;

    _title = TextEditingController(text: wish?.title ?? '');
    _note = TextEditingController(text: wish?.note ?? '');
    _description = TextEditingController(text: wish?.description ?? '');
    _releaseYear = TextEditingController(
      text: wish?.releaseYear?.toString() ?? '',
    );

    _kind = wish?.kind ?? WishKind.screen;
    _externalId = wish?.externalId;
    _posterUrl = wish?.posterUrl;
  }

  @override
  void dispose() {
    for (final controller in [_title, _note, _description, _releaseYear]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _trimmedOrNull(TextEditingController controller) {
    final value = controller.text.trim();

    return value.isEmpty ? null : value;
  }

  /// Looks the thing up wherever its kind is catalogued.
  ///
  /// The same three sources the tracked forms use, and the same rule: it
  /// fills in blanks and never overwrites what the owner wrote.
  Future<void> _lookUp() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final source = enrichmentSourceForWish(ref, _kind);

    if (!source.isConfigured) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.enrichMissingKey)));
      return;
    }

    final picked = await showEnrichmentSheet(
      context: context,
      source: source,
      initialQuery: _title.text.trim(),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _title.text = picked.title;
      _externalId = picked.externalId;
      _posterUrl = picked.posterUrl;
      if (_description.text.trim().isEmpty && picked.description != null) {
        _description.text = picked.description!;
      }
      if (_releaseYear.text.trim().isEmpty && picked.releaseYear != null) {
        _releaseYear.text = '${picked.releaseYear}';
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final saved = await guardSave(context, () async {
      final repository = ref.read(wishRepositoryProvider);
      final releaseYear = int.tryParse(_releaseYear.text.trim());
      final existing = widget.wish;

      if (existing == null) {
        await repository.create(
          WishDraft(
            kind: _kind,
            title: _title.text.trim(),
            addedOn: DateTime.now(),
            note: _trimmedOrNull(_note),
            description: _trimmedOrNull(_description),
            releaseYear: releaseYear,
            externalId: _externalId,
            posterUrl: _posterUrl,
          ),
        );
      } else {
        await repository.update(
          Wish(
            id: existing.id,
            kind: _kind,
            title: _title.text.trim(),
            addedOn: existing.addedOn,
            updatedAt: existing.updatedAt,
            note: _trimmedOrNull(_note),
            description: _trimmedOrNull(_description),
            releaseYear: releaseYear,
            externalId: _externalId,
            posterUrl: _posterUrl,
          ),
        );
      }
    });
    if (!mounted) return;
    if (!saved) {
      setState(() => _saving = false);
      return;
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TrackerFormScaffold(
      title: widget.isEditing ? l10n.watchlistTitle : l10n.watchlistAdd,
      formKey: _formKey,
      saving: _saving,
      onSave: _save,
      children: [
        ChoiceField<WishKind>(
          label: l10n.wishKindAll,
          value: _kind,
          values: WishKind.values,
          labelOf: (kind) => wishKindLabel(l10n, kind),
          // The kind decides which catalogue the lookup asks, so anything
          // found under the old one no longer belongs to this wish.
          onChanged: (kind) => setState(() {
            _kind = kind;
            _externalId = null;
            _posterUrl = null;
          }),
        ),
        Gap.vMd,
        TextFormField(
          controller: _title,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.fieldTitle),
          validator: (value) =>
              (value ?? '').trim().isEmpty ? l10n.fieldTitleRequired : null,
        ),
        Gap.vMd,
        TextFormField(
          controller: _releaseYear,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: l10n.fieldReleaseYear),
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
        TextFormField(
          controller: _note,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.wishNote,
            helperText: l10n.wishNoteHint,
            helperMaxLines: 2,
          ),
        ),
        Gap.vMd,
        TextFormField(
          controller: _description,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.fieldDescription),
        ),
      ],
    );
  }
}
