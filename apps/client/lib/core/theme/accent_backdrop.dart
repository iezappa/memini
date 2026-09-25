import 'package:flutter/material.dart';

import 'theme.dart';

/// The page the whole app sits on: the chosen accent, bled into the paper.
///
/// One layer for the entire app rather than a decoration per screen. Every
/// scaffold, bar and rail is transparent so this shows through all of them,
/// which is what makes the app read as one surface instead of a stack of
/// rectangles — and it is why the accent, which until now only coloured the
/// things you press, is finally visible on a screen that has nothing
/// pressed.
///
/// Two washes, both faint on purpose. The app is somebody's notebook and the
/// entries carry the colour; a background that competes with them is a
/// background you end up turning off.
class AccentBackdrop extends StatelessWidget {
  const AccentBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final page = context.semantics.page;
    final accent = context.colors.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;

    // Ink takes more colour before it shows: the same alpha that tints
    // paper visibly is invisible against a near-black page.
    final wash = dark ? 0.20 : 0.11;
    final bloom = dark ? 0.14 : 0.07;

    return DecoratedBox(
      // From the corner the reading starts in, out to nothing by half way
      // down — so the top of every screen is where the colour is and the
      // content lower down sits on plain page.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0, 0.55],
          colors: [
            Color.alphaBlend(accent.withValues(alpha: wash), page),
            page,
          ],
        ),
      ),
      child: DecoratedBox(
        // A second, rounder pool in the far corner, which is what keeps the
        // diagonal from reading as a straight fade across a flat sheet.
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(1.1, 1.0),
            radius: 1.1,
            colors: [
              accent.withValues(alpha: bloom),
              accent.withValues(alpha: 0),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
