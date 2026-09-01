import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Caps and centres the content column so a review never runs the full width
/// of a desktop window.
class ContentColumn extends StatelessWidget {
  const ContentColumn({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: Gap.md),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Small uppercase label that opens a section.
///
/// It carries its own trailing gap, so a section is always the label followed
/// directly by its controls, with nothing in between to drift out of step
/// from one screen to the next.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Text(
        text.toUpperCase(),
        style: context.text.labelSmall?.copyWith(
          color: context.colors.primary,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The score, rendered as the one loud element on a card.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.rating, this.large = false});

  final double? rating;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final value = rating;
    final muted = context.semantics.muted;

    if (value == null) {
      return Text(
        AppLocalizations.of(context).notRated,
        style: context.text.bodySmall?.copyWith(color: muted),
      );
    }

    // Drop the trailing ".0" so a 9 reads as "9", not "9.0".
    final label = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Icon(
          Icons.star_rounded,
          size: large ? 26 : 18,
          color: context.colors.primary,
        ),
        Gap.hXs,
        Text(
          label,
          style: (large ? context.text.headlineMedium : context.text.titleLarge)
              ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
        Text(' / 10', style: context.text.bodySmall?.copyWith(color: muted)),
      ],
    );
  }
}

/// Escaped / did not escape, with the minutes left when they are known.
class OutcomePill extends StatelessWidget {
  const OutcomePill({super.key, required this.escaped, this.timeLeftMinutes});

  final bool escaped;
  final int? timeLeftMinutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = escaped
        ? context.semantics.escaped
        : context.semantics.failed;

    final minutes = timeLeftMinutes;
    final label = escaped && minutes != null
        ? '${l10n.escapedYes} · ${l10n.timeLeftValue(minutes)}'
        : (escaped ? l10n.escapedYes : l10n.escapedNo);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: Radii.pill,
        border: Border.all(color: color.withValues(alpha: 0.5)),
        color: color.withValues(alpha: 0.10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            escaped ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
            size: 13,
            color: color,
          ),
          Gap.hXs,
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A stored room photo, or a quiet placeholder when there is none.
/// Cover image for any tracked entry, falling back to a domain icon.
class EntryPhoto extends StatelessWidget {
  const EntryPhoto({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.borderRadius = Radii.card,
    this.placeholderIcon = Icons.bookmark_outline,
  });

  final String? path;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  /// Shown when there is no photo, or the file behind it is gone.
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: borderRadius,
        border: Border.all(color: context.semantics.hairline),
      ),
      child: Icon(
        placeholderIcon,
        color: context.semantics.muted.withValues(alpha: 0.6),
        size: 28,
      ),
    );

    final file = path;
    if (file == null || kIsWeb) return placeholder;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.file(
        File(file),
        width: width,
        height: height,
        fit: BoxFit.cover,
        // The file can be gone after a restore from another device's backup.
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

/// Centred message for an empty list, with an optional call to action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: context.semantics.muted),
            Gap.vMd,
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.titleLarge,
            ),
            if (body != null) ...[
              Gap.vSm,
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall,
                ),
              ),
            ],
            if (action != null) ...[Gap.vLg, action!],
          ],
        ),
      ),
    );
  }
}
