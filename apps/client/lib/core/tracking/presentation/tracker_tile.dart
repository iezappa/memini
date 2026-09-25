import 'package:flutter/material.dart';

import '../../../features/shared/widgets.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'entry_cover.dart';

/// One entry in a grid: the picture first, the words under it.
///
/// The same five fields the row shows, ordered the other way round. A row
/// answers "what did I do and when"; a grid answers "which one was that",
/// so the cover gets the space and the date moves under the title.
class TrackerTile extends StatelessWidget {
  const TrackerTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.rating,
    this.icon = Icons.bookmark_outline,
    this.posterUrl,
    this.photoOwnerId,
  });

  final String title;
  final String subtitle;
  final double? rating;
  final IconData icon;
  final String? posterUrl;
  final String? photoOwnerId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  EntryCover(
                    icon: icon,
                    borderRadius: BorderRadius.zero,
                    posterUrl: posterUrl,
                    photoOwnerId: photoOwnerId,
                  ),
                  if (rating != null) ...[
                    // A wash from the top, so a score over bright artwork
                    // has something to sit on. Only where there is a score:
                    // darkening a cover for nothing is just a dirty cover.
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 72,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x66000000), Color(0x00000000)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: Gap.sm,
                      right: Gap.sm,
                      // On the picture rather than beside the title: the
                      // score is the one thing worth reading before the eye
                      // has found the name.
                      child: _ScorePip(rating: rating!),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.sm + 2,
                Gap.sm + 2,
                Gap.sm + 2,
                Gap.sm + 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: context.text.bodySmall?.copyWith(
                      color: context.semantics.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The score over a cover: white on a dark pill, so it reads on any picture.
///
/// The row's [ScoreBadge] sits on the page and can borrow the page's colours.
/// This one sits on somebody's poster and cannot borrow anything, so it
/// brings its own background.
class _ScorePip extends StatelessWidget {
  const _ScorePip({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    // Drop the trailing ".0", the way the row does: a 9 reads as "9".
    final label = rating == rating.roundToDouble()
        ? rating.toStringAsFixed(0)
        : rating.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 3),
      decoration: const BoxDecoration(
        color: Color(0xCC12100E),
        borderRadius: Radii.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: context.colors.primary),
          Gap.hXs,
          Text(
            label,
            style: context.text.labelLarge?.copyWith(
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
