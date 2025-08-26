import 'package:flutter/material.dart';

class FeatureChip extends StatelessWidget {
  final String text;
  const FeatureChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7), // خلفية أغمق لتباين أعلى
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
          color: Colors.white, // أبيض صافي لقراءة أفضل
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
