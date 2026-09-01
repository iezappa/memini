import 'package:flutter/material.dart';

/// The raw palette. Every colour the app uses is named here once, so a theme
/// change never means hunting through widgets.
///
/// The mood is an escape room itself: a warm, dim space with brass hardware
/// catching the only light in the room.
abstract final class MeminiColors {
  // Warm neutrals — the "room".
  static const ink = Color(0xFF12100E);
  static const inkSurface = Color(0xFF1B1714);
  static const inkElevated = Color(0xFF241F1A);
  static const inkBorder = Color(0xFF322B24);

  static const paper = Color(0xFFFAF7F2);
  static const paperSurface = Color(0xFFFFFFFF);
  static const paperElevated = Color(0xFFF3EDE3);
  static const paperBorder = Color(0xFFE3DACB);

  // Brass — the hardware, the only saturated colour in the app.
  static const brass = Color(0xFFD1A954);
  static const brassDeep = Color(0xFF8A6A1F);

  // Outcome. Muted on purpose: a failed room is a memory, not an error.
  static const escaped = Color(0xFF7FA88A);
  static const escapedDeep = Color(0xFF3F6B50);
  static const failed = Color(0xFFB4756B);
  static const failedDeep = Color(0xFF8C4A3F);

  static const textOnInk = Color(0xFFF4EFE7);
  static const mutedOnInk = Color(0xFF9C9186);
  static const textOnPaper = Color(0xFF191512);
  static const mutedOnPaper = Color(0xFF6E655B);
}

/// Spacing scale. Multiples of 4, named so layouts read as intent.
/// The pickable accent colours, shared with the other apps in the family.
///
/// Brass comes first and is the default: it is the colour the whole palette
/// was built around, so an existing owner who never opens settings sees the
/// app they already had. The other six are the family set, every seed
/// desaturated so none of them shouts over the paper and ink around it.
enum AppAccent { brass, green, blue, pink, violet, orange, red }

extension AppAccentSeed on AppAccent {
  Color get seed => switch (this) {
    AppAccent.brass => MeminiColors.brass,
    AppAccent.green => const Color(0xFF5E8B7E),
    AppAccent.blue => const Color(0xFF5C7C9E),
    AppAccent.pink => const Color(0xFFB56C86),
    AppAccent.violet => const Color(0xFF7C6BA8),
    AppAccent.orange => const Color(0xFFC1804E),
    AppAccent.red => const Color(0xFFB25E54),
  };

  /// The darker tone the light theme uses, so the accent still reads as text
  /// on paper. Brass keeps its own hand-tuned pair.
  Color get deepSeed => switch (this) {
    AppAccent.brass => MeminiColors.brassDeep,
    _ => Color.lerp(seed, const Color(0xFF000000), 0.22)!,
  };
}

abstract final class Gap {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 40.0;

  /// The air between two settings sections.
  static const section = 28.0;

  static const hXs = SizedBox(width: xs);
  static const hSm = SizedBox(width: sm);
  static const hMd = SizedBox(width: md);
  static const vXs = SizedBox(height: xs);
  static const vSm = SizedBox(height: sm);
  static const vMd = SizedBox(height: md);
  static const vLg = SizedBox(height: lg);
  static const vXl = SizedBox(height: xl);
  static const vSection = SizedBox(height: section);
}

abstract final class Radii {
  static const card = BorderRadius.all(Radius.circular(14));
  static const field = BorderRadius.all(Radius.circular(10));
  static const pill = BorderRadius.all(Radius.circular(999));
}

/// Widest the content column ever gets. Beyond this, reading a review turns
/// into scanning a billboard.
const double kContentMaxWidth = 900;
