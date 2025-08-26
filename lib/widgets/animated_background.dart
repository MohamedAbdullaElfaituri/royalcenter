import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

// ================== FeatureChip ==================
class FeatureChip extends StatelessWidget {
  final String text;
  const FeatureChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          shadows: [
            Shadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== LeftPanel ==================
class LeftPanel extends StatelessWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // شعار دائري
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4FC3F7),
                      Color(0xFF3B82F6),
                      Color(0xFF7C3AED)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 3,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.1, 0.9],
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.local_car_wash_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Transform.rotate(
                        angle: 0.5,
                        child: Icon(
                          Icons.star_rounded,
                          size: 24,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // العنوان
              ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF3B82F6)],
                  ).createShader(bounds);
                },
                child: Text(
                  'منظومة الغسيل الماليّة',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 28,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'نظام متكامل لإدارة مغاسل السيارات باحترافية عالية',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  height: 1.5,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // الميزات
              Column(
                children: const [
                  FeatureChip(text: '📊 تقارير يومية مفصلة'),
                  SizedBox(height: 10),
                  FeatureChip(text: '🧾 طباعة إيصالات احترافية'),
                  SizedBox(height: 10),
                  FeatureChip(text: '👥 إدارة متقدمة للموظفين'),
                  SizedBox(height: 10),
                  FeatureChip(text: '☁️ نسخ احتياطي تلقائي'),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'نحو إدارة أكثر ذكاءً',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blueAccent[100],
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== AnimatedBackground ==================
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: _AnimatedGradientPainter(_bgController.value),
        );
      },
    );
  }
}

class _AnimatedGradientPainter extends CustomPainter {
  final double animationValue;
  _AnimatedGradientPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      colors: [
        Colors.blue.shade400,
        Colors.purple.shade400,
        Colors.blue.shade300,
      ],
      stops: [
        (0.0 + animationValue) % 1,
        (0.5 + animationValue) % 1,
        (1.0 + animationValue) % 1,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedGradientPainter oldDelegate) => true;
}
