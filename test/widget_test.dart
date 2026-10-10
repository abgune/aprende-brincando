import 'package:aprende_brincando/state/learning_controller.dart';
import 'package:aprende_brincando/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  late LearningController controller;
  setUp(
    () => controller = LearningController(
      curriculum: fixture(),
      store: MemoryStore(),
    ),
  );
  tearDown(() => controller.dispose());
  testWidgets('first launch creates child through UI', (tester) async {
    await tester.pumpWidget(LearningApp(controller: controller));
    await tapVisible(tester, find.text('Criar o meu perfil'));
    await tester.enterText(find.byType(TextFormField), 'Lina');
    await tapVisible(tester, find.text('Vamos aprender'));
    expect(find.text('Olá, Lina!'), findsOneWidget);
    expect(controller.active!.age, 6);
  });
  testWidgets('full quiz gives one feedback per answer and persists stars', (
    tester,
  ) async {
    await controller.addProfile('Lina', 6, 0);
    await tester.pumpWidget(LearningApp(controller: controller));
    await tapVisible(tester, find.text('Português'));
    await tapVisible(tester, find.text('Explorar'));
    await tapVisible(tester, find.text('Começar os desafios'));
    final lesson = controller.curriculum.lessons.first;
    for (var i = 0; i < lesson.exercises.length; i++) {
      final question = lesson.exercises[i];
      await tapVisible(tester, find.text(question.choices[question.answer]));
      expect(find.text('Muito bem!'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(
                OutlinedButton,
                question.choices[question.answer],
              ),
            )
            .onPressed,
        isNull,
      );
      await tapVisible(
        tester,
        find.text(
          i + 1 == lesson.exercises.length
              ? 'Ver resultado'
              : 'Próximo desafio',
        ),
      );
    }
    expect(find.text('4 de 4 respostas certas'), findsOneWidget);
    expect(controller.stars, 3);
    await tapVisible(tester, find.text('Voltar às lições'));
    expect(find.text('Praticar outra vez'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('incorrect answer teaches without giving credit', (tester) async {
    await controller.addProfile('Lina', 6, 0);
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: LessonScreen(
          controller: controller,
          lesson: controller.curriculum.lessons.first,
        ),
      ),
    );
    await tapVisible(tester, find.text('Começar os desafios'));
    await tapVisible(tester, find.text('B'));
    expect(find.text('Vamos aprender juntos.'), findsOneWidget);
    expect(controller.stars, 0);
  });
  testWidgets('unfinished exit needs confirmation and saves no result', (
    tester,
  ) async {
    await controller.addProfile('Lina', 6, 0);
    await tester.pumpWidget(LearningApp(controller: controller));
    await tapVisible(tester, find.text('Português'));
    await tapVisible(tester, find.text('Explorar'));
    await tapVisible(tester, find.text('Começar os desafios'));
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Sair da lição?'), findsOneWidget);
    await tapVisible(tester, find.text('Sair'));
    expect(controller.progress('pt-1-vogais'), isNull);
    expect(find.text('Explorar'), findsNWidgets(2));
  });
  testWidgets('parent gate rejects wrong answer and accepts displayed sum', (
    tester,
  ) async {
    await tester.pumpWidget(LearningApp(controller: controller));
    await tester.tap(find.byTooltip('Área dos pais'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0');
    await tapVisible(tester, find.text('Entrar'));
    expect(find.text('Tente novamente.'), findsOneWidget);
    final question = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((t) => t.contains(' + ') && t.endsWith('= ?'));
    final numbers = RegExp(
      r'\d+',
    ).allMatches(question).map((m) => int.parse(m.group(0)!)).toList();
    await tester.enterText(
      find.byType(TextField),
      '${numbers[0] + numbers[1]}',
    );
    await tapVisible(tester, find.text('Entrar'));
    expect(find.text('Acompanhar a aprendizagem'), findsOneWidget);
  });
  for (final size in [const Size(320, 640), const Size(800, 1024)]) {
    testWidgets('home and profiles fit $size with larger text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await controller.addProfile('Uma alcunha comprida', 7, 2);
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: HomeScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tapVisible(tester, find.byIcon(Icons.swap_horiz_rounded));
      expect(tester.takeException(), isNull);
    });
  }
}
