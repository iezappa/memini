import 'package:flutter/material.dart';

import 'tokens.dart';

/// Extra colours Material's ColorScheme has no slot for.
@immutable
class MeminiSemantics extends ThemeExtension<MeminiSemantics> {
  const MeminiSemantics({
    required this.escaped,
    required this.failed,
    required this.muted,
    required this.hairline,
    required this.page,
  });

  final Color escaped;
  final Color failed;
  final Color muted;
  final Color hairline;

  /// What the page is, under everything.
  ///
  /// It used to be the scaffold's own colour. The scaffold is transparent
  /// now so that one accent-tinted wash can run behind the whole app rather
  /// than being covered by each screen in turn, and this is the colour that
  /// wash fades into. See [AccentBackdrop].
  final Color page;

  @override
  MeminiSemantics copyWith({
    Color? escaped,
    Color? failed,
    Color? muted,
    Color? hairline,
    Color? page,
  }) {
    return MeminiSemantics(
      escaped: escaped ?? this.escaped,
      failed: failed ?? this.failed,
      muted: muted ?? this.muted,
      hairline: hairline ?? this.hairline,
      page: page ?? this.page,
    );
  }

  @override
  MeminiSemantics lerp(MeminiSemantics? other, double t) {
    if (other == null) return this;
    return MeminiSemantics(
      escaped: Color.lerp(escaped, other.escaped, t)!,
      failed: Color.lerp(failed, other.failed, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      page: Color.lerp(page, other.page, t)!,
    );
  }
}

extension MeminiThemeX on BuildContext {
  MeminiSemantics get semantics => Theme.of(this).extension<MeminiSemantics>()!;
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
}

abstract final class MeminiTheme {
  /// One family for everything.
  ///
  /// The headings used to be set in Fraunces, a high-contrast serif. It is a
  /// handsome face and it made a log of meals out and games read like a
  /// wine list: the app is somebody's own notebook, and the type should
  /// sound like them rather than like a printed menu. Inter at a heavier
  /// weight and tighter tracking does the work of a display face without
  /// the formality.
  ///
  /// Fraunces stays bundled and licensed, because the licence page lists
  /// what the build ships and the file is still in it.
  static const _display = 'Inter';
  static const _body = 'Inter';

  /// The accent replaces the primary role only.
  ///
  /// The paper and ink surfaces are hand-tuned and stay put: this app is a
  /// warm, dim room with coloured hardware, and regenerating the whole scheme
  /// from the seed — the way the sibling apps do — would repaint the room too.
  static ThemeData light([AppAccent accent = AppAccent.brass]) => _build(
    brightness: Brightness.light,
    scheme: ColorScheme.light(
      primary: accent.deepSeed,
      onPrimary: Colors.white,
      secondary: MeminiColors.escapedDeep,
      // White, not the default black: black on escapedDeep is 3.4:1, below
      // the 4.5:1 a selected segment's label needs.
      onSecondary: Colors.white,
      surface: MeminiColors.paperSurface,
      onSurface: MeminiColors.textOnPaper,
      surfaceContainerLowest: MeminiColors.paper,
      surfaceContainerHighest: MeminiColors.paperElevated,
      outlineVariant: MeminiColors.paperBorder,
      error: MeminiColors.failedDeep,
    ),
    semantics: const MeminiSemantics(
      escaped: MeminiColors.escapedDeep,
      failed: MeminiColors.failedDeep,
      muted: MeminiColors.mutedOnPaper,
      hairline: MeminiColors.paperBorder,
      page: MeminiColors.paper,
    ),
  );

