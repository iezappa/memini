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
  });

  final Color escaped;
  final Color failed;
  final Color muted;
  final Color hairline;

  @override
  MeminiSemantics copyWith({
    Color? escaped,
    Color? failed,
    Color? muted,
    Color? hairline,
  }) {
    return MeminiSemantics(
      escaped: escaped ?? this.escaped,
      failed: failed ?? this.failed,
      muted: muted ?? this.muted,
      hairline: hairline ?? this.hairline,
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
    );
  }
}

extension MeminiThemeX on BuildContext {
  MeminiSemantics get semantics => Theme.of(this).extension<MeminiSemantics>()!;
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
}

abstract final class MeminiTheme {
  static const _display = 'Fraunces';
  static const _body = 'Inter';

  static ThemeData light() => _build(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: MeminiColors.brassDeep,
      onPrimary: Colors.white,
      secondary: MeminiColors.escapedDeep,
      surface: MeminiColors.paperSurface,
      onSurface: MeminiColors.textOnPaper,
      surfaceContainerLowest: MeminiColors.paper,
      surfaceContainerHighest: MeminiColors.paperElevated,
      outlineVariant: MeminiColors.paperBorder,
      error: MeminiColors.failedDeep,
    ),
    background: MeminiColors.paper,
    semantics: const MeminiSemantics(
      escaped: MeminiColors.escapedDeep,
      failed: MeminiColors.failedDeep,
      muted: MeminiColors.mutedOnPaper,
      hairline: MeminiColors.paperBorder,
    ),
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme.dark(
      primary: MeminiColors.brass,
      onPrimary: MeminiColors.ink,
      secondary: MeminiColors.escaped,
      surface: MeminiColors.inkSurface,
      onSurface: MeminiColors.textOnInk,
      surfaceContainerLowest: MeminiColors.ink,
      surfaceContainerHighest: MeminiColors.inkElevated,
      outlineVariant: MeminiColors.inkBorder,
      error: MeminiColors.failed,
    ),
    background: MeminiColors.ink,
    semantics: const MeminiSemantics(
      escaped: MeminiColors.escaped,
      failed: MeminiColors.failed,
      muted: MeminiColors.mutedOnInk,
      hairline: MeminiColors.inkBorder,
    ),
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color background,
    required MeminiSemantics semantics,
  }) {
    final base = ThemeData(brightness: brightness, colorScheme: scheme);

    // Serif for anything that names a thing, sans for anything that is read
    // in bulk. Tight letter spacing on display sizes keeps the serif elegant
    // rather than airy.
    final text = base.textTheme.copyWith(
      displaySmall: TextStyle(
        fontFamily: _display,
        fontSize: 34,
        height: 1.15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: _display,
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: _display,
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
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
      labelLarge: const TextStyle(
        fontFamily: _body,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
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
      scaffoldBackgroundColor: background,
      textTheme: text,
      extensions: [semantics],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.card,
          side: BorderSide(color: semantics.hairline),
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
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: Radii.field,
          borderSide: BorderSide(color: semantics.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.field,
          borderSide: BorderSide(color: semantics.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.field,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
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
        backgroundColor: Colors.transparent,
        selectedColor: scheme.primary.withValues(alpha: 0.14),
        side: BorderSide(color: semantics.hairline),
        shape: const RoundedRectangleBorder(borderRadius: Radii.pill),
        labelStyle: TextStyle(fontFamily: _body, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: text.bodyMedium,
        shape: const RoundedRectangleBorder(borderRadius: Radii.field),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: Radii.card),
        titleTextStyle: text.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(text.bodySmall),
      ),
    );
  }
}
