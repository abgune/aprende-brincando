import 'dart:io';
import 'package:aprende_brincando/content/curriculum.dart';
import 'package:aprende_brincando/data/local_store.dart';

Curriculum fixture() =>
    Curriculum.parse(File('assets/content/curriculum.json').readAsStringSync());

class MemoryStore implements LocalStore {
  String? value;
  bool failWrites = false;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String next) async {
    if (failWrites) throw const FileSystemException('Storage unavailable');
    value = next;
  }
}
