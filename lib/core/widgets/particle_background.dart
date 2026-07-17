import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class _Particle {
  _Particle(Random rng)
      : dx = rng.nextDouble(),
        dy = rng.nextDouble(),
        radius = rng.nextDouble() * 1.6 + 0.4,
        speed = rng.nextDouble() * 0.02 + 0.006,
        phase = rng.nextDouble() * 2 * pi;

  final double dx;
  final double dy;
  final double radius;
  final double speed;
  final double phase;
}

/// A near-static field of tiny floating particles plus a slow-moving glow,
/// used behind the logo on the splash and auth screens.
///
/// Deliberately restrained: low particle count, low opacity, slow drift.
/// This is ambience, not a hero effect.
class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key, this.particleCount = 34});

  final int particleCount;

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  )..repeat();

  late final List<_Particle> _particles = List.generate(
    widget.particleCount,
    (_) => _Particle(Random()),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              t: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles, required this.t});

  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // Soft ambient glow, off-center, drifting extremely slowly.
    final glowCenter = Offset(
      size.width * (0.5 + 0.06 * sin(t * 2 * pi)),
      size.height * (0.38 + 0.04 * cos(t * 2 * pi)),
    );
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.10),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: glowCenter, radius: size.width * 0.6),
      );
    canvas.drawCircle(glowCenter, size.width * 0.6, glowPaint);

    final particlePaint = Paint()..color = AppColors.secondary;
    for (final p in particles) {
      final y = (p.dy + t * p.speed) % 1.0;
      final x = p.dx + 0.01 * sin((t * 2 * pi) + p.phase);
      final opacity = (0.15 + 0.25 * (0.5 + 0.5 * sin((t * 2 * pi) + p.phase)))
          .clamp(0.0, 0.4);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.radius,
        particlePaint..color = AppColors.secondary.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
