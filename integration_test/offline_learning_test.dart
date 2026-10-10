import 'package:aprende_brincando/content/curriculum.dart';
import 'package:aprende_brincando/data/local_store.dart';
import 'package:aprende_brincando/state/learning_controller.dart';
import 'package:aprende_brincando/ui/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('bundled lesson and real local persistence survive reload', (
    tester,
  ) async {
    final curriculum = await Curriculum.load();
    final preferences = await SharedPreferences.getInstance();
    final original = preferences.getString(PreferencesStore.key);
    addTearDown(() async {
      if (original == null) {
        await preferences.remove(PreferencesStore.key);
      } else {
        await preferences.setString(PreferencesStore.key, original);
      }
    });
    await preferences.remove(PreferencesStore.key);
    final store = PreferencesStore(preferences);
    final controller = LearningController(curriculum: curriculum, store: store);
    addTearDown(controller.dispose);
    await controller.load();
    await controller.addProfile('Teste', 6, 0);
    await tester.pumpWidget(LearningApp(controller: controller));
    await tester.pumpAndSettle();
    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder.first);
      await tester.tap(finder.first);
      await tester.pumpAndSettle();
    }

    await tap(find.text('Português'));
    await tap(find.text('Explorar'));
    await tap(find.text('Começar os desafios'));
    final lesson = curriculum.lessons.first;
    for (var i = 0; i < lesson.exercises.length; i++) {
      final exercise = lesson.exercises[i];
      await tap(find.text(exercise.choices[exercise.answer]));
      await tap(
        find.text(
          i + 1 == lesson.exercises.length
              ? 'Ver resultado'
              : 'Próximo desafio',
        ),
      );
    }
    expect(find.text('4 de 4 respostas certas'), findsOneWidget);
    final reloaded = LearningController(curriculum: curriculum, store: store);
    addTearDown(reloaded.dispose);
    await reloaded.load();
    expect(reloaded.active!.name, 'Teste');
    expect(reloaded.stars, 3);
  });
}
