import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _flash = false;
  bool _flashOn = false;

  Future<void> _capture() async {
    setState(() => _flash = true);
    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    setState(() => _flash = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo captured (demo)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _topBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setState(() => _flashOn = !_flashOn),
              icon: Icon(
                _flashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
            ),
            const Text(
              'Camera',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.cameraswitch, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          GestureDetector(
            onTap: _capture,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
            ),
          ),
          const Icon(Icons.cameraswitch, color: Colors.transparent),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),
          _topBar(),
          _bottomBar(),
          if (_flash)
            Positioned.fill(
              child: Container(color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final dx = size.width * i / 3;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
    for (var i = 1; i < 3; i++) {
      final dy = size.height * i / 3;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withValues(alpha: 0.15)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
