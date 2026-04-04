import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Industrial Visual Utils
/// Provides rugged, high-contrast, and field-ready UI components for the inspection platform.
class IndustrialVisuals {
  static const Color primaryTech = Color(0xFF137fec);
  static const Color cautionYellow = Color(0xFFFFAB00);
  static const Color dangerRed = Color(0xFFFF4D4D);
  static const Color successGreen = Color(0xFF10B981);
  static const Color ruggedDark = Color(0xFF111418);
  static const Color slateGrey = Color(0xFF6B7280);

  /// Industrial Button Theme
  static Widget largeActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color color = primaryTech,
    bool isFullWidth = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Status Badge
  static Widget statusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'critical':
      case 'rejected':
      case 'failed':
        bgColor = dangerRed.withValues(alpha: 0.1);
        textColor = dangerRed;
        break;
      case 'non-compliant':
      case 'in_progress':
      case 'pending':
        bgColor = cautionYellow.withValues(alpha: 0.1);
        textColor = cautionYellow;
        break;
      case 'compliant':
      case 'approved':
      case 'completed':
        bgColor = successGreen.withValues(alpha: 0.1);
        textColor = successGreen;
        break;
      default:
        bgColor = slateGrey.withValues(alpha: 0.1);
        textColor = slateGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.outfit(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Grid Background Texture (Simulating blueprint/construction paper)
  static Widget blueprintBackground({required Widget child, bool isDark = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        image: DecorationImage(
          image: const AssetImage('assets/images/grid_texture.png'), // Will fallback if missing
          repeat: ImageRepeat.repeat,
          opacity: isDark ? 0.05 : 0.1,
        ),
      ),
      child: child,
    );
  }
}
