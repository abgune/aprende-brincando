import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalStore {
  Future<String?> read();
  Future<void> write(String value);
}

class PreferencesStore implements LocalStore {
  PreferencesStore(this.preferences);
  final SharedPreferences preferences;
  static const key = 'aprende_brincando.state.v1';
  @override
  Future<String?> read() async => preferences.getString(key);
  @override
  Future<void> write(String value) async {
    if (!await preferences.setString(key, value)) {
      throw StateError('Não foi possível guardar no dispositivo.');
    }
  }
}
