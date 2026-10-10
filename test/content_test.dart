import 'dart:convert';
import 'dart:io';
import 'package:aprende_brincando/content/curriculum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support.dart';

void main() {
  test('50 unique lessons, 100 activities per subject across three levels', () {
    final curriculum = fixture();
    expect(curriculum.lessons.length, 50);
    expect(curriculum.lessons.expand((l) => l.exercises).length, 200);
    for (final subject in ['portuguese', 'math']) {
      expect(
        curriculum.lessons
            .where((l) => l.subject == subject)
            .expand((l) => l.exercises)
            .length,
        100,
      );
      for (final level in [1, 2, 3]) {
        expect(
          curriculum.lessons
              .where((l) => l.subject == subject && l.level == level)
              .length,
          level == 1 ? 9 : 8,
        );
      }
    }
    expect(
      curriculum.lessons
          .expand((l) => l.exercises)
          .map((e) => e.answer)
          .toSet()
          .length,
      greaterThan(1),
    );
  });
  test('illustrated quantities and answer keys agree', () {
    for (final lesson in fixture().lessons) {
      for (final exercise in lesson.exercises) {
        final v = exercise.visual;
        if (v == null) continue;
        final answer = exercise.choices[exercise.answer];
        if (['count', 'addition', 'subtraction'].contains(v.kind)) {
          final expected = v.kind == 'count'
              ? v.left
              : v.kind == 'addition'
              ? v.left + v.right
              : v.left - v.right;
          expect(int.parse(answer), expected, reason: exercise.prompt);
        } else if (v.kind == 'compare') {
          final expected = int.tryParse(answer);
          if (expected != null) {
            expect(expected, v.left > v.right ? v.left : v.right);
          } else {
            expect(answer, v.left > v.right ? 'Grupo A' : 'Grupo B');
          }
        } else if (v.kind == 'length') {
          expect(answer, v.left > v.right ? 'Fita A' : 'Fita B');
        }
      }
    }
  });
  test('invalid subtraction illustrations are rejected', () {
    expect(
      () => ActivityVisual.fromJson({
        'kind': 'subtraction',
        'tokens': ['x'],
        'label': 'Teste',
        'left': 3,
        'right': 4,
      }),
      throwsFormatException,
    );
  });
  test('Portuguese content explicitly awaits educator review', () {
    final data =
        jsonDecode(File('assets/content/curriculum.json').readAsStringSync())
            as Map;
    expect(data['language'], 'pt-MZ');
    expect(data['reviewStatus'], contains('awaiting'));
    expect(
      fixture().lessons.first.exercises.first.explanation,
      contains('vogal'),
    );
  });
  test(
    'unsupported content version rejected',
    () => expect(
      () => Curriculum.parse('{"schemaVersion":2}'),
      throwsFormatException,
    ),
  );
  test('duplicate lesson IDs rejected', () {
    final data =
        jsonDecode(File('assets/content/curriculum.json').readAsStringSync())
            as Map<String, dynamic>;
    (data['lessons'] as List).add((data['lessons'] as List).first);
    expect(() => Curriculum.parse(jsonEncode(data)), throwsFormatException);
  });
  test(
    'out of range answer rejected',
    () => expect(
      () => Exercise.fromJson({
        'prompt': '2+1?',
        'choices': ['2', '3'],
        'answer': 2,
        'explanation': '3',
      }),
      throwsFormatException,
    ),
  );
  test(
    'duplicate choices rejected',
    () => expect(
      () => Exercise.fromJson({
        'prompt': '2+1?',
        'choices': ['3', '3'],
        'answer': 0,
        'explanation': '3',
      }),
      throwsFormatException,
    ),
  );
}
