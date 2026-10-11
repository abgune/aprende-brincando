part of '../app.dart';

class PiuGuide extends StatelessWidget {
  const PiuGuide({super.key, this.size = 76, this.happy = false});
  final double size;
  final bool happy;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Piu, o passarinho amigo',
    image: true,
    child: TweenAnimationBuilder<double>(
      key: ValueKey(happy),
      tween: Tween(begin: happy ? .85 : 1, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 450),
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _PiuPainter(happy)),
      ),
    ),
  );
}

class _PiuPainter extends CustomPainter {
  _PiuPainter(this.happy);
  final bool happy;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final paint = Paint()..color = const Color(0xFF168D80);
    canvas.drawOval(const Rect.fromLTWH(12, 15, 76, 77), paint);
    paint.color = const Color(0xFF8BE2C6);
    canvas.drawOval(const Rect.fromLTWH(18, 49, 64, 39), paint);
    paint.color = green;
    canvas.drawOval(const Rect.fromLTWH(1, 49, 24, 29), paint);
    canvas.drawOval(const Rect.fromLTWH(75, 49, 24, 29), paint);
    paint.color = Colors.white;
    canvas.drawCircle(const Offset(33, 38), 11, paint);
    canvas.drawCircle(const Offset(67, 38), 11, paint);
    paint.color = ink;
    canvas.drawCircle(const Offset(35, 39), 5, paint);
    canvas.drawCircle(const Offset(65, 39), 5, paint);
    paint.color = const Color(0xFFFFC956);
    canvas.drawPath(
      Path()
        ..moveTo(40, 51)
        ..lineTo(60, 51)
        ..lineTo(50, happy ? 69 : 62)
        ..close(),
      paint,
    );
    canvas.drawOval(const Rect.fromLTWH(26, 88, 19, 8), paint);
    canvas.drawOval(const Rect.fromLTWH(55, 88, 19, 8), paint);
    paint.color = const Color(0xFFF5A591);
    canvas.drawCircle(const Offset(24, 54), 6, paint);
    canvas.drawCircle(const Offset(76, 54), 6, paint);
    paint.color = green;
    canvas.drawOval(const Rect.fromLTWH(46, 0, 12, 22), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PiuPainter oldDelegate) => happy != oldDelegate.happy;
}

class ShapeOutline extends StatelessWidget {
  const ShapeOutline({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 90,
    height: 90,
    child: CustomPaint(painter: _OutlinePainter(name)),
  );
}

class _OutlinePainter extends CustomPainter {
  _OutlinePainter(this.name);
  final String name;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    if (name == 'círculo') {
      canvas.drawCircle(const Offset(45, 45), 34, paint);
    } else if (name == 'triângulo') {
      canvas.drawPath(
        Path()
          ..moveTo(45, 10)
          ..lineTo(80, 78)
          ..lineTo(10, 78)
          ..close(),
        paint,
      );
    } else {
      canvas.drawRect(
        name == 'rectângulo'
            ? const Rect.fromLTWH(8, 25, 74, 40)
            : const Rect.fromLTWH(11, 11, 68, 68),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OutlinePainter oldDelegate) => name != oldDelegate.name;
}

String gameShape(String name) => switch (name) {
  'círculo' => 'circle',
  'triângulo' => 'triangle',
  'quadrado' => 'square',
  _ => 'rectangle',
};
