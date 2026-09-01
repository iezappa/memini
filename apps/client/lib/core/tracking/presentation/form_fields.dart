import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../features/shared/widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../domain/trackable.dart';

/// Cover picker, identical in all five forms.
class PhotoField extends StatelessWidget {
  const PhotoField({
    super.key,
    required this.path,
    required this.onPick,
    required this.onRemove,
    this.placeholderIcon = Icons.bookmark_outline,
  });

  final String? path;
  final VoidCallback onPick;
  final VoidCallback? onRemove;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap.vMd,
        AspectRatio(
          aspectRatio: 16 / 9,
          child: EntryPhoto(
            path: path,
            width: double.infinity,
            placeholderIcon: placeholderIcon,
          ),
        ),
        Gap.vSm,
        Row(
          children: [
            TextButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: Text(path == null ? l10n.photoAdd : l10n.photoReplace),
            ),
            if (onRemove != null)
              TextButton(onPressed: onRemove, child: Text(l10n.photoRemove)),
          ],
        ),
      ],
    );
  }
}

/// The 0–10 slider, with an explicit way back to "not rated".
///
/// Unrated has to stay reachable: a score of zero is a verdict, and silently
/// turning "I have not decided" into a zero would corrupt every average.
class RatingField extends StatelessWidget {
  const RatingField({super.key, required this.value, required this.onChanged});

  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionLabel(l10n.fieldRating),
            ScoreBadge(rating: value),
          ],
        ),
        Slider(
          value: value ?? kMinRating,
          min: kMinRating,
          max: kMaxRating,
          divisions: 20,
          label: (value ?? 0).toStringAsFixed(1),
          onChanged: onChanged,
        ),
        if (value != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onChanged(null),
              child: Text(l10n.notRated),
            ),
          ),
      ],
    );
  }
}

/// A tappable date row that opens the platform picker.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();

    return InkWell(
      borderRadius: Radii.field,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(1970),
          // Nothing can be logged before it happened.
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          DateFormat.yMMMd(locale).format(value),
          style: context.text.bodyLarge,
        ),
      ),
    );
  }
}

/// A segmented picker for a small, closed set of options.
class ChoiceField<T> extends StatelessWidget {
  const ChoiceField({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        Gap.vSm,
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (final option in values)
              ChoiceChip(
                label: Text(labelOf(option)),
                selected: option == value,
                onSelected: (_) => onChanged(option),
              ),
          ],
        ),
      ],
    );
  }
}

/// The frame every entry form shares: a save action in the bar and at the
/// bottom, a scrolling body, and the same padding in all five.
class TrackerFormScaffold extends StatelessWidget {
  const TrackerFormScaffold({
    super.key,
    required this.title,
    required this.formKey,
    required this.saving,
    required this.onSave,
    required this.children,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final bool saving;
  final VoidCallback onSave;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(onPressed: saving ? null : onSave, child: Text(l10n.save)),
          Gap.hSm,
        ],
      ),
      body: SafeArea(
        child: ContentColumn(
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.only(bottom: Gap.xl),
              children: [
                ...children,
                Gap.vLg,
                FilledButton(
                  onPressed: saving ? null : onSave,
                  child: Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
