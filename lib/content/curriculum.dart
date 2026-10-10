import 'dart:convert';
import 'package:flutter/services.dart';

class ActivityVisual {
  const ActivityVisual({
    required this.kind,
    required this.tokens,
    required this.label,
    this.left = 0,
    this.right = 0,
  });
  final String kind, label;
  final List<String> tokens;
  final int left, right;
  factory ActivityVisual.fromJson(Map<String, dynamic> json) {
    final kind = json['kind'] as String;
    final tokens = List<String>.from(json['tokens'] as List);
    final label = json['label'] as String;
    final left = json['left'] as int? ?? 0, right = json['right'] as int? ?? 0;
    if (![
          'picture',
          'count',
          'addition',
          'subtraction',
          'compare',
          'sequence',
          'shape',
          'length',
        ].contains(kind) ||
        tokens.isEmpty ||
        tokens.length > 8 ||
        tokens.any((t) => t.trim().isEmpty) ||
        label.trim().isEmpty ||
        left < 0 ||
        left > 20 ||
        right < 0 ||
        right > 20 ||
        (kind == 'subtraction' && right > left) ||
        (kind == 'addition' && left + right > 20) ||
        ([
              'count',
              'addition',
              'subtraction',
              'compare',
              'length',
            ].contains(kind) &&
            left == 0)) {
      throw const FormatException('Ilustração inválida');
    }
    return ActivityVisual(
      kind: kind,
      tokens: List.unmodifiable(tokens),
      label: label,
      left: left,
      right: right,
    );
  }
}

class Exercise {
  const Exercise({
    required this.prompt,
    required this.choices,
    required this.answer,
    required this.explanation,
    this.visual,
  });
  final String prompt;
  final List<String> choices;
  final int answer;
  final String explanation;
  final ActivityVisual? visual;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final choices = List<String>.from(json['choices'] as List);
    final answer = json['answer'] as int;
    final prompt = json['prompt'] as String;
    final explanation = json['explanation'] as String;
    if (choices.length < 2 ||
        choices.length > 4 ||
        choices.toSet().length != choices.length ||
        choices.any((c) => c.trim().isEmpty) ||
        answer < 0 ||
        answer >= choices.length ||
        prompt.trim().isEmpty ||
        explanation.trim().isEmpty) {
      throw const FormatException('Exercício inválido');
    }
    return Exercise(
      prompt: prompt,
      choices: List.unmodifiable(choices),
      answer: answer,
      explanation: explanation,
      visual: json['visual'] == null
          ? null
          : ActivityVisual.fromJson(
              Map<String, dynamic>.from(json['visual'] as Map),
            ),
    );
  }
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.subject,
    required this.level,
    required this.objective,
    required this.introduction,
    required this.exercises,
  });
  final String id, title, subject, objective, introduction;
  final int level;
  final List<Exercise> exercises;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final lesson = Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      level: json['level'] as int,
      objective: json['objective'] as String,
      introduction: json['introduction'] as String,
      exercises: List.unmodifiable(
        (json['exercises'] as List).map(
          (e) => Exercise.fromJson(Map<String, dynamic>.from(e as Map)),
        ),
      ),
    );
    if (lesson.id.isEmpty ||
        lesson.title.isEmpty ||
        lesson.objective.isEmpty ||
        lesson.introduction.isEmpty ||
        !['portuguese', 'math'].contains(lesson.subject) ||
        lesson.level < 1 ||
        lesson.level > 3 ||
        lesson.exercises.isEmpty) {
      throw const FormatException('Lição inválida');
    }
    return lesson;
  }
}

class Curriculum {
  const Curriculum(this.lessons);
  final List<Lesson> lessons;

  factory Curriculum.parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    if (json['schemaVersion'] != 1 || json['language'] != 'pt-MZ') {
      throw const FormatException('Versão de conteúdo não suportada');
    }
    final lessons = (json['lessons'] as List)
        .map((e) => Lesson.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (lessons.isEmpty ||
        lessons.map((e) => e.id).toSet().length != lessons.length) {
      throw const FormatException('Lições vazias ou repetidas');
    }
    return Curriculum(List.unmodifiable(lessons));
  }

  static Future<Curriculum> load() async => Curriculum.parse(
    await rootBundle.loadString('assets/content/curriculum.json'),
  );
}
