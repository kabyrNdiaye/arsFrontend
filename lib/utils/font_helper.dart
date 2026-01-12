import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Helper pour obtenir le style de texte avec Source Serif Pro
/// Utilise d'abord la police locale si disponible, sinon google_fonts (Source Serif 4)
TextStyle getSourceSerifProStyle({
  double? fontSize,
  FontWeight? fontWeight,
  double? letterSpacing,
  double? height,
  Color? color,
  FontStyle? fontStyle,
}) {
  // Essayer d'abord avec la police locale (si les fichiers sont dans assets/fonts/)
  // Note: Flutter détectera automatiquement si la police est disponible
  // Si elle n'est pas disponible, on utilisera google_fonts
  
  // Source Serif Pro a été renommé en Source Serif 4
  // Utilisons directement GoogleFonts.sourceSerif4 qui est disponible
  return GoogleFonts.sourceSerif4(
    fontSize: fontSize,
    fontWeight: fontWeight ?? FontWeight.w400,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
    fontStyle: fontStyle,
  );
}

/// Helper pour obtenir le style de texte avec Inter (selon spécifications Figma)
TextStyle getInterStyle({
  double? fontSize,
  FontWeight? fontWeight,
  double? letterSpacing,
  double? height,
  Color? color,
  FontStyle? fontStyle,
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight ?? FontWeight.w400,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
    fontStyle: fontStyle,
  );
}

