import 'package:aprende_brincando/games/mini_games.dart';
import 'package:aprende_brincando/state/learning_controller.dart';
import 'package:aprende_brincando/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support.dart';

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  late LearningController controller;
  late MemoryStore store;
  setUp(() {
    store = MemoryStore();
    controller = LearningController(curriculum: fixture(), store: store);
  });
  tearDown(() => controller.dispose());
  Future<void> open(WidgetTester tester, MiniGamePack pack) async {
    await controller.addProfile('Lina', 6, 0);
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: PlayScreen(controller: controller, pack: pack),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> collectRound(WidgetTester tester, int count) async {
    for (var i = 0; i < count; i++) {
      await tap(tester, find.byKey(ValueKey('collect-$i')));
    }
    await tap(tester, find.text('Verificar'));
    expect(find.text('Muito bem! Desafio resolvido.'), findsOneWidget);
  }

  test('all six packs use four compatible scored curriculum exercises', () {
    for (final pack in MiniGamePack.all) {
      final lesson = pack.lesson(controller.curriculum);
      expect(lesson.exercises.length, 4);
      for (var i = 0; i < 4; i++) {
        final round = MiniGameRound.fromExercise(
          pack.kind,
          lesson.exercises[i],
          i,
        );
        if (pack.kind == MiniGameKind.words) {
          final pieces = MiniGameRound.syllables[round.target]!;
          expect(
            round.wordMatches(
              pieces.map((p) => round.tiles.indexOf(p)).toList(),
            ),
            true,
          );
          expect(round.wordMatches([0, 0]), false);
        } else if (pack.kind == MiniGameKind.collect) {
          expect(
            round.quantity,
            int.parse(lesson.exercises[i].choices[lesson.exercises[i].answer]),
          );
        } else {
          expect(round.tiles, contains(round.target));
        }
      }
    }
  });
  testWidgets('home launches the game menu', (tester) async {
    await controller.addProfile('Lina', 6, 0);
    await tester.pumpWidget(LearningApp(controller: controller));
    await tap(tester, find.text('Brincar e aprender'));
    expect(find.text('Contar e recolher'), findsOneWidget);
    expect(find.text('Construir palavras'), findsOneWidget);
    expect(find.text('Combinar formas'), findsOneWidget);
  });
  testWidgets('collect adventure completes, saves and survives reload', (
    tester,
  ) async {
    final pack = MiniGamePack.all.first;
    await open(tester, pack);
    for (var i = 0; i < 4; i++) {
      await collectRound(tester, i + 1);
      await tap(
        tester,
        find.text(i == 3 ? 'Concluir aventura' : 'Próximo desafio'),
      );
      if (i != 3) {
        expect(
          tester
              .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
              .controller!
              .offset,
          0,
        );
      }
    }
    expect(find.text('Terminar a aventura'), findsOneWidget);
    expect(controller.progress(pack.lessonId)!.bestCorrect, 4);
    final restored = LearningController(curriculum: fixture(), store: store);
    addTearDown(restored.dispose);
    await restored.load();
    expect(restored.progress(pack.lessonId)!.stars, 3);
    expect(tester.takeException(), isNull);
  });
  testWidgets('wrong collection can be corrected without duplicate objects', (
    tester,
  ) async {
    await open(tester, MiniGamePack.all.first);
    await tap(tester, find.byKey(const ValueKey('collect-0')));
    await tap(tester, find.byKey(const ValueKey('collect-1')));
    await tap(tester, find.text('Verificar'));
    expect(find.textContaining('Vamos contar juntos.'), findsOneWidget);
    await tap(tester, find.byKey(const ValueKey('return-1')));
    expect(find.text('No cesto: 1'), findsOneWidget);
    await tap(tester, find.text('Verificar'));
    expect(find.text('Muito bem! Desafio resolvido.'), findsOneWidget);
    expect(controller.progress(MiniGamePack.all.first.lessonId), isNull);
  });
  testWidgets('word drag drops into slots and tap completes other rounds', (
    tester,
  ) async {
    final pack = MiniGamePack.all[3];
    await open(tester, pack);
    final words = ['bola', 'gato', 'pato', 'casa'];
    for (var index = 0; index < 4; index++) {
      final parts = MiniGameRound.syllables[words[index]]!;
      for (var slot = 0; slot < parts.length; slot++) {
        final source = find.text(parts[slot]);
        if (index == 0) {
          await tester.ensureVisible(source);
          final start = tester.getCenter(source);
          final end = tester.getCenter(find.byKey(ValueKey('slot-$slot')));
          final gesture = await tester.startGesture(start);
          await gesture.moveTo(end);
          await tester.pump();
          await gesture.up();
          await tester.pumpAndSettle();
        } else {
          await tap(tester, source);
        }
      }
      await tap(tester, find.text('Verificar'));
      expect(find.text('Muito bem! Desafio resolvido.'), findsOneWidget);
      await tap(
        tester,
        find.text(index == 3 ? 'Concluir aventura' : 'Próximo desafio'),
      );
    }
    expect(controller.progress(pack.lessonId)!.bestCorrect, 4);
  });
  testWidgets('shape matching supports retry, tap and real drag', (
    tester,
  ) async {
    final pack = MiniGamePack.all.last;
    await open(tester, pack);
    await tap(tester, find.byKey(const ValueKey('shape-triângulo')));
    await tap(tester, find.byKey(const ValueKey('shape-target')));
    expect(find.textContaining('Olha para os lados'), findsOneWidget);
    final targets = ['círculo', 'triângulo', 'quadrado', 'rectângulo'];
    for (var index = 0; index < 4; index++) {
      if (index == 1) {
        final source = find.byKey(ValueKey('shape-${targets[index]}'));
        await tester.ensureVisible(source);
        final gesture = await tester.startGesture(tester.getCenter(source));
        await gesture.moveTo(
          tester.getCenter(find.byKey(const ValueKey('shape-target'))),
        );
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();
      } else {
        await tap(tester, find.byKey(ValueKey('shape-${targets[index]}')));
        await tap(tester, find.byKey(const ValueKey('shape-target')));
      }
      expect(find.text('Muito bem! Desafio resolvido.'), findsOneWidget);
      await tap(
        tester,
        find.text(index == 3 ? 'Concluir aventura' : 'Próximo desafio'),
      );
    }
    expect(controller.progress(pack.lessonId)!.bestCorrect, 3);
  });
  testWidgets('failed game save retries without adding duplicate attempts', (
    tester,
  ) async {
    final pack = MiniGamePack.all.first;
    await open(tester, pack);
    for (var i = 0; i < 4; i++) {
      await collectRound(tester, i + 1);
      if (i == 3) store.failWrites = true;
      await tap(
        tester,
        find.text(i == 3 ? 'Concluir aventura' : 'Próximo desafio'),
      );
    }
    expect(controller.progress(pack.lessonId), isNull);
    store.failWrites = false;
    await tap(tester, find.text('Tentar guardar novamente'));
    expect(controller.progress(pack.lessonId)!.attempts, 1);
  });
  testWidgets('pause leaves unfinished game without a saved result', (
    tester,
  ) async {
    await controller.addProfile('Lina', 6, 0);
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: GamesScreen(controller: controller),
      ),
    );
    await tap(tester, find.text('Contar de 1 a 4'));
    await tap(tester, find.text('Fazer uma pausa'));
    await tap(tester, find.widgetWithText(TextButton, 'Fazer uma pausa').last);
    expect(find.text('Contar e recolher'), findsOneWidget);
    expect(controller.progress(MiniGamePack.all.first.lessonId), isNull);
  });
  for (final size in [const Size(320, 640), const Size(800, 1024)]) {
    testWidgets(
      'all game packs fit $size with enlarged text and reduced motion',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await controller.addProfile('Lina', 6, 0);
        for (final pack in MiniGamePack.all) {
          await tester.pumpWidget(
            MaterialApp(
              key: ValueKey(pack.lessonId),
              theme: appTheme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: PlayScreen(controller: controller, pack: pack),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: pack.lessonId);
        }
      },
    );
  }
}
