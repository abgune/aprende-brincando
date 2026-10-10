import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../content/curriculum.dart';
import '../audio/read_aloud.dart';
import '../state/learning_controller.dart';

part 'screens/home_screen.dart';
part 'screens/profile_screen.dart';
part 'screens/lesson_list_screen.dart';
part 'screens/lesson_screen.dart';
part 'screens/stars.dart';
part 'screens/read_aloud_button.dart';
part 'screens/learning_visuals.dart';
part 'screens/parent_screen.dart';

const ink = Color(0xFF19354B);
const green = Color(0xFF138777);
const purple = Color(0xFF7560C4);
const canvas = Color(0xFFFFF9EE);
const avatarIcons = [
  Icons.pets_rounded,
  Icons.rocket_launch_rounded,
  Icons.local_florist_rounded,
  Icons.bolt_rounded,
];
final appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.fromSeed(seedColor: green, surface: Colors.white),
  scaffoldBackgroundColor: canvas,
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: ink,
    displayColor: ink,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: canvas,
    foregroundColor: ink,
    centerTitle: false,
    scrolledUnderElevation: 0,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
  ),
);

class LearningApp extends StatelessWidget {
  const LearningApp({super.key, required this.controller});
  final LearningController controller;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Aprende Brincando',
    debugShowCheckedModeBanner: false,
    theme: appTheme,
    locale: const Locale('pt', 'MZ'),
    supportedLocales: const [Locale('pt', 'MZ')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: HomeScreen(controller: controller),
  );
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: child,
        ),
      ),
    ),
  );
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(22),
  });
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: ink.withValues(alpha: .05)),
    ),
    child: child,
  );
}

Future<bool> saveAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
    return true;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível guardar. Verifique o espaço livre e tente novamente.',
          ),
        ),
      );
    }
    return false;
  }
}

String subjectName(String subject) =>
    subject == 'portuguese' ? 'Português' : 'Matemática';
Color subjectColor(String subject) => subject == 'portuguese' ? green : purple;
IconData subjectIcon(String subject) =>
    subject == 'portuguese' ? Icons.menu_book_rounded : Icons.calculate_rounded;
