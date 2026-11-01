import 'package:flutter/material.dart';

import 'colors.dart';

abstract final class PerfKitTheme {
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Segoe UI',
    );

    return base.copyWith(
      scaffoldBackgroundColor: PerfKitColors.background,
      colorScheme: const ColorScheme.dark(
        primary: PerfKitColors.accent,
        onPrimary: PerfKitColors.background,
        secondary: PerfKitColors.accent,
        surface: PerfKitColors.surface,
        onSurface: PerfKitColors.primaryText,
        error: PerfKitColors.danger,
        outline: PerfKitColors.border,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PerfKitColors.background,
        foregroundColor: PerfKitColors.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: PerfKitColors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: PerfKitColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: PerfKitColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: PerfKitColors.border,
        thickness: 1,
        space: 1,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: PerfKitColors.surface,
        selectedIconTheme: IconThemeData(color: PerfKitColors.accent),
        unselectedIconTheme: IconThemeData(color: PerfKitColors.secondaryText),
        selectedLabelTextStyle: TextStyle(
          color: PerfKitColors.primaryText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: PerfKitColors.secondaryText,
          fontSize: 12,
        ),
        indicatorColor: PerfKitColors.accentMuted,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PerfKitColors.surface,
        indicatorColor: PerfKitColors.accentMuted,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? PerfKitColors.primaryText
                : PerfKitColors.secondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? PerfKitColors.accent
                : PerfKitColors.secondaryText,
          );
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PerfKitColors.accentMuted;
            }
            return PerfKitColors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PerfKitColors.accent;
            }
            return PerfKitColors.secondaryText;
          }),
          side: const WidgetStatePropertyAll(
            BorderSide(color: PerfKitColors.border),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PerfKitColors.accent,
          foregroundColor: PerfKitColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PerfKitColors.primaryText,
          side: const BorderSide(color: PerfKitColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PerfKitColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: PerfKitColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: PerfKitColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: PerfKitColors.accent),
        ),
        hintStyle: const TextStyle(color: PerfKitColors.secondaryText),
        labelStyle: const TextStyle(color: PerfKitColors.secondaryText),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PerfKitColors.surfaceElevated,
        selectedColor: PerfKitColors.accentMuted,
        side: const BorderSide(color: PerfKitColors.border),
        labelStyle: const TextStyle(color: PerfKitColors.primaryText),
        secondaryLabelStyle: const TextStyle(
          color: PerfKitColors.secondaryText,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: PerfKitColors.primaryText,
        displayColor: PerfKitColors.primaryText,
      ),
    );
  }
}
