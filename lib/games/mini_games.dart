import 'dart:math';
import '../content/curriculum.dart';

enum MiniGameKind { collect, words, shapes }

class MiniGamePack {
  const MiniGamePack(this.kind, this.lessonId, this.title);
  final MiniGameKind kind;
  final String lessonId, title;
  static const all = [
    MiniGamePack(
      MiniGameKind.collect,
      'mt-1-visual-contar1',
      'Contar de 1 a 4',
    ),
    MiniGamePack(
      MiniGameKind.collect,
      'mt-1-visual-contar2',
      'Contar de 5 a 8',
    ),
    MiniGamePack(MiniGameKind.collect, 'mt-1-visual-contar3', 'Contar até 10'),
    MiniGamePack(
      MiniGameKind.words,
      'pt-1-visual-juntar',
      'As primeiras palavras',
    ),
    MiniGamePack(
      MiniGameKind.words,
      'pt-1-visual-juntar2',
      'Mais palavras para juntar',
    ),
    MiniGamePack(
      MiniGameKind.shapes,
      'mt-1-visual-formas2',
      'As quatro formas',
    ),
  ];
  Lesson lesson(Curriculum curriculum) =>
      curriculum.lessons.firstWhere((l) => l.id == lessonId);
}

class MiniGameRound {
  MiniGameRound({
    required this.target,
    required this.token,
    required this.tiles,
    this.quantity = 0,
  });
  final String target, token;
  final List<String> tiles;
  final int quantity;
  static const syllables = {
    'bola': ['BO', 'LA'],
    'gato': ['GA', 'TO'],
    'pato': ['PA', 'TO'],
    'casa': ['CA', 'SA'],
    'mala': ['MA', 'LA'],
    'livro': ['LI', 'VRO'],
    'copo': ['CO', 'PO'],
    'uva': ['U', 'VA'],
  };
  static const shapeNames = ['círculo', 'triângulo', 'quadrado', 'rectângulo'];
  factory MiniGameRound.fromExercise(
    MiniGameKind kind,
    Exercise exercise,
    int seed,
  ) {
    final answer = exercise.choices[exercise.answer].toLowerCase();
    final visual = exercise.visual!;
    if (kind == MiniGameKind.collect) {
      final count = int.parse(answer);
      if (count != visual.left || count < 1 || count > 10) {
        throw const FormatException('Quantidade do jogo inválida');
      }
      return MiniGameRound(
        target: answer,
        token: visual.tokens.first,
        quantity: count,
        tiles: const [],
      );
    }
    final tiles = kind == MiniGameKind.words
        ? [...syllables[answer]!, 'ME']
        : [...shapeNames];
    tiles.shuffle(Random(seed));
    return MiniGameRound(
      target: answer,
      token: visual.tokens.first,
      tiles: List.unmodifiable(tiles),
    );
  }
  int get slots => syllables[target]?.length ?? 0;
  bool wordMatches(List<int?> chosen) =>
      chosen.length == slots &&
      chosen.every((i) => i != null) &&
      chosen.toSet().length == chosen.length &&
      chosen.map((i) => tiles[i!]).join().toLowerCase() == target;
}
