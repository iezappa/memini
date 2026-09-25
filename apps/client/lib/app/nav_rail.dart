import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import '../core/theme/tokens.dart';

/// One destination in the rail: what to draw, and what to call it.
typedef NavDestination = (IconData icon, IconData selected, String label);

/// The sections, down the side of a wide window.
///
/// Written rather than taken from `NavigationRail`, for two reasons. The
/// rail stacks a label under every icon and there is no way to turn that off
/// and keep the rail — and the bottom bar on a phone has hidden its labels
/// since the day the icons were chosen, so the two halves of the same app
/// disagreed about whether "Lugares donde comí" belongs on screen at all.
/// And a rail is a full-height slab of colour against a wall, which on a
/// page with a wash behind it is the one shape that cuts the wash in half.
///
/// So: icons only, the name in the tooltip and in what a screen reader
/// reads, and a panel that floats on the page with the wash running under
/// and around it.
class NavRail extends StatelessWidget {
  const NavRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.sm + 2, Gap.md, 0, Gap.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Barely there: enough to lift the icons off the page without
          // becoming the wall the rail used to be.
          color: context.colors.surface.withValues(alpha: 0.55),
          borderRadius: Radii.card,
          border: Border.all(color: context.semantics.hairline),
        ),
        child: SingleChildScrollView(
          // Eight destinations fit a laptop and do not fit a short window,
          // and a section you cannot reach is worse than one you scroll to.
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (index, destination) in destinations.indexed)
                  _RailButton(
                    destination: destination,
                    selected: index == selectedIndex,
                    onTap: () => onSelected(index),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, selectedIcon, label) = destination;
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 3),
      child: Tooltip(
        message: label,
        // To the side, where the rail is not: above the icon it would cover
        // the destination above it.
        preferBelow: false,
        verticalOffset: 0,
        margin: const EdgeInsets.only(left: 64),
        child: Semantics(
          label: label,
          selected: selected,
          button: true,
          child: Material(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: Radii.field,
            child: InkWell(
              borderRadius: Radii.field,
              onTap: onTap,
              child: SizedBox(
                // The 48 every tappable thing in this app is held to.
                width: 48,
                height: 48,
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: 22,
                  color: selected ? colors.onPrimary : context.semantics.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
