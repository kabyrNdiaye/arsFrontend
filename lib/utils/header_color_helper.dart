import 'package:flutter/material.dart';

/// Helper class pour gérer les couleurs de header selon le type d'utilisateur
class HeaderColorHelper {
  // Couleurs principales selon le type d'utilisateur
  static const Color adminColor = Color(0xFF7B2CBF);      // Violet pour admin
  static const Color clientColor = Color(0xFF4CAF50);     // Vert pour client
  static const Color professionnelColor = Color(0xFF0059AB); // Bleu pour professionnel
  
  // Couleurs disponibles pour différents rôles de professionnels
  static const Map<String, Color> professionnelRoleColors = {
    'chef': Color(0xFF0053A6),         // Bleu profond pour chef
    'cuisinier': Color(0xFF0066CC),    // Bleu moyen pour cuisinier
    'aide_cuisine': Color(0xFF0073E6), // Bleu clair pour aide-cuisine
    'manager': Color(0xFF004080),     // Bleu foncé pour manager
  };

  /// Obtient la couleur du header selon le type d'utilisateur
  /// userType peut être: 'admin', 'client', 'professionnel'
  static Color getHeaderColor({
    String? userType,
    String? userRole,
    String? userEmail,
    String? userId,
  }) {
    // Priorité 1: Type d'utilisateur principal (admin, client, professionnel)
    if (userType != null) {
      switch (userType.toLowerCase()) {
        case 'admin':
          return adminColor;
        case 'client':
          return clientColor;
        case 'professionnel':
        case 'professional':
          // Si c'est un professionnel avec un rôle spécifique
          if (userRole != null && professionnelRoleColors.containsKey(userRole.toLowerCase())) {
            return professionnelRoleColors[userRole.toLowerCase()]!;
          }
          return professionnelColor;
        default:
          break;
      }
    }

    // Priorité 2: Rôle spécifique de professionnel
    if (userRole != null && professionnelRoleColors.containsKey(userRole.toLowerCase())) {
      return professionnelRoleColors[userRole.toLowerCase()]!;
    }

    // Priorité 3: Détection automatique basée sur l'email (si contient des mots-clés)
    if (userEmail != null) {
      final emailLower = userEmail.toLowerCase();
      if (emailLower.contains('admin') || emailLower.contains('@admin.')) {
        return adminColor;
      }
      if (emailLower.contains('client') || emailLower.contains('@client.')) {
        return clientColor;
      }
    }

    // Par défaut: Bleu pour professionnel
    return professionnelColor;
  }

  /// Génère une couleur cohérente basée sur une chaîne (email, ID, etc.)
  static Color _generateColorFromString(String input) {
    // Hash simple pour générer une couleur cohérente
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }

    // Générer une couleur dans la palette bleue (variations de bleu)
    final hue = (hash.abs() % 60) + 200; // Entre 200-260 (bleu)
    final saturation = 0.7 + (hash.abs() % 20) / 100; // Entre 0.7-0.9
    final brightness = 0.4 + (hash.abs() % 20) / 100; // Entre 0.4-0.6

    return HSVColor.fromAHSV(1.0, hue.toDouble(), saturation, brightness).toColor();
  }

  /// Détermine si les icônes de la barre de statut doivent être claires ou sombres
  static Brightness getStatusBarIconBrightness(Color headerColor) {
    // Calculer la luminosité de la couleur
    final luminance = headerColor.computeLuminance();
    // Si la couleur est sombre (luminance < 0.5), utiliser des icônes claires
    return luminance < 0.5 ? Brightness.light : Brightness.dark;
  }
}

