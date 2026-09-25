import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../features/shared/widgets.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../domain/map_point.dart';
import 'map_preview.dart';

/// Where a place is, from the link the owner pasted.
///
/// Three states, and the middle one is the reason this is a widget rather
/// than a call to [MapPreview]: a link with coordinates in it draws a map, a
/// link without them still opens, and no link at all shows nothing.
class MapSection extends StatelessWidget {
  const MapSection({super.key, required this.mapsUrl});

  final String? mapsUrl;

  Future<void> _open() async {
    final url = Uri.tryParse(mapsUrl!.trim());
    if (url == null) return;

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final link = mapsUrl?.trim();
    if (link == null || link.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final point = parseMapLink(link);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap.vXl,
        SectionLabel(l10n.mapLabel),
        if (point != null) ...[
          // The map is the button: tapping the picture opens the place in
          // whatever map app the owner actually uses.
          InkWell(
            borderRadius: Radii.card,
            onTap: _open,
            child: MapPreview(point: point),
          ),
          Gap.vSm,
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _open,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(l10n.mapOpen),
          ),
        ),
        if (point == null)
          Text(
            l10n.mapNoCoordinates,
            style: context.text.bodySmall?.copyWith(
              color: context.semantics.muted,
            ),
          ),
      ],
    );
  }
}
