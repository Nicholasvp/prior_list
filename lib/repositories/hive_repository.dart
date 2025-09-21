import 'package:hive/hive.dart';

class HiveRepository {
  final String boxName;
  Box? _box;

  HiveRepository(this.boxName);

  Future<Box> _getBox() async {
    if (_box?.isOpen == true) return _box!;
    _box = await Hive.openBox(boxName);
    return _box!;
  }

  Future<void> create(String key, dynamic value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  Future<dynamic> read(String key) async {
    final box = await _getBox();
    return box.get(key);
  }

  Future<void> update(String key, dynamic value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  Future<void> delete(String key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  Future<void> deleteAll(List<dynamic> keys) async {
    final box = await _getBox();
    await box.deleteAll(keys);
  }

  Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
  }

  Future<List<dynamic>> getAll(List<dynamic> keys) async {
    final box = await _getBox();
    return keys.map((key) => box.get(key)).toList();
  }

  Future<List<dynamic>> getAllKeys() async {
    final box = await _getBox();
    return box.keys.toList();
  }

  Future<Map<dynamic, dynamic>> getAllValues() async {
    final box = await _getBox();
    return box.toMap();
  }

  Future<void> close() async {
    if (_box?.isOpen == true) await _box?.close();
    _box = null;
  }
}
