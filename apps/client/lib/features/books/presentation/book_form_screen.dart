import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enrichment/data/enrichment_providers.dart';
import '../../../core/enrichment/presentation/enrichment_sheet.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/tracking/presentation/form_fields.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/save_failure.dart';
import '../domain/book.dart';
import 'book_providers.dart';

class BookFormScreen extends ConsumerStatefulWidget {
  const BookFormScreen({super.key, this.book});

  final Book? book;
  bool get isEditing => book != null;

  @override
  ConsumerState<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends ConsumerState<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _publicationYear;
  late final TextEditingController _description;
  late final TextEditingController _review;
  late DateTime _readOn;
  double? _rating;
  String? _externalId;
  String? _coverUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _title = TextEditingController(text: book?.title ?? '');
    _author = TextEditingController(text: book?.author ?? '');
    _publicationYear = TextEditingController(
      text: book?.publicationYear?.toString() ?? '',
    );
    _description = TextEditingController(text: book?.description ?? '');
    _review = TextEditingController(text: book?.review ?? '');
    _readOn = book?.readOn ?? DateTime.now();
    _rating = book?.rating;
    _externalId = book?.externalId;
    _coverUrl = book?.coverUrl;
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _author,
      _publicationYear,
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

  Future<void> _lookUp() async {
    final source = ref.read(openLibrarySourceProvider);
    final picked = await showEnrichmentSheet(
      context: context,
      source: source,
      initialQuery: [_title.text.trim(), _author.text.trim()]
          .where((part) => part.isNotEmpty)
          .join(' '),
    );
    if (picked == null || !mounted) return;

    if (_author.text.trim().isEmpty && picked.author != null) {
      _author.text = picked.author!;
    }
    if (_description.text.trim().isEmpty && picked.description != null) {
      _description.text = picked.description!;
    }
    if (_publicationYear.text.trim().isEmpty && picked.releaseYear != null) {
      _publicationYear.text = '${picked.releaseYear}';
    }

    setState(() {
      _title.text = picked.title;
      _externalId = picked.externalId;
      _coverUrl = picked.posterUrl;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final saved = await guardSave(context, () async {
      final repository = ref.read(bookRepositoryProvider);
      final publicationYear = int.tryParse(_publicationYear.text.trim());
      final existing = widget.book;
      if (existing == null) {
        await repository.create(
          BookDraft(
            title: _title.text.trim(),
            readOn: _readOn,
            author: _trimmedOrNull(_author),
            description: _trimmedOrNull(_description),
            rating: _rating,
            review: _trimmedOrNull(_review),
            publicationYear: publicationYear,
            externalId: _externalId,
            coverUrl: _coverUrl,
          ),
        );
      } else {
        await repository.update(
          Book(
            id: existing.id,
            title: _title.text.trim(),
            readOn: _readOn,
            author: _trimmedOrNull(_author),
            description: _trimmedOrNull(_description),
            rating: _rating,
            review: _trimmedOrNull(_review),
            publicationYear: publicationYear,
            externalId: _externalId,
            coverUrl: _coverUrl,
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
      title: widget.isEditing ? l10n.editBook : l10n.newBook,
      formKey: _formKey,
      saving: _saving,
      onSave: _save,
      children: [
        TextFormField(
          controller: _title,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.fieldTitle),
          validator: (value) =>
              (value ?? '').trim().isEmpty ? l10n.fieldTitleRequired : null,
        ),
        Gap.vMd,
        TextFormField(
          controller: _author,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.fieldAuthor),
        ),
        Gap.vMd,
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _publicationYear,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.fieldPublicationYear),
              ),
            ),
            Gap.hMd,
            Expanded(
              child: DateField(
                label: l10n.fieldReadOn,
                value: _readOn,
                onChanged: (value) => setState(() => _readOn = value),
              ),
            ),
          ],
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
