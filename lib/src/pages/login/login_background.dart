import 'package:flutter/material.dart';
import 'dart:math';

class LoginBackground extends StatelessWidget {
  final double animationValue;
  final double glowValue;
  const LoginBackground({
    super.key,
    required this.animationValue,
    required this.glowValue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Layer
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1A1A),
                const Color.fromARGB(255, 64, 65, 64),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Glow Circle
        Positioned(
          top: 100,
          right: -100,
          child: AnimatedOpacity(
            opacity: glowValue,
            duration: const Duration(milliseconds: 500),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.25),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
        ),

        // Particles
        Positioned.fill(
          child: CustomPaint(
            painter: _ParticlePainter(animationValue),
          ),
        ),
      ],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double value;
  _ParticlePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    const particleCount = 20;

    for (int i = 0; i < particleCount; i++) {
      final x = size.width * ((i + 1) / particleCount);
      final y = size.height * (0.3 +
          0.1 *
              sin(value *
                  6 +
                  i)); // animationValue ทำให้ particle เคลื่อนไหว

      canvas.drawCircle(Offset(x, y), 1.8, paint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
