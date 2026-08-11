import 'package:flutter/material.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class WallpaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.wallpaper.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final fillPaint = Paint()
      ..color = AppColors.wallpaper.withValues(alpha: 0.35);

    final random = _SeededRandom(7);
    for (var i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = 6 + random.nextDouble() * 22;
      switch (i % 4) {
        case 0:
          canvas.drawCircle(Offset(x, y), r, paint);
          break;
        case 1:
          canvas.drawCircle(Offset(x, y), r, fillPaint);
          break;
        case 2:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(x, y), width: r * 1.6, height: r),
              const Radius.circular(3),
            ),
            paint,
          );
          break;
        case 3:
          canvas.drawArc(
            Rect.fromCenter(
                center: Offset(x, y), width: r * 2, height: r * 2),
            0,
            1.4,
            false,
            paint,
          );
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SeededRandom {
  _SeededRandom(this.seed);
  int seed;

  double nextDouble() {
    seed = (seed * 16807) % 2147483647;
    return seed / 2147483647;
  }
}
