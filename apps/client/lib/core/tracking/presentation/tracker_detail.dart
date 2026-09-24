import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../features/shared/widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';

/// The detail layout every domain shares: title, one line of context,
/// the score, then whatever the domain wants to add.
class TrackerDetailBody extends StatelessWidget {
  const TrackerDetailBody({
    super.key,
    required this.title,
    required this.happenedOn,
    required this.rating,
    this.contextLine,
    this.badge,
    this.description,
    this.review,
    this.facts = const [],
    this.extra = const [],
    this.posterUrl,
    this.backdropUrl,
  });

  final String title;
  final DateTime happenedOn;
  final double? rating;

  /// Shown before the date, e.g. a venue or a franchise.
  final String? contextLine;

  /// The domain's own badge, beside the score.
  final Widget? badge;

  final String? description;
  final String? review;

  /// Short label/value pairs — director, platform, price. Empty values are
  /// dropped by the caller, so a sparse entry never shows blank rows.
  final List<({String label, String value})> facts;

  /// Anything the domain needs that is not a fact row, such as a setlist.
  final List<Widget> extra;

  /// The cover and the wide still, where the domain has artwork.
  ///
  /// With either of them the page opens on the picture instead of on a line
  /// of text: the still fills the header, blurred and darkened behind the
  /// title, and the cover sits on top of it. Without them the header is the
  /// title block it always was, which is what the other four domains get —
  /// nobody photographs the restaurant.
  final String? posterUrl;
  final String? backdropUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMMd(locale).format(happenedOn);

    final art = backdropUrl ?? posterUrl;

    final heading = <Widget>[
      Text(title, style: context.text.displaySmall),
      Gap.vXs,
      Text([?contextLine, date].join(' · '), style: context.text.bodySmall),
      Gap.vMd,
      Row(
        children: [
          ScoreBadge(rating: rating, large: true),
          if (badge != null) ...[Gap.hMd, badge!],
        ],
      ),
    ];

    final body = <Widget>[
      if (facts.isNotEmpty) ...[
        Gap.vXl,
        for (final fact in facts) _FactRow(fact: fact),
      ],
      if (description != null) ...[
        Gap.vXl,
        SectionLabel(l10n.fieldDescription),
        Gap.vSm,
        Text(description!, style: context.text.bodyLarge),
      ],
      ...extra,
      if (review != null) ...[
        Gap.vXl,
        SectionLabel(l10n.fieldReview),
        Gap.vSm,
        Text(review!, style: context.text.bodyLarge),
      ],
    ];

    // The header bleeds the full width of the window, so the column cap is
    // applied per block rather than around the whole page.
    return ListView(
      padding: const EdgeInsets.only(bottom: Gap.xl),
      children: [
        // Both columns start on the left. A `ListView` stretches what it is
        // given and a `Column` centres it, so wrapping these blocks to let
        // the header bleed the full width would have quietly centred every
        // paragraph on the page.
        if (art == null)
          ContentColumn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: heading,
            ),
          )
        else
          ArtHeader(backdropUrl: art, posterUrl: posterUrl, heading: heading),
        ContentColumn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: body,
          ),
        ),
      ],
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.fact});

  final ({String label, String value}) fact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              fact.label,
              style: context.text.bodySmall?.copyWith(
                color: context.semantics.muted,
              ),
            ),
          ),
          Gap.hSm,
          Expanded(child: Text(fact.value, style: context.text.bodyLarge)),
        ],
      ),
    );
  }
}

/// Confirms a destructive delete. Returns true only on an explicit yes.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// The picture the page opens on: the still behind, the cover in front.
///
/// Blurred and darkened rather than shown sharp. A still is a photograph
/// with its own subject and its own contrast, and text laid straight over
/// one is unreadable half the time — blurring it turns the picture into
/// what it is here, which is the colour of the thing being written about.
class ArtHeader extends StatelessWidget {
  const ArtHeader({
    required this.backdropUrl,
    required this.heading,
    this.posterUrl,
    super.key,
  });

  final String backdropUrl;
  final String? posterUrl;
  final List<Widget> heading;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: _RemoteImage(url: backdropUrl, fit: BoxFit.cover),
            ),
          ),
        ),
        // A scrim, and not a flat one: heaviest where the text sits and
        // lightest at the top, so the picture still reads as a picture.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dark
                    ? [Colors.black.withValues(alpha: 0.55), Colors.black]
                    : [
                        Colors.white.withValues(alpha: 0.70),
                        Colors.white.withValues(alpha: 0.94),
                      ],
              ),
            ),
          ),
        ),
        ContentColumn(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (posterUrl case final poster?) ...[
                  ClipRRect(
                    borderRadius: Radii.card,
                    // Width first, then the shape a film poster is printed
                    // in: the other way round the ratio has nothing to
                    // work from, since a row hands its children unbounded
                    // width.
                    child: SizedBox(
                      width: 148,
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: _RemoteImage(url: poster, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Gap.hMd,
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: heading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A picture from someone else's server, which may not arrive.
///
/// Nothing is cached to disk: the URL is stored, the bytes are not, so a
/// slow connection shows the space the image will take and a dead link
/// shows nothing at all. Neither is an error worth putting on screen —
/// the page is about the entry, not about the artwork.
class _RemoteImage extends StatelessWidget {
  const _RemoteImage({required this.url, required this.fit});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, _, _) =>
          ColoredBox(color: context.semantics.hairline),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : ColoredBox(color: context.semantics.hairline),
    );
  }
}
