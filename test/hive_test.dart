import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  group('Hive CRUD', () {
    const boxName = 'testBox';
    setUpAll(() async {
      final dir = Directory('./test/hive_test_dir');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      Hive.init(dir.path);
    });

    tearDownAll(() async {
      await Hive.deleteBoxFromDisk(boxName);
      Directory('./test/hive_test_dir').deleteSync(recursive: true);
    });

    test('Create, Read, Update, Delete', () async {
      var box = await Hive.openBox(boxName);

      // Create
      await box.put('key1', 'value1');
      expect(box.get('key1'), 'value1');

      // Read
      var value = box.get('key1');
      expect(value, 'value1');

      // Update
      await box.put('key1', 'value2');
      expect(box.get('key1'), 'value2');

      // Delete
      await box.delete('key1');
      expect(box.get('key1'), null);

      await box.close();
    });
  });
}
