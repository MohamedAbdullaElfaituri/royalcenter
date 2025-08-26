import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedGradientPainter extends CustomPainter {
  final double t;
  AnimatedGradientPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // ألوان متغيرة بناءً على الوقت
    final colorsA = [Color.lerp(const Color(0xFF0F172A), const Color(0xFF0EA5E9), (t + 0.0) % 1)!,
      Color.lerp(const Color(0xFF0F172A), const Color(0xFF8B5CF6), (t + 0.2) % 1)!];

    final colorsB = [Color.lerp(const Color(0xFF001219), const Color(0xFF06B6D4), (t + 0.5) % 1)!,
      Color.lerp(const Color(0xFF001219), const Color(0xFF7C3AED), (t + 0.7) % 1)!];

    final grad = LinearGradient(
      begin: Alignment(-0.8 + t, -0.6),
      end: Alignment(0.8 - t, 0.6),
      colors: [colorsA[0], colorsB[1], colorsA[1]],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()..shader = grad.createShader(rect);

    // رسم الخلفيّة
    canvas.drawRect(rect, paint);

    // لمعة (عناصر بيضاء شبه شفافة)
    final glowPaint = Paint()..color = Colors.white.withOpacity(0);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.18), size.width * 0.45, glowPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.82), size.width * 0.35, glowPaint);
  }

  @override
  bool shouldRepaint(covariant AnimatedGradientPainter oldDelegate) => oldDelegate.t != t;
}