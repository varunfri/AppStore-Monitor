import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Apple iOS HIG System Colors (Light / Dark responsive dynamically via Theme/ColorScheme)
  static const Color iosBlueLight = Color(0xFF007AFF);
  static const Color iosBlueDark = Color(0xFF0A84FF);

  static const Color iosGreenLight = Color(0xFF34C759);
  static const Color iosGreenDark = Color(0xFF30D158);

  static const Color iosOrangeLight = Color(0xFFFF9500);
  static const Color iosOrangeDark = Color(0xFFFF9F0A);

  static const Color iosRedLight = Color(0xFFFF3B30);
  static const Color iosRedDark = Color(0xFFFF453A);

  static const Color iosIndigoLight = Color(0xFF5856D6);
  static const Color iosIndigoDark = Color(0xFF5E5CE6);

  // Keep static constants for compatibility, using the dark/system-wide standard colors
  static const Color primaryBlue = iosBlueLight;
  static const Color accentIndigo = iosIndigoLight;
  static const Color successGreen = iosGreenLight;
  static const Color warningOrange = iosOrangeLight;
  static const Color errorRed = iosRedLight;

  // Semantic Light Mode Colors
  static const Color lightBg = Color(0xFFF2F2F7); // Apple System Grouped Background
  static const Color lightCardBg = Color(0xFFFFFFFF); // Apple System Background
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF3C3C43);
  static const Color lightTextMuted = Color(0xFF8E8E93);
  static const Color lightBorder = Color(0xFFE5E5EA);

  // Semantic Dark Mode Colors
  static const Color darkBg = Color(0xFF000000); // Apple Pure Black System Background
  static const Color darkCardBg = Color(0xFF1C1C1E); // Apple Secondary System Grouped Background
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFEBEBF5);
  static const Color darkTextMuted = Color(0xFF8E8E93);
  static const Color darkBorder = Color(0xFF38383A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: iosBlueLight,
      cardColor: lightCardBg,
      dividerColor: lightBorder,
      colorScheme: const ColorScheme.light(
        primary: iosBlueLight,
        secondary: iosIndigoLight,
        surface: lightCardBg,
        error: iosRedLight,
        outline: lightBorder,
        outlineVariant: lightBorder,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: lightTextPrimary, fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: lightTextPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: lightTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 14, fontWeight: FontWeight.normal),
          bodySmall: TextStyle(color: lightTextMuted, fontSize: 12, fontWeight: FontWeight.normal),
          labelLarge: TextStyle(color: lightTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE5E5EA).withOpacity(0.5),
        hintStyle: const TextStyle(color: lightTextMuted, fontSize: 14),
        labelStyle: const TextStyle(color: lightTextSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: iosBlueLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: iosRedLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: iosBlueLight,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: iosBlueLight,
          side: const BorderSide(color: iosBlueLight),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: lightBorder, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: lightTextPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: iosBlueLight),
        shape: Border(bottom: BorderSide(color: lightBorder, width: 0.5)),
      ),
      dividerTheme: const DividerThemeData(color: lightBorder, thickness: 0.5, space: 1),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: iosBlueDark,
      cardColor: darkCardBg,
      dividerColor: darkBorder,
      colorScheme: const ColorScheme.dark(
        primary: iosBlueDark,
        secondary: iosIndigoDark,
        surface: darkCardBg,
        error: iosRedDark,
        outline: darkBorder,
        outlineVariant: darkBorder,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: darkTextPrimary, fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: darkTextPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 14, fontWeight: FontWeight.normal),
          bodySmall: TextStyle(color: darkTextMuted, fontSize: 12, fontWeight: FontWeight.normal),
          labelLarge: TextStyle(color: darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C1C1E).withOpacity(0.5),
        hintStyle: const TextStyle(color: darkTextMuted, fontSize: 14),
        labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: iosBlueDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: iosRedDark, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: iosBlueDark,
          foregroundColor: Colors.black,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: iosBlueDark,
          side: const BorderSide(color: iosBlueDark),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorder, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: darkTextPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: iosBlueDark),
        shape: Border(bottom: BorderSide(color: darkBorder, width: 0.5)),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 0.5, space: 1),
    );
  }

  static CupertinoThemeData get cupertinoTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: CupertinoColors.activeBlue,
      barBackgroundColor: Color(0xEE1C1C1E),
      scaffoldBackgroundColor: CupertinoColors.black,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.white,
        navLargeTitleTextStyle: TextStyle(
          inherit: false,
          color: CupertinoColors.white,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        navTitleTextStyle: TextStyle(
          inherit: false,
          color: CupertinoColors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        textStyle: TextStyle(
          inherit: false,
          color: CupertinoColors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
