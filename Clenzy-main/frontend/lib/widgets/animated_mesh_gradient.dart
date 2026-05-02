import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedMeshGradient extends StatefulWidget {
  final List<Color> colors;
  final double speed;

  const AnimatedMeshGradient({
    super.key,
    required this.colors,
    this.speed = 1.0,
  });

  @override
  State<AnimatedMeshGradient> createState() => _AnimatedMeshGradientState();
}

class _AnimatedMeshGradientState extends State<AnimatedMeshGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: MeshGradientPainter(
            colors: widget.colors,
            animationValue: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class MeshGradientPainter extends CustomPainter {
  final List<Color> colors;
  final double animationValue;

  MeshGradientPainter({
    required this.colors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    for (int i = 0; i < colors.length; i++) {
      final color = colors[i];
      final phase = (i * pi * 2) / colors.length;
      final x = size.width / 2 +
          cos(animationValue * pi * 2 + phase) * (size.width * 0.4);
      final y = size.height / 2 +
          sin(animationValue * pi * 2 + phase * 1.5) * (size.height * 0.4);

      final radius = max(size.width, size.height) * 0.8;
      
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.6),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius))
        ..blendMode = BlendMode.screen;

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MeshGradientPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.colors != colors;
  }
}
