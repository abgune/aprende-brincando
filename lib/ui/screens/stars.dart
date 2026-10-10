part of '../app.dart';

class Stars extends StatelessWidget {
  const Stars({super.key, required this.count, this.size = 24});
  final int count;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$count de 3 estrelas',
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Icon(
              i < count ? Icons.star_rounded : Icons.star_outline_rounded,
              color: i < count
                  ? const Color(0xFFE4A530)
                  : const Color(0xFF8495A3),
              size: size,
            ),
        ],
      ),
    ),
  );
}
