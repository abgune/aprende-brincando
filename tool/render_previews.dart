// Run explicitly with: flutter test tool/render_previews.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:aprende_brincando/state/learning_controller.dart';
import 'package:aprende_brincando/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test/support.dart';

void main() {
  testWidgets('render phone previews from the actual Flutter screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final flutterRoot =
        Platform.environment['FLUTTER_ROOT'] ??
        Directory('../../work/tooling/flutter').absolute.path;
    await tester.runAsync(() async {
      final fonts = FontLoader('Roboto');
      for (final weight in ['regular', 'medium', 'bold', 'black']) {
        fonts.addFont(
          Future.value(
            ByteData.sublistView(
              File(
                '$flutterRoot/bin/cache/artifacts/material_fonts/roboto-$weight.ttf',
              ).readAsBytesSync(),
            ),
          ),
        );
      }
      await fonts.load();
      final emojiFile = File('C:/Windows/Fonts/seguiemj.ttf');
      if (await emojiFile.exists()) {
        final emoji = FontLoader('Emoji');
        emoji.addFont(
          Future.value(ByteData.sublistView(await emojiFile.readAsBytes())),
        );
        await emoji.load();
      }
      final icons = FontLoader('MaterialIcons');
      icons.addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
            ).readAsBytesSync(),
          ),
        ),
      );
      await icons.load();
    });
    final controller = LearningController(
      curriculum: fixture(),
      store: MemoryStore(),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.runAsync(() async {
      final context = tester.element(find.byType(SizedBox).first);
      for (final asset in ['reading', 'math']) {
        await precacheImage(
          ResizeImage(AssetImage('assets/images/$asset.png'), width: 1000),
          context,
        );
      }
    });
    final boundaryKey = GlobalKey();
    Future<void> capture(String name, Widget screen) async {
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp(
            key: ValueKey(name),
            debugShowCheckedModeBanner: false,
            theme: appTheme.copyWith(
              textTheme: appTheme.textTheme.apply(fontFamily: 'Roboto'),
            ),
            home: screen,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final output = File('docs/previews/$name.png');
        await output.parent.create(recursive: true);
        await output.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('welcome', HomeScreen(controller: controller));
    await controller.addProfile('Lina', 6, 2);
    await controller.recordResult(controller.curriculum.lessons.first, 4);
    await capture('home', HomeScreen(controller: controller));
    await capture('profiles', ProfileScreen(controller: controller));
    await capture(
      'lessons',
      LessonListScreen(controller: controller, subject: 'portuguese'),
    );
    await capture(
      'lesson',
      LessonScreen(
        controller: controller,
        lesson: controller.curriculum.lessons.first,
      ),
    );
    await tester.ensureVisible(find.text('Começar os desafios'));
    await tester.tap(find.text('Começar os desafios'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'docs/previews/quiz.png',
      ).writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
    await capture(
      'math-picture',
      const Scaffold(
        body: PageBody(child: CountingPicture(count: 5, removed: 2)),
      ),
    );
    for (final subject in ['portuguese', 'math']) {
      final lesson = controller.curriculum.lessons.firstWhere(
        (l) => l.subject == subject && l.id.contains('-visual-'),
      );
      await capture(
        '$subject-activity',
        LessonScreen(controller: controller, lesson: lesson),
      );
      await tester.ensureVisible(find.text('Começar os desafios'));
      await tester.tap(find.text('Começar os desafios'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'docs/previews/$subject-activity.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    await capture('parents', ParentScreen(controller: controller));
  });
}
