import 'package:flutter/material.dart';

import 'theme.dart';

/// The page the whole app sits on: the chosen accent, bled into the paper.
///
/// One layer for the entire app rather than a decoration per screen. Every
/// scaffold, bar and rail is transparent so this shows through all of them,
/// which is what makes the app read as one surface instead of a stack of
/// rectangles — and it is why the accent, which until now only coloured the
/// things you press, is visible on a screen that has nothing pressed.
class AccentBackdrop extends StatelessWidget {
  const AccentBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final page = context.semantics.page;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tint = tintedPage(page, context.colors.primary, dark: dark);

    return DecoratedBox(
      // From the corner the reading starts in, out to the page by three
      // quarters of the way down — far enough that the colour is still
      // there when the eye reaches the first card.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0, 0.75],
          colors: [tint, page],
        ),
      ),
      child: DecoratedBox(
        // A second, rounder pool in the far corner, which keeps the diagonal
        // from reading as a straight fade across a flat sheet. The same
        // colour, so nowhere on the page is more tinted than [tint] — which
        // is the one background the text has to stay legible against.
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(1.1, 1.0),
            radius: 1.2,
            colors: [
              tint.withValues(alpha: 0.85),
              tint.withValues(alpha: 0),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// The page, in the accent's colour but at the page's own brightness.
///
/// Mixing an accent into the page at any real strength lightens it, and a
/// lighter page is one that small grey text stops being legible on — which
/// is exactly what happened when this was a plain blend: a 38% brass wash
/// took the section labels down to 4.2:1, under the 4.5 the contrast tests
/// hold every screen to.
///
/// So the mix is heavy and then the result is put back at the page's own
/// lightness, give or take a nudge. The hue arrives at full strength, the
/// brightness barely moves, and the contrast of everything drawn on top is
/// the contrast it always had. It also means a pale accent and a dark one
/// tint the page by the same amount, rather than brass washing it out while
/// violet barely shows.
Color tintedPage(Color page, Color accent, {required bool dark}) {
  final mixed = HSLColor.fromColor(
    Color.alphaBlend(accent.withValues(alpha: 0.55), page),
  );
  final lightness = HSLColor.fromColor(page).lightness;

  // Up on ink, down on paper: in both directions away from the page, so the
  // tint is a shade of the room rather than a light left on in it.
  final lift = dark ? 0.09 : -0.045;

  return mixed.withLightness((lightness + lift).clamp(0.0, 1.0)).toColor();
}
