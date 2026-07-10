import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Exact color tokens ported from the prototype `:root` CSS variables.
class K {
  // Purple tint ramp
  static const t9 = Color(0xFF1A0E3D);
  static const t8 = Color(0xFF2D1B69);
  static const t7 = Color(0xFF3D2582);
  static const t6 = Color(0xFF5B3E9E);
  static const t5 = Color(0xFF7C5CBF);
  static const t4 = Color(0xFFA07ED4);
  static const t3 = Color(0xFFC4AEE8);
  static const t2 = Color(0xFFD4C4EE);
  static const t1 = Color(0xFFEDE6F7);
  static const t0 = Color(0xFFF7F4FC);

  // Gold ramp
  static const g5 = Color(0xFFB45309);
  static const g4 = Color(0xFFD97706);
  static const g3 = Color(0xFFF5A623);
  static const g2 = Color(0xFFFDE68A);
  static const g1 = Color(0xFFFEF3D5);

  // Semantic
  static const ok = Color(0xFF16A34A);
  static const ok1 = Color(0xFFDCFCE7);
  static const er = Color(0xFFDC2626);
  static const er1 = Color(0xFFFEE2E2);
  static const inC = Color(0xFF1D4ED8);
  static const in1 = Color(0xFFDBEAFE);
  static const wa = Color(0xFFD97706);
  static const wa1 = Color(0xFFFEF3D5);

  // Ink / surfaces
  static const ink = Color(0xFF1A1028);
  static const ink2 = Color(0xFF3D2D5C);
  static const ink3 = Color(0xFF6B5A8A);
  static const ink4 = Color(0xFFA89BC0);
  static const cream = Color(0xFFF5EFE8);
  static const cream2 = Color(0xFFEDE5DB);
  static const white = Color(0xFFFFFFFF);

  // Borders (precomputed const ARGB from rgba(124,92,191,.13/.22))
  static const bd = Color(0x217C5CBF);
  static const bd2 = Color(0x387C5CBF);

  // Phone shell background
  static const phoneBg = Color(0xFF0C0918);

  static const sh = [
    BoxShadow(color: Color(0x125C3E9E), blurRadius: 8, offset: Offset(0, 2)),
  ];

  // Common gradients
  static const gPurple = LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [t5, t7]); // 135deg #7C5CBF -> #3D2582
  static const gPurpleDeep =
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [t9, t7]); // 1A0E3D -> 3D2582
  static const gGold =
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [g3, g4]); // F5A623 -> D97706
  static const gOk = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ok, Color(0xFF14532D)]);

  // 155deg dark header used across many screens
  static const gHeader = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.7, 1),
    colors: [t9, t7, t5],
  );
}

/// rem -> logical px (CSS base 16px, phone rendered at native width)
double rem(double r) => r * 16.0;

/// Font helpers (Sora = body, Fraunces = display, DM Mono = numeric)
TextStyle ff({double size = 14, FontWeight w = FontWeight.w400, Color color = K.ink, double? height, double? ls}) =>
    GoogleFonts.sora(fontSize: size, fontWeight: w, color: color, height: height, letterSpacing: ls);

TextStyle fd({double size = 18, FontWeight w = FontWeight.w800, Color color = K.ink, double? height, double? ls}) =>
    GoogleFonts.fraunces(fontSize: size, fontWeight: w, color: color, height: height, letterSpacing: ls);

TextStyle mono({double size = 14, FontWeight w = FontWeight.w700, Color color = K.ink, double? ls, double? height}) =>
    GoogleFonts.dmMono(fontSize: size, fontWeight: w, color: color, letterSpacing: ls, height: height);

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: K.cream,
    colorScheme: ColorScheme.fromSeed(seedColor: K.t6, primary: K.t6),
    textTheme: GoogleFonts.soraTextTheme(),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
