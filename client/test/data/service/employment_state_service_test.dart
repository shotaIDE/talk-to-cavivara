import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/employment_state_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  group('EmploymentStateService', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    EmploymentState notifier() =>
        container.read(employmentStateProvider.notifier);

    Future<void> waitForInitialization() => notifier().ensureInitialized();

    group('初期状態', () {
      test('永続化データがない場合はデフォルトカヴィヴァラのみ雇用されていること', () async {
        await waitForInitialization();

        final state = container.read(employmentStateProvider);
        expect(state, equals({'cavivara_default'}));
      });

      test('永続化データが存在する場合は永続化された値で初期化されること', () async {
        container.dispose();
        SharedPreferences.setMockInitialValues({
          PreferenceKey.employedCavivaraIds.name: <String>['cavivara_mascot'],
        });
        SharedPreferencesAsyncPlatform
            .instance = InMemorySharedPreferencesAsync.withData({
          PreferenceKey.employedCavivaraIds.name: <String>['cavivara_mascot'],
        });
        container = ProviderContainer();

        await container
            .read(employmentStateProvider.notifier)
            .ensureInitialized();

        final state = container.read(employmentStateProvider);
        expect(state, equals({'cavivara_mascot'}));
      });

      test('初期化後はデフォルトカヴィヴァラが雇用済みとして判定されること', () async {
        await waitForInitialization();

        expect(
          container.read(isEmployedProvider('cavivara_default')),
          isTrue,
        );
      });

      test('雇用中のカヴィヴァラIDリストにデフォルトが含まれること', () async {
        await waitForInitialization();

        final employedIds = container.read(employedCavivaraIdsProvider);
        expect(employedIds, contains('cavivara_default'));
      });
    });

    group('永続化', () {
      test('雇用状態の変更が永続化されること', () async {
        await waitForInitialization();
        await notifier().hire('cavivara_mascot');

        final newContainer = ProviderContainer();
        addTearDown(newContainer.dispose);
        await newContainer
            .read(employmentStateProvider.notifier)
            .ensureInitialized();

        final state = newContainer.read(employmentStateProvider);
        expect(state, containsAll({'cavivara_default', 'cavivara_mascot'}));
      });

      test('全員解雇後の状態が永続化されること', () async {
        await waitForInitialization();
        await notifier().fireAll();

        final newContainer = ProviderContainer();
        addTearDown(newContainer.dispose);
        await newContainer
            .read(employmentStateProvider.notifier)
            .ensureInitialized();

        expect(newContainer.read(employmentStateProvider), isEmpty);
      });
    });

    group('雇用処理', () {
      test('新しいカヴィヴァラを雇用できること', () async {
        await waitForInitialization();
        const cavivaraId = 'cavivara_mascot';

        await notifier().hire(cavivaraId);

        final state = container.read(employmentStateProvider);
        final isEmployed = container.read(isEmployedProvider(cavivaraId));

        expect(state, containsAll({'cavivara_default', cavivaraId}));
        expect(isEmployed, isTrue);
      });

      test('複数のカヴィヴァラを同時に雇用できること', () async {
        await waitForInitialization();
        const cavivaraId1 = 'cavivara_default';
        const cavivaraId2 = 'cavivara_mascot';

        await notifier().fireAll();
        await notifier().hire(cavivaraId1);
        await notifier().hire(cavivaraId2);

        final state = container.read(employmentStateProvider);
        final isEmployed1 = container.read(isEmployedProvider(cavivaraId1));
        final isEmployed2 = container.read(isEmployedProvider(cavivaraId2));

        expect(state, containsAll({cavivaraId1, cavivaraId2}));
        expect(isEmployed1, isTrue);
        expect(isEmployed2, isTrue);
      });

      test('同じカヴィヴァラを重複して雇用しても状態が変わらないこと', () async {
        await waitForInitialization();
        const cavivaraId = 'cavivara_mascot';

        await notifier().fireAll();
        await notifier().hire(cavivaraId);
        await notifier().hire(cavivaraId); // 重複雇用

        final state = container.read(employmentStateProvider);
        expect(state.where((id) => id == cavivaraId), hasLength(1));
      });
    });

    group('解雇処理', () {
      test('雇用中のカヴィヴァラを解雇できること', () async {
        await waitForInitialization();
        const cavivaraId = 'cavivara_default';
        expect(container.read(isEmployedProvider(cavivaraId)), isTrue);

        await notifier().fire(cavivaraId);

        final state = container.read(employmentStateProvider);
        final isEmployed = container.read(isEmployedProvider(cavivaraId));

        expect(state, isNot(contains(cavivaraId)));
        expect(isEmployed, isFalse);
      });

      test('未雇用のカヴィヴァラを解雇しても状態が変わらないこと', () async {
        await waitForInitialization();
        const cavivaraId = 'cavivara_mascot';

        await notifier().fire(cavivaraId);

        final state = container.read(employmentStateProvider);
        expect(state, equals({'cavivara_default'}));
      });

      test('複数雇用時に特定のカヴィヴァラのみ解雇できること', () async {
        await waitForInitialization();
        const cavivaraId1 = 'cavivara_default';
        const cavivaraId2 = 'cavivara_mascot';

        await notifier().hire(cavivaraId2);
        await notifier().fire(cavivaraId1);

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
      test('全員を解雇できること', () async {
        await waitForInitialization();
        await notifier().hire('cavivara_mascot');
        expect(container.read(employmentStateProvider), hasLength(2));

        await notifier().fireAll();

        final state = container.read(employmentStateProvider);
        expect(state, isEmpty);

        final isEmployed1 = container.read(
          isEmployedProvider('cavivara_default'),
        );
        final isEmployed2 = container.read(
          isEmployedProvider('cavivara_mascot'),
        );
        expect(isEmployed1, isFalse);
        expect(isEmployed2, isFalse);
      });

      test('全員未雇用状態で全員解雇しても状態が変わらないこと', () async {
        await waitForInitialization();
        await notifier().fireAll();

        final stateAfterFirst = container.read(employmentStateProvider);
        expect(stateAfterFirst, isEmpty);

        await notifier().fireAll();

        final stateAfterSecond = container.read(employmentStateProvider);
        expect(stateAfterSecond, isEmpty);
      });
    });

    group('雇用リスト取得', () {
      test('雇用中のカヴィヴァラIDリストが正しく取得できること', () async {
        await waitForInitialization();
        await notifier().hire('cavivara_mascot');

        final employedIds = container.read(employedCavivaraIdsProvider);
        expect(
          employedIds,
          containsAll(['cavivara_default', 'cavivara_mascot']),
        );
      });

      test('雇用状態の変化がリアルタイムで反映されること', () async {
        await waitForInitialization();
        const cavivaraId = 'cavivara_mascot';

        var employedIds = container.read(employedCavivaraIdsProvider);
        expect(employedIds, contains('cavivara_default'));
        expect(employedIds, isNot(contains(cavivaraId)));

        await notifier().hire(cavivaraId);
        employedIds = container.read(employedCavivaraIdsProvider);
        expect(employedIds, contains(cavivaraId));

        await notifier().fire(cavivaraId);
        employedIds = container.read(employedCavivaraIdsProvider);
        expect(employedIds, isNot(contains(cavivaraId)));
      });
    });

    group('状態通知', () {
      test('雇用状態の変化でプロバイダーが通知されること', () async {
        await waitForInitialization();
        final employmentStateNotifier = notifier();
        var notificationCount = 0;

        container.listen<Set<String>>(
          employmentStateProvider,
          (previous, next) {
            notificationCount++;
          },
        );

        await employmentStateNotifier.hire('cavivara_mascot');
        expect(notificationCount, equals(1));

        await employmentStateNotifier.fire('cavivara_mascot');
        expect(notificationCount, equals(2));

        await employmentStateNotifier.fireAll();
        expect(notificationCount, equals(3));
      });
    });
  });
}
