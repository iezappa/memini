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
                  if (rating != null)
                    Positioned(
                      top: Gap.xs,
                      right: Gap.xs,
                      // On the picture rather than beside the title: the
                      // score is the one thing worth reading before the
                      // eye has found the name.
                      child: ScoreBadge(rating: rating),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Gap.sm),
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
