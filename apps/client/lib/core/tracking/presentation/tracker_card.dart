import 'package:flutter/material.dart';

import '../../../features/shared/widgets.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';

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
    this.photoPath,
    this.rating,
    this.placeholderIcon = Icons.bookmark_outline,
    this.pill,
  });

  final String title;

  /// The one line under the title: usually a place and a date.
  final String subtitle;
  final String? photoPath;
  final double? rating;
  final IconData placeholderIcon;

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
              EntryPhoto(
                path: photoPath,
                width: 78,
                height: 78,
                borderRadius: Radii.field,
                placeholderIcon: placeholderIcon,
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
