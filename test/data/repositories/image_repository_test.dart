import 'package:flutter_test/flutter_test.dart';
import 'package:radioquiz/data/repositories/image_repository.dart';

void main() {
  setUp(() {
    ImageRepository.resetCache();
  });

  group('ImageRepository', () {
    test('fetchImages returns cached data when cache is pre-seeded', () async {
      ImageRepository.seedCache('level1', {'test.png': 'assets/image/level1/test.png'});

      final repo = ImageRepository();
      final images = await repo.fetchImages('level1');

      expect(images, isNotNull);
      expect(images['test.png'], 'assets/image/level1/test.png');
    });

    test('fetchImages returns the same map instance on subsequent calls (cache)',
        () async {
      ImageRepository.seedCache('level1', {'test.png': 'assets/image/level1/test.png'});

      final repo = ImageRepository();
      final firstCall = await repo.fetchImages('level1');
      final secondCall = await repo.fetchImages('level1');

      expect(identical(firstCall, secondCall), isTrue,
          reason: 'Cache should return the same Map instance');
    });

    test('fetchImages returns an empty map from cache for a level with no data',
        () async {
      ImageRepository.seedCache('level3', {});

      final repo = ImageRepository();
      final images = await repo.fetchImages('level3');

      expect(images, isEmpty);
    });

    test('cache is isolated per level', () async {
      ImageRepository.seedCache('level1', {'a.png': 'assets/image/level1/a.png'});
      ImageRepository.seedCache('level2', {'b.png': 'assets/image/level2/b.png'});

      final repo = ImageRepository();
      final level1 = await repo.fetchImages('level1');
      final level2 = await repo.fetchImages('level2');

      expect(level1.containsKey('a.png'), isTrue);
      expect(level1.containsKey('b.png'), isFalse);
      expect(level2.containsKey('b.png'), isTrue);
      expect(level2.containsKey('a.png'), isFalse);
    });
  });
}
