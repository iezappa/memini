import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/tracking/presentation/form_fields.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/meal.dart';
import 'meal_providers.dart';

class MealFormScreen extends ConsumerStatefulWidget {
  const MealFormScreen({super.key, this.meal});

  /// Null when adding, the existing entry when editing.
  final Meal? meal;

  bool get isEditing => meal != null;

  @override
  ConsumerState<MealFormScreen> createState() => _MealFormScreenState();
}

class _MealFormScreenState extends ConsumerState<MealFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _dish;
  late final TextEditingController _price;
  late final TextEditingController _company;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late final TextEditingController _review;

  late DateTime _happenedOn;
  double? _rating;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final meal = widget.meal;

    _title = TextEditingController(text: meal?.title ?? '');
    _dish = TextEditingController(text: meal?.dish ?? '');
    _price = TextEditingController(text: meal?.price?.toString() ?? '');
    _company = TextEditingController(text: meal?.company ?? '');
    _location = TextEditingController(text: meal?.location ?? '');
    _description = TextEditingController(text: meal?.description ?? '');
    _review = TextEditingController(text: meal?.review ?? '');

    _happenedOn = meal?.happenedOn ?? DateTime.now();
    _rating = meal?.rating;
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _dish,
      _price,
      _company,
      _location,
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final repository = ref.read(mealRepositoryProvider);
    // A comma is the decimal separator here, and a stray one would otherwise
    // silently drop the price rather than record it.
    final price = double.tryParse(_price.text.trim().replaceAll(',', '.'));

    final existing = widget.meal;
    if (existing == null) {
      await repository.create(
        MealDraft(
          title: _title.text.trim(),
          happenedOn: _happenedOn,
          description: _trimmedOrNull(_description),
          rating: _rating,
          review: _trimmedOrNull(_review),
          dish: _trimmedOrNull(_dish),
          price: price,
          company: _trimmedOrNull(_company),
          location: _trimmedOrNull(_location),
        ),
      );
    } else {
      await repository.update(
        Meal(
          id: existing.id,
          title: _title.text.trim(),
          happenedOn: _happenedOn,
          description: _trimmedOrNull(_description),
          rating: _rating,
          review: _trimmedOrNull(_review),
          dish: _trimmedOrNull(_dish),
          price: price,
          company: _trimmedOrNull(_company),
          location: _trimmedOrNull(_location),
        ),
      );
    }

    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TrackerFormScaffold(
      title: widget.isEditing ? l10n.editMeal : l10n.newMeal,
      formKey: _formKey,
      saving: _saving,
      onSave: _save,
      children: [
        TextFormField(
          controller: _title,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.fieldPlace),
          validator: (value) =>
              (value ?? '').trim().isEmpty ? l10n.fieldPlaceRequired : null,
        ),
        Gap.vMd,
        TextFormField(
          controller: _location,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.fieldLocation),
        ),
        Gap.vMd,
        DateField(
          label: l10n.fieldAte,
          value: _happenedOn,
          onChanged: (value) => setState(() => _happenedOn = value),
        ),
        Gap.vMd,
        TextFormField(
          controller: _dish,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.fieldDish),
        ),
        Gap.vMd,
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.fieldPrice),
              ),
            ),
            Gap.hMd,
            Expanded(
              child: TextFormField(
                controller: _company,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.fieldCompany),
              ),
            ),
          ],
        ),
        Gap.vLg,
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