  static ThemeData dark([AppAccent accent = AppAccent.brass]) => _build(
    brightness: Brightness.dark,
    scheme: ColorScheme.dark(
      primary: accent.seed,
      onPrimary: MeminiColors.ink,
      secondary: MeminiColors.escaped,
      surface: MeminiColors.inkSurface,
      onSurface: MeminiColors.textOnInk,
      surfaceContainerLowest: MeminiColors.ink,
      surfaceContainerHighest: MeminiColors.inkElevated,
      outlineVariant: MeminiColors.inkBorder,
      error: MeminiColors.failed,
    ),
    semantics: const MeminiSemantics(
      escaped: MeminiColors.escaped,
      failed: MeminiColors.failed,
      muted: MeminiColors.mutedOnInk,
      hairline: MeminiColors.inkBorder,
      page: MeminiColors.ink,
    ),
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required MeminiSemantics semantics,
  }) {
    final base = ThemeData(brightness: brightness, colorScheme: scheme);
    final onInk = brightness == Brightness.dark;

    // One face throughout, told apart by size and weight rather than by
    // family. Tight letter spacing on the big sizes is what keeps a sans
    // from reading as a sign rather than as a heading.
    final text = base.textTheme.copyWith(
      displaySmall: TextStyle(
        fontFamily: _display,
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: _display,
        fontSize: 25,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: _display,
        fontSize: 19,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: _body,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: _body,
        fontSize: 15,
        height: 1.55,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: _body,
        fontSize: 14,
        height: 1.5,
        color: scheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: _body,
        fontSize: 12.5,
        height: 1.4,
        color: semantics.muted,
      ),
      // Coloured explicitly: a label outside a button (the menu chips) has no
      // foreground to inherit, and a null colour painted it invisible.
      labelLarge: TextStyle(
        fontFamily: _body,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: scheme.onSurface,
      ),
      // Used for the small uppercase eyebrow labels above sections.
      labelSmall: TextStyle(
        fontFamily: _body,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: semantics.muted,
      ),
    );

    return base.copyWith(
      // Transparent, all of it: the page itself is painted once by
      // [AccentBackdrop], and a screen, a bar or a rail that brought its own
      // opaque colour would cut a rectangle out of the wash behind it.
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: text,
      extensions: [semantics],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      // Depth instead of an outline, where depth is visible.
      //
      // A 1px border around every card is what made the app read as a form:
      // the eye sees the boxes before it sees what is in them. On paper a
      // soft shadow does the same job of separating the card from the page
      // without drawing anything, so the border goes. On ink a shadow is
      // invisible — black on black — so there the hairline stays, and the
      // surface is a shade lighter than the page instead.
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: onInk ? 0 : 0.10),
        elevation: onInk ? 0 : 3,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.card,
          side: onInk
              ? BorderSide(color: semantics.hairline)
              : BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: semantics.hairline,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Gap.md,
          vertical: 15,
        ),
        // The fill is the field. A box drawn round a filled field says the
        // same thing twice, and once the boxes are gone the focus ring is
        // the only outline on the page — which is what makes it read as
        // focus rather than as decoration.
        border: const OutlineInputBorder(
          borderRadius: Radii.field,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: Radii.field,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.field,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: TextStyle(fontFamily: _body, color: semantics.muted),
        hintStyle: TextStyle(fontFamily: _body, color: semantics.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: 16),
          shape: const RoundedRectangleBorder(borderRadius: Radii.field),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: 16),
          shape: const RoundedRectangleBorder(borderRadius: Radii.field),
          side: BorderSide(color: semantics.hairline),
          foregroundColor: scheme.onSurface,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primary.withValues(alpha: 0.18),
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: Radii.pill),
        labelStyle: TextStyle(
          fontFamily: _body,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: text.bodyMedium,
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: Radii.field),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: Radii.sheet),
        titleTextStyle: text.titleLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      // A menu is a small card, so it is shaped like one.
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: Radii.field),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: Radii.field),
          ),
        ),
      ),
      // Squircle rather than circle: the shape the rest of the app is cut
      // to, at the size that makes it the loudest thing on the screen.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 5,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        extendedTextStyle: text.labelLarge?.copyWith(color: scheme.onPrimary),
        shape: const RoundedRectangleBorder(borderRadius: Radii.field),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: Radii.field),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          side: WidgetStatePropertyAll(
            BorderSide(color: semantics.hairline),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: Radii.pill),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: Radii.pill,
        ),
        elevation: 0,
        // Room for an icon and one line under it. Left to Material's
        // default the bar is taller than it needs to be on a phone.
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelSmall?.copyWith(color: semantics.muted),
        ),
      ),
    );
  }
}
