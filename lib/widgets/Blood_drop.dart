// ============================================================================
// FILE: lib/widgets/blood_drop_icon.dart
// Custom blood drop icon widget
// ============================================================================

import 'package:flutter/material.dart';

class BloodDropIcon extends StatelessWidget {
  final double size;
  final Color color;

  BloodDropIcon({
    required this.size,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.2),
      painter: BloodDropPainter(color: color),
    );
  }
}

class BloodDropPainter extends CustomPainter {
  final Color color;

  BloodDropPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Draw blood drop shape
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.3,
      size.width * 0.9,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.9,
      size.width / 2,
      size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.9,
      size.width * 0.1,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.3,
      size.width / 2,
      0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}