import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class SpeechBackend {
  void Function(String id, bool failed)? onFinished;
  Future<bool> prepare();
  Future<void> speak(String text, String id);
  Future<void> stop();
  void dispose();
}

class PlatformSpeech extends SpeechBackend {
  static const channel = MethodChannel('mz.aprendebrincando/speech');
  static PlatformSpeech? owner;
  @override
  Future<bool> prepare() async {
    owner = this;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'finished') {
        final data = Map<String, dynamic>.from(call.arguments as Map);
        onFinished?.call(data['id'] as String, data['failed'] == true);
      }
    });
    return await channel.invokeMethod<bool>('prepare') ?? false;
  }

  @override
  Future<void> speak(String text, String id) =>
      channel.invokeMethod<void>('speak', {'text': text, 'id': id});
  @override
  Future<void> stop() async {
    if (owner == this) await channel.invokeMethod<void>('stop');
  }

  @override
  void dispose() {
    if (owner == this) {
      owner = null;
      channel.setMethodCallHandler(null);
    }
  }
}

class ReadAloudController extends ChangeNotifier {
  ReadAloudController({SpeechBackend? backend})
    : backend = backend ?? PlatformSpeech() {
    this.backend.onFinished = (id, failed) {
      if (_disposed || id != activeId) return;
      activeId = null;
      if (failed) error = 'Não foi possível ler. Tenta novamente.';
      notifyListeners();
    };
  }
  final SpeechBackend backend;
  static int _sequence = 0;
  bool preparing = false, _disposed = false;
  int _generation = 0;
  String? activeId, activeKey, error;
  Future<void> toggle(String key, String text) async {
    if (preparing || _disposed) return;
    if (activeId != null && activeKey == key) {
      await stop();
      return;
    }
    final generation = ++_generation;
    preparing = true;
    error = null;
    notifyListeners();
    try {
      await backend.stop();
      final ready = await backend.prepare().timeout(const Duration(seconds: 8));
      if (_disposed || generation != _generation) return;
      if (!ready) {
        activeId = null;
        error =
            'Pede a um adulto para instalar uma voz portuguesa offline nas definições de voz do Android.';
      } else {
        activeId = 'reading-${++_sequence}';
        activeKey = key;
        await backend.speak(spokenText(text), activeId!);
      }
    } catch (_) {
      if (!_disposed && generation == _generation) {
        activeId = null;
        error = 'A leitura não está disponível agora. Pede ajuda a um adulto.';
      }
    } finally {
      if (!_disposed && generation == _generation) {
        preparing = false;
        notifyListeners();
      }
    }
  }

  Future<void> stop() async {
    _generation++;
    preparing = false;
    activeId = null;
    activeKey = null;
    if (!_disposed) notifyListeners();
    try {
      await backend.stop();
    } catch (_) {
      /* Stopping must never block navigation. */
    }
  }

  static String spokenText(String text) => text
      .replaceAll('+', ' mais ')
      .replaceAll('−', ' menos ')
      .replaceAll('=', ' é igual a ')
      .replaceAll('_', ' espaço ')
      .replaceAll('●', ' ponto ');
  @override
  void dispose() {
    _disposed = true;
    _generation++;
    backend.onFinished = null;
    unawaited(backend.stop().catchError((Object _) {}));
    backend.dispose();
    super.dispose();
  }
}
