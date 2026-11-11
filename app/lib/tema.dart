import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warna khas Agenda Kampus: merah marun ala kampus.
const warnaKhas = Color(0xFFB3261E);

/// Membuat tema terang/gelap dari satu warna seed.
/// [fontKustom] dimatikan di widget test agar tidak mengunduh font.
ThemeData buatTema(Brightness brightness, {bool fontKustom = true}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: warnaKhas,
    brightness: brightness,
  );
  final dasar = ThemeData(colorScheme: scheme, useMaterial3: true);
  return dasar.copyWith(
    // Font kustom dari paket google_fonts: Plus Jakarta Sans.
    textTheme: fontKustom
        ? GoogleFonts.plusJakartaSansTextTheme(dasar.textTheme)
        : dasar.textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
