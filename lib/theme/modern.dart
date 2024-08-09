import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension MetaStyles on TextTheme {
  TextStyle get metaText => GoogleFonts.titilliumWeb(fontSize: 16);
}

class ModernTheme {
  static ThemeData get darkTheme {
    const orangePrimaryValue = 0xFFF55951;

    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF543C52),
        secondary: Color(orangePrimaryValue),
        /* secondaryVariant: Color(0xFFF22C22), */
      ),
      primaryColor: const Color(0xFF543C52),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // scaffoldBackgroundColor: Color(0xFF361D32),
      scaffoldBackgroundColor: const Color(0xFF222222),
      fontFamily: GoogleFonts.titilliumWeb().fontFamily,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.quicksand(
          fontSize: 50,
          height: 1.1,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.quicksand(
          fontSize: 36,
          height: 1.1,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.quicksand(
          fontSize: 30,
          height: 1.0,
          color: Colors.grey.shade300,
        ),
        /*
        headline5: GoogleFonts.quicksand(
          fontSize: 24,
          height: 1.0,
          color: Colors.grey.shade300,
        ),*/
        bodyLarge: GoogleFonts.titilliumWeb(
          color: const Color(0xFFEEEEEE),
          height: 1,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.titilliumWeb(
          color: const Color(0xFFEEEEEE),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        colorScheme: const ColorScheme.dark(),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.white.withAlpha(20)),
          foregroundColor: WidgetStateProperty.all(
            const Color(orangePrimaryValue),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(orangePrimaryValue),
            width: 2.0,
          ),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(orangePrimaryValue),
          selectionColor: Color(orangePrimaryValue),
          selectionHandleColor: Color(orangePrimaryValue)),
    );
  }
}
