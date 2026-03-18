import 'package:flutter_test/flutter_test.dart';
import 'package:kohere/features/log/coffee_log.dart';

void main() {
  group('CoffeeLog Model Tests', () {
    test('toMap and fromMap should be consistent', () {
      final now = DateTime.now();
      final log = CoffeeLog(
        id: '1',
        cafeName: 'Test Cafe',
        menu: 'Latte',
        weather: 'Sunny',
        mood: 'Happy',
        ambiance: 'Quiet',
        memo: 'Good coffee',
        createdAt: now,
        folderName: 'Seoul',
      );

      final map = log.toMap();
      final fromMap = CoffeeLog.fromMap(map);

      expect(fromMap.id, log.id);
      expect(fromMap.cafeName, log.cafeName);
      expect(fromMap.menu, log.menu);
      expect(fromMap.weather, log.weather);
      expect(fromMap.mood, log.mood);
      expect(fromMap.ambiance, log.ambiance);
      expect(fromMap.memo, log.memo);
      // Compare ISO strings to avoid microsecond differences in some environments
      expect(fromMap.createdAt.toIso8601String(), log.createdAt.toIso8601String());
      expect(fromMap.folderName, log.folderName);
    });

    test('copyWith should work correctly', () {
      final log = CoffeeLog(
        id: '1',
        cafeName: 'Original Cafe',
        menu: 'Original Menu',
        weather: 'Sunny',
        mood: 'Happy',
        ambiance: 'Quiet',
        memo: 'Original Memo',
        createdAt: DateTime.now(),
      );

      final updated = log.copyWith(
        cafeName: 'New Cafe',
        memo: 'New Memo',
        isInTrash: true,
      );

      expect(updated.id, log.id);
      expect(updated.cafeName, 'New Cafe');
      expect(updated.memo, 'New Memo');
      expect(updated.isInTrash, true);
      expect(updated.menu, log.menu); // Should stay original
    });
  });
}
