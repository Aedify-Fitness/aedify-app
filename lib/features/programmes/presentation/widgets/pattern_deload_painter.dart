import 'package:flutter/material.dart';
import 'package:aedify/shared/theme/app_spacing.dart';

class PatternDeloadPainter extends CustomPainter {
  const PatternDeloadPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = AppSizing.deloadLineStrokeWidth
      ..style = PaintingStyle.stroke;

    const spacing = AppSizing.deloadLineSpacing;
    final maxDim = size.width + size.height;

    for (var i = -maxDim; i < maxDim; i += spacing) {
      canvas.drawLine(
        Offset(i.toDouble(), -4),
        Offset(i + size.height, size.height + 4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PatternDeloadPainter oldDelegate) => false;
}
