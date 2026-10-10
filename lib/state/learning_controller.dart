import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../content/curriculum.dart';
import '../data/local_store.dart';

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.avatar,
  });
  final String id, name;
  final int age, avatar;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'avatar': avatar,
  };
  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    final profile = ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      avatar: json['avatar'] as int,
    );
    if (profile.id.isEmpty ||
        profile.name.trim().isEmpty ||
        profile.name.length > 24 ||
        profile.age < 5 ||
        profile.age > 8 ||
        profile.avatar < 0 ||
        profile.avatar > 3) {
      throw const FormatException('Perfil inválido');
    }
    return profile;
  }
}

class LessonProgress {
  const LessonProgress({
    required this.bestCorrect,
    required this.total,
    required this.attempts,
    required this.lastPlayed,
  });
  final int bestCorrect, total, attempts;
  final String lastPlayed;
  int get stars => starsFor(bestCorrect, total);
  static int starsFor(int correct, int total) => correct == total
      ? 3
      : correct * 2 >= total
      ? 2
      : correct > 0
      ? 1
      : 0;
  Map<String, dynamic> toJson() => {
    'bestCorrect': bestCorrect,
    'total': total,
    'attempts': attempts,
    'lastPlayed': lastPlayed,
  };
  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    final result = LessonProgress(
      bestCorrect: json['bestCorrect'] as int,
      total: json['total'] as int,
      attempts: json['attempts'] as int,
      lastPlayed: json['lastPlayed'] as String,
    );
    if (result.total <= 0 ||
        result.bestCorrect < 0 ||
        result.bestCorrect > result.total ||
        result.attempts < 1 ||
        DateTime.tryParse(result.lastPlayed) == null) {
      throw const FormatException('Progresso inválido');
    }
    return result;
  }
}

class LearningController extends ChangeNotifier {
  LearningController({required this.curriculum, required this.store});
  final Curriculum curriculum;
  final LocalStore store;
  final List<ChildProfile> _profiles = [];
  final Map<String, Map<String, LessonProgress>> _progress = {};
  String? _activeId;
  bool saving = false;
  List<ChildProfile> get profiles => List.unmodifiable(_profiles);
  ChildProfile? get active =>
      _profiles.where((p) => p.id == _activeId).firstOrNull;
  Map<String, LessonProgress> progressFor(String id) =>
      Map.unmodifiable(_progress[id] ?? {});
  LessonProgress? progress(String lessonId) => _progress[_activeId]?[lessonId];
  int get stars =>
      progressFor(_activeId ?? '').values.fold(0, (sum, p) => sum + p.stars);

  Future<void> load() async {
    final source = await store.read();
    if (source == null) return;
    final json = jsonDecode(source) as Map<String, dynamic>;
    if (json['schemaVersion'] != 1) {
      throw const FormatException('Dados locais incompatíveis');
    }
    final profiles = (json['profiles'] as List)
        .map((e) => ChildProfile.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final ids = profiles.map((p) => p.id).toSet();
    if (ids.length != profiles.length) {
      throw const FormatException('Perfis repetidos');
    }
    final activeId = json['activeId'] as String?;
    if (profiles.isNotEmpty && !ids.contains(activeId)) {
      throw const FormatException('Perfil activo inválido');
    }
    final progress = <String, Map<String, LessonProgress>>{};
    for (final entry in (json['progress'] as Map<String, dynamic>).entries) {
      if (!ids.contains(entry.key)) {
        throw const FormatException('Perfil de progresso inválido');
      }
      progress[entry.key] = (entry.value as Map<String, dynamic>).map((
        key,
        value,
      ) {
        final lesson = curriculum.lessons.where((l) => l.id == key).firstOrNull;
        final record = LessonProgress.fromJson(
          Map<String, dynamic>.from(value as Map),
        );
        if (lesson == null || record.total != lesson.exercises.length) {
          throw const FormatException('Lição de progresso incompatível');
        }
        return MapEntry(key, record);
      });
    }
    _profiles
      ..clear()
      ..addAll(profiles);
    _progress
      ..clear()
      ..addAll(progress);
    _activeId = activeId;
    notifyListeners();
  }

  String _serialize(
    List<ChildProfile> profiles,
    String? activeId,
    Map<String, Map<String, LessonProgress>> progress,
  ) => jsonEncode({
    'schemaVersion': 1,
    'profiles': profiles.map((p) => p.toJson()).toList(),
    'activeId': activeId,
    'progress': progress.map(
      (key, value) =>
          MapEntry(key, value.map((id, p) => MapEntry(id, p.toJson()))),
    ),
  });

  Future<void> _commit(
    List<ChildProfile> profiles,
    String? activeId,
    Map<String, Map<String, LessonProgress>> progress,
  ) async {
    if (saving) throw StateError('Aguarde enquanto guardamos.');
    saving = true;
    notifyListeners();
    try {
      await store.write(_serialize(profiles, activeId, progress));
      _profiles
        ..clear()
        ..addAll(profiles);
      _progress
        ..clear()
        ..addAll(progress);
      _activeId = activeId;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> addProfile(String name, int age, int avatar) async {
    final cleaned = name.trim();
    if (cleaned.isEmpty ||
        cleaned.length > 24 ||
        age < 5 ||
        age > 8 ||
        avatar < 0 ||
        avatar > 3) {
      throw ArgumentError('Verifique o nome e a idade.');
    }
    if (_profiles.length >= 8) {
      throw StateError('Este protótipo permite até oito perfis.');
    }
    final random = Random.secure();
    String id;
    do {
      id = base64Url
          .encode(List.generate(16, (_) => random.nextInt(256)))
          .replaceAll('=', '');
    } while (_profiles.any((profile) => profile.id == id));
    final profile = ChildProfile(
      id: id,
      name: cleaned,
      age: age,
      avatar: avatar,
    );
    await _commit([..._profiles, profile], id, Map.of(_progress));
  }

  Future<void> selectProfile(String id) async {
    if (!_profiles.any((p) => p.id == id)) {
      throw ArgumentError('Perfil desconhecido');
    }
    await _commit(List.of(_profiles), id, Map.of(_progress));
  }

  Future<void> recordResult(Lesson lesson, int correct) async {
    final childId = _activeId;
    if (childId == null ||
        !curriculum.lessons.contains(lesson) ||
        correct < 0 ||
        correct > lesson.exercises.length) {
      throw ArgumentError('Resultado inválido');
    }
    final previous = _progress[childId]?[lesson.id];
    final records = Map<String, LessonProgress>.of(_progress[childId] ?? {});
    records[lesson.id] = LessonProgress(
      bestCorrect: previous != null && previous.bestCorrect > correct
          ? previous.bestCorrect
          : correct,
      total: lesson.exercises.length,
      attempts: (previous?.attempts ?? 0) + 1,
      lastPlayed: DateTime.now().toUtc().toIso8601String(),
    );
    await _commit(List.of(_profiles), childId, {
      ..._progress,
      childId: records,
    });
  }
}
