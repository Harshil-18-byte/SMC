import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Replaces generic rounded dialogs with a "Pinned Sticky Note" or
/// "Prescription Pad" modal. Adds jagged borders, a realistic drop shadow,
/// and a pin/tape visual at the top.
class MedicalStickyNoteDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;
  final Color noteColor;

  const MedicalStickyNoteDialog({
    super.key,
    required this.title,
    required this.content,
    this.primaryActionText,
    this.onPrimaryAction,
    this.noteColor = const Color(0xFFF9F6AA), // Classic pale yellow sticky
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        const Color(0xFF2C2825); // Always dark text on sticky note

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // The sticky note paper
          CustomPaint(
            painter: _StickyNotePainter(color: noteColor),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 40, left: 24, right: 24, bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: textColor.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    style: GoogleFonts.caveat(
                      color: textColor,
                      fontSize: 22,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'CANCEL',
                          style: GoogleFonts.outfit(
                            color: textColor.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (primaryActionText != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onPrimaryAction?.call();
                          },
                          child: Text(
                            primaryActionText!,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFC62828), // Clinical Red
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // The pinning tape at the top center
          Positioned(
            top: -10,
            child: Container(
              width: 80,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyNotePainter extends CustomPainter {
  final Color color;

  _StickyNotePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // A slightly wavy, imperfect square for the note
    final path = Path();
    path.moveTo(0, 5);
    path.quadraticBezierTo(w * 0.5, -2, w, 3);
    path.lineTo(w - 2, h - 10);
    // Curl at bottom right
    path.quadraticBezierTo(w - 15, h - 2, w - 25, h);
    path.lineTo(5, h - 3);
    path.close();

    // Drop shadow (sharp/dark at curl)
    canvas.drawShadow(path, Colors.black, 6, true);

    // Note base
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);

    // Bottom right curl highlight
    final curlPath = Path();
    curlPath.moveTo(w - 2, h - 10);
    curlPath.quadraticBezierTo(w - 15, h - 2, w - 25, h);
    curlPath.quadraticBezierTo(w - 10, h - 8, w - 2, h - 10);

    canvas.drawPath(
      curlPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _StickyNotePainter old) => old.color != color;
}

/// Helper method to easily show the sticky note
Future<void> showMedicalStickyNote(
  BuildContext context, {
  required String title,
  required String content,
  String? primaryActionText,
  VoidCallback? onPrimaryAction,
}) {
  return showDialog(
    context: context,
    builder: (context) => MedicalStickyNoteDialog(
      title: title,
      content: content,
      primaryActionText: primaryActionText,
      onPrimaryAction: onPrimaryAction,
    ),
  );
}
