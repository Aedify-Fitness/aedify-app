import 'package:flutter/material.dart';

class PatternDeloadPainter extends CustomPainter {
  const PatternDeloadPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    final maxDim = size.width + size.height;

    for (var i = -maxDim; i < maxDim; i += spacing) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PatternDeloadPainter oldDelegate) => false;
}
