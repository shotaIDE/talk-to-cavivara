import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/data/service/employment_state_service.dart';

void main() {
  group('EmploymentStateService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('初期状態', () {
      test('初期状態では全員が未雇用であること', () {
        final state = container.read(employmentStateProvider);
        expect(state, isEmpty);
      });

      test('初期状態では特定のキャラクターが未雇用であること', () {
        const cavivaraId = 'cavivara_default';
        final isEmployed = container.read(isEmployedProvider(cavivaraId));
        expect(isEmployed, isFalse);
      });

      test('初期状態では雇用中のリストが空であること', () {
        final employedIds = container.read(employedCavivaraIdsProvider);
        expect(employedIds, isEmpty);
      });
    });

    group('雇用処理', () {
      test('カヴィヴァラを雇用できること', () {
        const cavivaraId = 'cavivara_default';
        final notifier = container.read(employmentStateProvider.notifier);

        notifier.hire(cavivaraId);

        final state = container.read(employmentStateProvider);
        expect(state, contains(cavivaraId));

        final isEmployed = container.read(isEmployedProvider(cavivaraId));
        expect(isEmployed, isTrue);
      });

      test('複数のカヴィヴァラを同時に雇用できること', () {
        const cavivaraId1 = 'cavivara_default';
        const cavivaraId2 = 'cavivara_technical';
        final notifier = container.read(employmentStateProvider.notifier);

        notifier.hire(cavivaraId1);
        notifier.hire(cavivaraId2);

        final state = container.read(employmentStateProvider);
        expect(state, containsAll([cavivaraId1, cavivaraId2]));

        final isEmployed1 = container.read(isEmployedProvider(cavivaraId1));
        final isEmployed2 = container.read(isEmployedProvider(cavivaraId2));
        expect(isEmployed1, isTrue);
        expect(isEmployed2, isTrue);
      });

      test('同じカヴィヴァラを重複して雇用しても状態が変わらないこと', () {
        const cavivaraId = 'cavivara_default';
        final notifier = container.read(employmentStateProvider.notifier);

        notifier.hire(cavivaraId);
        notifier.hire(cavivaraId); // 重複雇用

        final state = container.read(employmentStateProvider);
        expect(state, hasLength(1));
        expect(state, contains(cavivaraId));
      });
    });

    group('解雇処理', () {
      test('雇用中のカヴィヴァラを解雇できること', () {
        const cavivaraId = 'cavivara_default';
        final notifier = container.read(employmentStateProvider.notifier);

        // まず雇用
        notifier.hire(cavivaraId);
        expect(container.read(isEmployedProvider(cavivaraId)), isTrue);

        // 解雇
        notifier.fire(cavivaraId);

        final state = container.read(employmentStateProvider);
        expect(state, isNot(contains(cavivaraId)));

        final isEmployed = container.read(isEmployedProvider(cavivaraId));
        expect(isEmployed, isFalse);
      });

      test('未雇用のカヴィヴァラを解雇しても状態が変わらないこと', () {
        const cavivaraId = 'cavivara_default';
        final notifier = container.read(employmentStateProvider.notifier);

        // 解雇（未雇用状態から）
        notifier.fire(cavivaraId);

        final state = container.read(employmentStateProvider);
        expect(state, isEmpty);
      });

      test('複数雇用時に特定のカヴィヴァラのみ解雇できること', () {
        const cavivaraId1 = 'cavivara_default';
        const cavivaraId2 = 'cavivara_technical';
        final notifier = container.read(employmentStateProvider.notifier);

        // 両方を雇用
        notifier.hire(cavivaraId1);
        notifier.hire(cavivaraId2);

        // 一方のみ解雇
        notifier.fire(cavivaraId1);

        final state = container.read(employmentStateProvider);
        expect(state, isNot(contains(cavivaraId1)));
        expect(state, contains(cavivaraId2));

        final isEmployed1 = container.read(isEmployedProvider(cavivaraId1));
        final isEmployed2 = container.read(isEmployedProvider(cavivaraId2));
        expect(isEmployed1, isFalse);
        expect(isEmployed2, isTrue);
      });
    });

    group('全員解雇処理', () {
      test('全員を解雇できること', () {
        const cavivaraId1 = 'cavivara_default';
        const cavivaraId2 = 'cavivara_technical';
        final notifier = container.read(employmentStateProvider.notifier);

        // 複数を雇用
        notifier.hire(cavivaraId1);
        notifier.hire(cavivaraId2);
        expect(container.read(employmentStateProvider), hasLength(2));

        // 全員解雇
        notifier.fireAll();

        final state = container.read(employmentStateProvider);
        expect(state, isEmpty);

        final isEmployed1 = container.read(isEmployedProvider(cavivaraId1));
        final isEmployed2 = container.read(isEmployedProvider(cavivaraId2));
        expect(isEmployed1, isFalse);
        expect(isEmployed2, isFalse);
      });

      test('全員未雇用状態で全員解雇しても状態が変わらないこと', () {
        final notifier = container.read(employmentStateProvider.notifier);

        notifier.fireAll();

        final state = container.read(employmentStateProvider);
        expect(state, isEmpty);
      });
    });

    group('雇用リスト取得', () {
      test('雇用中のカヴィヴァラIDリストが正しく取得できること', () {
        const cavivaraId1 = 'cavivara_default';
        const cavivaraId2 = 'cavivara_technical';
        final notifier = container.read(employmentStateProvider.notifier);

        notifier.hire(cavivaraId1);
        notifier.hire(cavivaraId2);

        final employedIds = container.read(employedCavivaraIdsProvider);
        expect(employedIds, hasLength(2));
        expect(employedIds, containsAll([cavivaraId1, cavivaraId2]));
      });

      test('雇用状態の変化がリアルタイムで反映されること', () {
        const cavivaraId = 'cavivara_default';
        final notifier = container.read(employmentStateProvider.notifier);

        // 雇用前
        var employedIds = container.read(employedCavivaraIdsProvider);
        expect(employedIds, isEmpty);

        // 雇用後
        notifier.hire(cavivaraId);
        employedIds = container.read(employedCavivaraIdsProvider);
        expect(employedIds, contains(cavivaraId));

        // 解雇後
        notifier.fire(cavivaraId);
        employedIds = container.read(employedCavivaraIdsProvider);
        expect(employedIds, isEmpty);
      });
    });

    group('状態通知', () {
      test('雇用状態の変化でプロバイダーが通知されること', () {
        const cavivaraId = 'cavivara_default';
        final notifier = container.read(employmentStateProvider.notifier);
        var notificationCount = 0;

        // リスナーを追加
        container.listen(
          employmentStateProvider,
          (previous, next) {
            notificationCount++;
          },
        );

        notifier.hire(cavivaraId);
        expect(notificationCount, equals(1));

        notifier.fire(cavivaraId);
        expect(notificationCount, equals(2));

        notifier.fireAll();
        expect(notificationCount, equals(3));
      });
    });
  });
}
