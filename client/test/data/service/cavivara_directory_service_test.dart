import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/data/service/cavivara_directory_service.dart';

void main() {
  group('CavivaraDirectoryService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('cavivaraDirectoryProvider', () {
      test('2名のカヴィヴァラプロフィールが期待通り取得できること', () {
        final profiles = container.read(cavivaraDirectoryProvider);

        expect(profiles, hasLength(2));

        // デフォルトカヴィヴァラの確認
        final defaultCavivara = profiles.firstWhere(
          (profile) => profile.id == 'cavivara_default',
        );
        expect(defaultCavivara.displayName, equals('カヴィヴァラ'));
        expect(defaultCavivara.title, contains('マスコットキャラクター'));
        expect(defaultCavivara.resumeSections, isNotEmpty);

        // マスコットカヴィヴァラの確認
        final mascotCavivara = profiles.firstWhere(
          (profile) => profile.id == 'cavivara_mascot',
        );
        expect(mascotCavivara.displayName, equals('カヴィヴァラ・マスコット'));
        expect(mascotCavivara.title, contains('応援隊長'));
        expect(mascotCavivara.resumeSections, isNotEmpty);
      });
    });

    group('cavivaraByIdProvider', () {
      test('有効なIDで正しいプロフィールが取得できること', () {
        const targetId = 'cavivara_default';
        final profile = container.read(cavivaraByIdProvider(targetId));

        expect(profile.id, equals(targetId));
        expect(profile.displayName, equals('カヴィヴァラ'));
      });

      test('マスコットカヴィヴァラのIDで正しいプロフィールが取得できること', () {
        const targetId = 'cavivara_mascot';
        final profile = container.read(cavivaraByIdProvider(targetId));

        expect(profile.id, equals(targetId));
        expect(profile.displayName, equals('カヴィヴァラ・マスコット'));
      });

      test('存在しないIDでCavivaraNotFoundExceptionが投げられること', () {
        const invalidId = 'non_existent_id';

        expect(
          () => container.read(cavivaraByIdProvider(invalidId)),
          throwsA(isA<CavivaraNotFoundException>()),
        );
      });

      test('CavivaraNotFoundExceptionに正しいIDが含まれること', () {
        const invalidId = 'non_existent_id';

        try {
          container.read(cavivaraByIdProvider(invalidId));
          fail('CavivaraNotFoundExceptionが投げられるべきです');
        } on CavivaraNotFoundException catch (e) {
          expect(e.id, equals(invalidId));
          expect(e.toString(), contains(invalidId));
        }
      });
    });
  });
}
