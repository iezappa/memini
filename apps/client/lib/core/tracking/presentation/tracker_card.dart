import 'package:flutter/material.dart';

import '../../../features/shared/widgets.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'entry_cover.dart';

/// One row in any tracked list.
///
/// The five domains show the same three things — what it was, when, and the
/// score — so the row is written once. What differs goes in [pill]: a room
/// shows whether the team escaped, a game how far the owner got.
class TrackerCard extends StatelessWidget {
  const TrackerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.rating,
    this.icon = Icons.bookmark_outline,
    this.pill,
    this.posterUrl,
    this.photoOwnerId,
  });

  final String title;

  /// The one line under the title: usually a place and a date.
  final String subtitle;
  final double? rating;

  /// The domain's icon, shown on a tile before the title.
  ///
  /// Replaced by [posterUrl] where there is one: a cover says which film
  /// this is from across the room, and the icon only ever said "film".
  final IconData icon;

  /// The cover, for a domain that has artwork.
  final String? posterUrl;

  /// The entry itself, so a domain with no artwork can show the photograph
  /// the owner attached to it.
  final String? photoOwnerId;

  /// The domain's own badge, shown under the subtitle when there is one.
  final Widget? pill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Gap.sm + 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                // The shape a poster is printed in, so a row of them lines
                // up whatever the artwork behind it does — and so every
                // domain's rows are the same height, cover or no cover.
                height: 66,
                child: EntryCover(
                  icon: icon,
                  borderRadius: Radii.field,
                  posterUrl: posterUrl,
                  photoOwnerId: photoOwnerId,
                ),
              ),
              Gap.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (pill != null) ...[Gap.vSm, pill!],
                  ],
                ),
              ),
              Gap.hSm,
              ScoreBadge(rating: rating),
            ],
          ),
        ),
      ),
    );
  }
}
