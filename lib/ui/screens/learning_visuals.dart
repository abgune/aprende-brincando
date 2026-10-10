part of '../app.dart';

/// Bundled storybook artwork is decorative; teaching quantities are drawn below.
class ScenePicture extends StatelessWidget {
  const ScenePicture({super.key, required this.subject, this.height = 140});
  final String subject;
  final double height;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: Image.asset(
      'assets/images/${subject == 'math' ? 'math' : 'reading'}.png',
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      cacheWidth: 1000,
    ),
  );
}

class ShapePicture extends StatelessWidget {
  const ShapePicture({super.key, required this.shape});
  final String shape;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 42,
    height: 42,
    child: CustomPaint(painter: _ShapePainter(shape)),
  );
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.shape);
  final String shape;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = shape == 'circle'
          ? green
          : shape == 'square'
          ? purple
          : const Color(0xFFF09B40);
    final rect = Rect.fromLTWH(4, 4, size.width - 8, size.height - 8);
    if (shape == 'grapes') {
      p.color = purple;
      for (final xy in [
        (12.0, 14.0),
        (25.0, 14.0),
        (9.0, 24.0),
        (21.0, 24.0),
        (32.0, 24.0),
        (15.0, 33.0),
        (27.0, 33.0),
        (21.0, 40.0),
      ]) {
        canvas.drawCircle(Offset(xy.$1, xy.$2), 6, p);
      }
      p.color = green;
      canvas.drawOval(const Rect.fromLTWH(20, 1, 16, 8), p);
    } else if (shape == 'circle') {
      canvas.drawOval(rect, p);
    } else if (shape == 'square') {
      canvas.drawRect(rect, p);
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(size.width / 2, 4)
          ..lineTo(size.width - 4, size.height - 4)
          ..lineTo(4, size.height - 4)
          ..close(),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) => oldDelegate.shape != shape;
}

String? shapeFor(String label) => switch (label.toLowerCase()) {
  'círculo' => 'circle',
  'quadrado' => 'square',
  'triângulo' => 'triangle',
  _ => null,
};
IconData? pictureFor(String label) => switch (label.toLowerCase()) {
  'livro' => Icons.menu_book_rounded,
  'copo' => Icons.local_drink_rounded,
  'água' => Icons.water_drop_rounded,
  'mesa' => Icons.table_restaurant_rounded,
  'bola' => Icons.sports_soccer_rounded,
  'escola' => Icons.school_rounded,
  'cadeira' => Icons.chair_rounded,
  _ => null,
};

class ChoicePicture extends StatelessWidget {
  const ChoicePicture({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final shape = shapeFor(label), icon = pictureFor(label);
    if (shape == null && icon == null) return const SizedBox.shrink();
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: shape != null
            ? ShapePicture(shape: shape)
            : Icon(icon, color: green, size: 36),
      ),
    );
  }
}

class LessonBadge extends StatelessWidget {
  const LessonBadge({super.key, required this.lesson});
  final Lesson lesson;
  @override
  Widget build(BuildContext context) => lesson.id.endsWith('formas')
      ? const Wrap(
          spacing: 12,
          children: [
            ShapePicture(shape: 'circle'),
            ShapePicture(shape: 'triangle'),
            ShapePicture(shape: 'square'),
          ],
        )
      : lesson.id.endsWith('vogais')
      ? const Text(
          'A E I O U',
          style: TextStyle(
            color: green,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        )
      : Row(
          children: [
            Icon(
              subjectIcon(lesson.subject),
              size: 42,
              color: subjectColor(lesson.subject),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(lesson.objective)),
          ],
        );
}

/// Each item is an individual widget, so quantities stay exact at every size.
class CountingPicture extends StatelessWidget {
  const CountingPicture({
    super.key,
    required this.count,
    this.removed = 0,
    this.icon = Icons.circle,
  });
  final int count, removed;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$count objectos, $removed riscados',
    child: ExcludeSemantics(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < count; i++)
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  key: ValueKey('count-object-$i'),
                  size: 32,
                  color: i < count - removed
                      ? const Color(0xFFF0A435)
                      : const Color(0xFFC6C6C6),
                ),
                if (i >= count - removed)
                  const Icon(Icons.close_rounded, color: ink, size: 32),
              ],
            ),
        ],
      ),
    ),
  );
}

class ExercisePicture extends StatelessWidget {
  const ExercisePicture({super.key, required this.lesson, required this.index});
  final Lesson lesson;
  final int index;
  @override
  Widget build(BuildContext context) {
    Widget picture;
    final quantities = <String, List<(int, int, String)>>{
      'mt-2-somar': [(2, 1, '+'), (3, 2, '+'), (4, 4, '+'), (6, 4, '+')],
      'mt-2-tirar': [(5, 2, '−'), (8, 3, '−'), (0, 0, ''), (7, 1, '−')],
      'mt-3-problemas': [(7, 5, '+'), (15, 4, '−'), (8, 6, '+'), (20, 5, '−')],
    };
    final q = quantities[lesson.id]?[index];
    if (q != null && q.$1 > 0) {
      picture = q.$3 == '−'
          ? CountingPicture(count: q.$1, removed: q.$2)
          : Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 14,
              runSpacing: 12,
              children: [
                CountingPicture(count: q.$1),
                const Text('+', style: TextStyle(fontSize: 32)),
                CountingPicture(count: q.$2),
              ],
            );
    } else if (lesson.id == 'mt-1-contar' && (index == 0 || index == 3)) {
      picture = CountingPicture(
        count: index == 0 ? 3 : 4,
        icon: index == 0 ? Icons.circle : Icons.edit_rounded,
      );
    } else if (lesson.id == 'mt-1-formas' && index == 1) {
      picture = const ShapePicture(shape: 'triangle');
    } else if (lesson.id == 'mt-3-padroes' && index == 1) {
      picture = const Wrap(
        spacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ShapePicture(shape: 'circle'),
          ShapePicture(shape: 'square'),
          ShapePicture(shape: 'circle'),
          Text('?', style: TextStyle(fontSize: 32)),
        ],
      );
    } else if (lesson.id == 'pt-1-vogais' && (index == 1 || index == 2)) {
      picture = index == 1
          ? const Icon(Icons.egg_rounded, size: 70, color: Color(0xFFF0A435))
          : const Center(
              child: SizedBox(
                width: 70,
                height: 70,
                child: FittedBox(child: ShapePicture(shape: 'grapes')),
              ),
            );
    } else {
      picture = ScenePicture(subject: lesson.subject, height: 110);
    }
    return Surface(
      color: const Color(0xFFFFF0CC),
      padding: const EdgeInsets.all(16),
      child: picture,
    );
  }
}
