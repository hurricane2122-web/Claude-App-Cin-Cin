import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/services/proximity_service.dart';

class RadarAnimation extends StatelessWidget {
  final AnimationController pulseController;
  final AnimationController toastController;
  final ProximityState state;
  final int nearbyCount;
  final double closestDistance;

  const RadarAnimation({
    super.key,
    required this.pulseController,
    required this.toastController,
    required this.state,
    required this.nearbyCount,
    required this.closestDistance,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: AnimatedBuilder(
        animation: Listenable.merge([pulseController, toastController]),
        builder: (context, _) {
          return CustomPaint(
            painter: RadarPainter(
              pulse: pulseController.value,
              toastProgress: toastController.value,
              state: state,
              nearbyCount: nearbyCount,
              closestDistance: closestDistance,
            ),
          );
        },
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double pulse;
  final double toastProgress;
  final ProximityState state;
  final int nearbyCount;
  final double closestDistance;

  const RadarPainter({
    required this.pulse,
    required this.toastProgress,
    required this.state,
    required this.nearbyCount,
    required this.closestDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final isToasting = state == ProximityState.toasting;
    final isScanning = state == ProximityState.scanning || state == ProximityState.near;

    const gold = Color(0xFFD4AF37);
    const amber = Color(0xFFFFBF00);

    for (int i = 1; i <= 4; i++) {
      final r = maxRadius * i / 4;
      final paint = Paint()
        ..color = gold.withOpacity(0.08 + (i == 1 ? 0.04 : 0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawCircle(center, r, paint);
    }

    if (isScanning || isToasting) {
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * pi + pulse * 2 * pi;
        final paint = Paint()
          ..color = gold.withOpacity(0.06)
          ..strokeWidth = 0.5;
        canvas.drawLine(
          center,
          Offset(center.dx + cos(angle) * maxRadius, center.dy + sin(angle) * maxRadius),
          paint,
        );
      }
    }

    if (isScanning) {
      for (int i = 0; i < 3; i++) {
        final wavePhase = (pulse + i / 3) % 1.0;
        final waveRadius = maxRadius * wavePhase;
        final wavePaint = Paint()
          ..color = gold.withOpacity(0.3 * (1 - wavePhase))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(center, waveRadius, wavePaint);
      }
    }

    if (nearbyCount > 0 && !isToasting) {
      final nearRadius = (closestDistance.clamp(0.1, 3.0) / 3.0) * maxRadius;
      final nearPaint = Paint()
        ..color = amber.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, nearRadius.clamp(20, maxRadius * 0.8), nearPaint);
    }

    if (isToasting) {
      final burstPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (int i = 0; i < 3; i++) {
        final progress = (toastProgress - i * 0.15).clamp(0.0, 1.0);
        if (progress > 0) {
          burstPaint.color = gold.withOpacity(0.6 * (1 - progress));
          canvas.drawCircle(center, maxRadius * progress, burstPaint);
        }
      }
    }

    final centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          isToasting
              ? gold.withOpacity(0.9)
              : gold.withOpacity(0.3 + 0.2 * sin(pulse * 2 * pi)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 28));
    canvas.drawCircle(center, 28, centerGlow);

    final centerRing = Paint()
      ..color = gold.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 28, centerRing);

    final dotPaint = Paint()..color = gold;
    canvas.drawCircle(center, 3, dotPaint);

    if (nearbyCount > 0) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '+$nearbyCount',
          style: const TextStyle(
            color: amber,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy + 36),
      );
    }
  }

  @override
  bool shouldRepaint(RadarPainter old) =>
      old.pulse != pulse ||
      old.toastProgress != toastProgress ||
      old.state != state ||
      old.nearbyCount != nearbyCount;
}
