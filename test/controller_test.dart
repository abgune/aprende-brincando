import 'dart:io';
import 'package:aprende_brincando/content/curriculum.dart';
import 'dart:convert';
import 'package:aprende_brincando/state/learning_controller.dart';
import 'package:aprende_brincando/data/local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support.dart';

void main() {
  late MemoryStore store;
  late LearningController controller;
  setUp(() {
    store = MemoryStore();
    controller = LearningController(curriculum: fixture(), store: store);
  });
  tearDown(() => controller.dispose());
  test('Build 01 profiles and scores survive expanded curriculum', () async {
    final legacy = LearningController(
      curriculum: Curriculum.parse(
        File('test/fixtures/build01_curriculum.json').readAsStringSync(),
      ),
      store: store,
    );
    addTearDown(legacy.dispose);
    await legacy.addProfile('Lina', 6, 0);
    await legacy.recordResult(legacy.curriculum.lessons.first, 4);
    await controller.load();
    expect(controller.active!.name, 'Lina');
    expect(controller.stars, 3);
    expect(controller.progress('pt-1-vogais')!.bestCorrect, 4);
    expect(controller.curriculum.lessons.length, 50);
  });
  test('new install has no profiles', () async {
    await controller.load();
    expect(controller.profiles, isEmpty);
    expect(controller.active, isNull);
  });
  test('profile and progress survive reload', () async {
    await controller.addProfile(' Lina ', 6, 1);
    await controller.recordResult(controller.curriculum.lessons.first, 3);
    final restarted = LearningController(curriculum: fixture(), store: store);
    addTearDown(restarted.dispose);
    await restarted.load();
    expect(restarted.active!.name, 'Lina');
    expect(restarted.stars, 2);
    expect(restarted.progress('pt-1-vogais')!.attempts, 1);
  });
  test('children have isolated progress', () async {
    await controller.addProfile('Lina', 6, 0);
    final lina = controller.active!.id;
    await controller.recordResult(controller.curriculum.lessons.first, 4);
    await controller.addProfile('Rui', 8, 2);
    expect(controller.stars, 0);
    await controller.selectProfile(lina);
    expect(controller.stars, 3);
  });
  test(
    'replay preserves best score, adds attempt, does not duplicate stars',
    () async {
      await controller.addProfile('Lina', 6, 0);
      final lesson = controller.curriculum.lessons.first;
      await controller.recordResult(lesson, 4);
      await controller.recordResult(lesson, 1);
      expect(controller.progress(lesson.id)!.bestCorrect, 4);
      expect(controller.progress(lesson.id)!.attempts, 2);
      expect(controller.stars, 3);
      expect(controller.progressFor(controller.active!.id).length, 1);
    },
  );
  test('zero correct finishes with zero stars', () async {
    await controller.addProfile('Lina', 6, 0);
    await controller.recordResult(controller.curriculum.lessons.first, 0);
    expect(controller.stars, 0);
    expect(controller.progressFor(controller.active!.id).length, 1);
  });
  test(
    'star thresholds',
    () => expect(
      [
        for (var correct = 0; correct <= 4; correct++)
          LessonProgress.starsFor(correct, 4),
      ],
      [0, 1, 2, 2, 3],
    ),
  );
  test('invalid profile fields rejected', () async {
    for (final args in [
      ('', 6, 0),
      ('Lina', 4, 0),
      ('Lina', 9, 0),
      ('Lina', 6, 5),
    ]) {
      await expectLater(
        controller.addProfile(args.$1, args.$2, args.$3),
        throwsArgumentError,
      );
    }
    expect(store.value, isNull);
  });
  test('failed profile write does not claim success', () async {
    store.failWrites = true;
    await expectLater(controller.addProfile('Lina', 6, 0), throwsA(anything));
    expect(controller.profiles, isEmpty);
    expect(controller.saving, false);
  });
  test('failed result save can retry without duplicate attempts', () async {
    await controller.addProfile('Lina', 6, 0);
    store.failWrites = true;
    await expectLater(
      controller.recordResult(controller.curriculum.lessons.first, 4),
      throwsA(anything),
    );
    expect(controller.stars, 0);
    store.failWrites = false;
    await controller.recordResult(controller.curriculum.lessons.first, 4);
    expect(controller.progress('pt-1-vogais')!.attempts, 1);
  });
  test('invalid score and unknown child rejected', () async {
    await expectLater(
      controller.recordResult(controller.curriculum.lessons.first, 1),
      throwsArgumentError,
    );
    await controller.addProfile('Lina', 6, 0);
    await expectLater(
      controller.recordResult(controller.curriculum.lessons.first, 5),
      throwsArgumentError,
    );
    await expectLater(controller.selectProfile('unknown'), throwsArgumentError);
  });
  test('corrupt storage is preserved', () async {
    store.value = '{broken';
    await expectLater(controller.load(), throwsFormatException);
    expect(store.value, '{broken');
    expect(controller.profiles, isEmpty);
  });
  test('unsupported local schema rejected', () async {
    store.value = jsonEncode({'schemaVersion': 2});
    await expectLater(controller.load(), throwsFormatException);
  });
  test('preferences adapter persists serialized state', () async {
    SharedPreferences.setMockInitialValues({});
    final local = PreferencesStore(await SharedPreferences.getInstance());
    await local.write('test state');
    expect(await local.read(), 'test state');
  });
}
