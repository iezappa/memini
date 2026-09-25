import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../photos/presentation/photo_providers.dart';
import '../../theme/theme.dart';

/// The picture on an entry's card, filling whatever box it is given.
///
/// Three sources, in the order the owner would expect: the artwork a lookup
/// found, then the photograph they took themselves, then the domain's icon.
/// The middle one is the point — a meal, an escape room and a concert have
/// no service to ask for a cover, and until photos came back their cards
/// were a wall of identical icons.
class EntryCover extends ConsumerWidget {
  const EntryCover({
    super.key,
    required this.icon,
    required this.borderRadius,
    this.posterUrl,
    this.photoOwnerId,
  });

  final IconData icon;
  final BorderRadius borderRadius;

  /// A poster or cover held as an address, fetched from the service's host.
  final String? posterUrl;

  /// The entry whose own photographs to fall back on.
  final String? photoOwnerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (posterUrl case final poster?) {
      return _clipped(
        context,
        Image.network(
          poster,
          fit: BoxFit.cover,
          // A dead link falls back to the icon the card would have had,
          // rather than to a broken-image box.
          errorBuilder: (context, _, _) => _placeholder(context),
        ),
      );
    }

    if (photoOwnerId case final ownerId?) {
      final photo = ref.watch(entryCoverProvider(ownerId)).valueOrNull;
      if (photo != null) {
        return _clipped(context, Image.memory(photo.bytes, fit: BoxFit.cover));
      }
    }

    return _placeholder(context);
  }

  Widget _clipped(BuildContext context, Widget child) => ClipRRect(
    borderRadius: borderRadius,
    child: SizedBox.expand(child: child),
  );

  /// No border on it: with the cards unboxed this was the only outline left
  /// on a list, and an entry with no picture was drawn louder than one with.
  Widget _placeholder(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerHighest,
      borderRadius: borderRadius,
    ),
    child: Center(
      child: Icon(
        icon,
        color: context.semantics.muted.withValues(alpha: 0.6),
        size: 28,
      ),
    ),
  );
}
