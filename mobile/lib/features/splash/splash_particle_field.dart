import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'splash_palette.dart';

class SplashParticle {
  SplashParticle({
    required this.origin,
    required this.size,
    required this.color,
    required this.phase,
    required this.kind,
  });

  final Offset origin;
  final double size;
  final Color color;
  final double phase;
  final int kind; // 0 dot, 1 stroke, 2 shard

  Offset positionAt(double t, Size canvas, double gather) {
    final center = Offset(canvas.width / 2, canvas.height * 0.38);
    final drift = Offset(
      math.sin((t * 2 * math.pi) + phase) * 8,
      math.cos((t * 1.6 * math.pi) + phase * 1.3) * 6,
    );
    final scattered = origin + drift;
    final target = center + Offset(
      math.cos(phase * 5) * (18 + size * 2),
      math.sin(phase * 4) * (14 + size * 2),
    );
    final eased = Curves.easeInOutCubicEmphasized.transform(gather.clamp(0.0, 1.0));
    return Offset.lerp(scattered, target, eased)!;
  }
}

List<SplashParticle> generateParticles(Size size, math.Random random) {
  final count = 110;
  return List.generate(count, (i) {
    final goldish = i.isEven;
    return SplashParticle(
      origin: Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ),
      size: 1.2 + random.nextDouble() * 3.2,
      color: goldish
          ? SplashPalette.gold.withValues(alpha: 0.35 + random.nextDouble() * 0.45)
          : SplashPalette.black.withValues(alpha: 0.12 + random.nextDouble() * 0.28),
      phase: random.nextDouble() * math.pi * 2,
      kind: i % 3,
    );
  });
}

class SplashParticlePainter extends CustomPainter {
  SplashParticlePainter({
    required this.particles,
    required this.time,
    required this.gather,
  });

  final List<SplashParticle> particles;
  final double time;
  final double gather;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final pos = p.positionAt(time, size, gather);
      final opacity = (1.0 - gather * 0.92).clamp(0.0, 1.0);
      if (opacity <= 0.02) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.color.a * opacity)
        ..strokeCap = StrokeCap.round;

      if (p.kind == 1) {
        paint.strokeWidth = p.size * 0.6;
        paint.style = PaintingStyle.stroke;
        canvas.drawArc(
          Rect.fromCircle(center: pos, radius: p.size * 2.2),
          p.phase,
          0.8,
          false,
          paint,
        );
      } else if (p.kind == 2) {
        paint.style = PaintingStyle.fill;
        final path = Path()
          ..moveTo(pos.dx, pos.dy - p.size)
          ..lineTo(pos.dx + p.size, pos.dy)
          ..lineTo(pos.dx, pos.dy + p.size * 0.6)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(pos, p.size * 0.55, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SplashParticlePainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.gather != gather;
  }
}
