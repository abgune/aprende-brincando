import 'dart:convert';
import 'dart:io';
import 'package:aprende_brincando/content/curriculum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support.dart';

void main() {
  test(
    '12 unique lessons, 48 exercises, two lessons per subject and level',
    () {
      final curriculum = fixture();
      expect(curriculum.lessons.length, 12);
      expect(curriculum.lessons.expand((l) => l.exercises).length, 48);
      for (final subject in ['portuguese', 'math']) {
        for (final level in [1, 2, 3]) {
          expect(
            curriculum.lessons
                .where((l) => l.subject == subject && l.level == level)
                .length,
            2,
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
    },
  );
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
