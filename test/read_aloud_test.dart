import 'dart:async';
import 'package:aprende_brincando/audio/read_aloud.dart';
import 'package:aprende_brincando/state/learning_controller.dart';
import 'package:aprende_brincando/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support.dart';

class FakeSpeech extends SpeechBackend {
  bool available = true, fail = false;
  Completer<bool>? pending;
  final spoken = <String>[];
  int stops = 0;
  @override
  Future<bool> prepare() async => pending == null ? available : pending!.future;
  @override
  Future<void> speak(String text, String id) async {
    if (fail) throw StateError('engine error');
    spoken.add(text);
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  void dispose() {}
}

void main() {
  test('missing offline voice shows help without speaking', () async {
    final backend = FakeSpeech()..available = false;
    final reader = ReadAloudController(backend: backend);
    addTearDown(reader.dispose);
    await reader.toggle('a', 'Pergunta');
    expect(reader.error, contains('voz portuguesa offline'));
    expect(backend.spoken, isEmpty);
    expect(reader.activeId, isNull);
  });
  test('same button stops; completion resets playback', () async {
    final backend = FakeSpeech();
    final reader = ReadAloudController(backend: backend);
    addTearDown(reader.dispose);
    await reader.toggle('a', 'Texto');
    expect(reader.activeId, isNotNull);
    await reader.toggle('a', 'Texto');
    expect(reader.activeId, isNull);
    expect(backend.spoken.length, 1);
    await reader.toggle('a', 'Texto');
    backend.onFinished!(reader.activeId!, false);
    expect(reader.activeId, isNull);
  });
  test('old completion cannot stop a newer passage', () async {
    final backend = FakeSpeech();
    final reader = ReadAloudController(backend: backend);
    addTearDown(reader.dispose);
    await reader.toggle('a', 'Texto A');
    final oldId = reader.activeId!;
    await reader.toggle('b', 'Texto B');
    backend.onFinished!(oldId, false);
    expect(reader.activeKey, 'b');
    expect(reader.activeId, isNotNull);
  });
  test('leaving while voice prepares prevents late playback', () async {
    final backend = FakeSpeech()..pending = Completer<bool>();
    final reader = ReadAloudController(backend: backend);
    addTearDown(reader.dispose);
    final playback = reader.toggle('a', 'Texto');
    await Future<void>.delayed(Duration.zero);
    await reader.stop();
    backend.pending!.complete(true);
    await playback;
    expect(backend.spoken, isEmpty);
    expect(reader.preparing, false);
  });
  test('speech failure can be retried', () async {
    final backend = FakeSpeech()..fail = true;
    final reader = ReadAloudController(backend: backend);
    addTearDown(reader.dispose);
    await reader.toggle('a', 'Texto');
    expect(reader.error, isNotNull);
    backend.fail = false;
    await reader.toggle('a', 'Texto');
    expect(reader.error, isNull);
    expect(reader.activeId, isNotNull);
  });
  test('math symbols receive spoken Portuguese equivalents', () {
    expect(
      ReadAloudController.spokenText('3 + 2 = 5; 4 − 1; _va'),
      contains('mais'),
    );
    expect(ReadAloudController.spokenText('4 − 1'), contains('menos'));
    expect(ReadAloudController.spokenText('_va'), contains('espaço'));
  });
  testWidgets('lesson listen button reads and stops the introduction', (
    tester,
  ) async {
    final controller = LearningController(
      curriculum: fixture(),
      store: MemoryStore(),
    );
    addTearDown(controller.dispose);
    final speech = FakeSpeech();
    final lesson = controller.curriculum.lessons.first;
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: LessonScreen(
          controller: controller,
          lesson: lesson,
          speechBackend: speech,
        ),
      ),
    );
    await tester.ensureVisible(find.text('Ouvir'));
    await tester.tap(find.text('Ouvir'));
    await tester.pumpAndSettle();
    expect(speech.spoken.single, lesson.introduction);
    expect(find.text('Parar'), findsOneWidget);
    await tester.tap(find.text('Parar'));
    await tester.pumpAndSettle();
    expect(find.text('Ouvir'), findsOneWidget);
    await tester.tap(find.text('Ouvir'));
    await tester.pumpAndSettle();
    final previousStops = speech.stops;
    await tester.ensureVisible(find.text('Começar os desafios'));
    await tester.tap(find.text('Começar os desafios'));
    await tester.pumpAndSettle();
    expect(speech.stops, greaterThan(previousStops));
    expect(find.text('Parar'), findsNothing);
  });
}
