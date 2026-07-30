import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class DeloadDiagonalPainter extends CustomPainter {
  const DeloadDiagonalPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = AppSizing.hairlineStrokeWidth
      ..style = PaintingStyle.stroke;

    for (var start = -size.height; start < size.width; start += AppSpacing.xl) {
      canvas.drawLine(
        Offset(start, size.height),
        Offset(start + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DeloadDiagonalPainter oldDelegate) =>
      oldDelegate.color != color;
}
