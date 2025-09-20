import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/employment_state_service.dart';
import 'package:house_worker/ui/feature/job_market/job_market_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  group('JobMarketScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    testWidgets('displays job market title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JobMarketScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // タイトルが表示されることを確認
      expect(find.text('転職市場'), findsOneWidget);
    });

    testWidgets('can be created without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JobMarketScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ウィジェットが正常に作成されることを確認
      expect(find.byType(JobMarketScreen), findsOneWidget);
    });

    testWidgets('displays cavivara profiles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JobMarketScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // カヴィヴァラの名前が表示されることを確認
      expect(find.text('カヴィヴァラ'), findsOneWidget);
      expect(find.text('カヴィヴァラ・マスコット'), findsOneWidget);
    });

    testWidgets(
      'shows employment badge for employed cavivara',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: JobMarketScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 雇用中バッジが表示されることを確認
        expect(find.text('雇用中'), findsOneWidget);
      },
    );

    testWidgets(
      'shows consult button for employed cavivara',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: JobMarketScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 相談ボタンが表示されることを確認
        expect(find.text('相談する'), findsOneWidget);
      },
    );

    testWidgets(
      'employment state changes are reflected in real-time',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({
          PreferenceKey.employedCavivaraIds.name: <String>[],
        });
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData({
              PreferenceKey.employedCavivaraIds.name: <String>[],
            });
        late ProviderContainer container;
        await tester.pumpWidget(
          ProviderScope(
            child: Builder(
              builder: (context) {
                container = ProviderScope.containerOf(context);
                return const MaterialApp(
                  home: JobMarketScreen(),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 複数のカヴィヴァラを雇用
        await container
            .read(employmentStateProvider.notifier)
            .hire('cavivara_default');
        await container
            .read(employmentStateProvider.notifier)
            .hire('cavivara_mascot');
        await tester.pumpAndSettle();

        // 両方の雇用中バッジが表示されることを確認
        expect(find.text('雇用中'), findsNWidgets(2));
        expect(find.text('相談する'), findsNWidgets(2));

        // 一人を解雇
        await container
            .read(employmentStateProvider.notifier)
            .fire('cavivara_default');
        await tester.pumpAndSettle();

        // 一つの雇用中バッジのみ表示されることを確認
        expect(find.text('雇用中'), findsOneWidget);
        expect(find.text('相談する'), findsOneWidget);
      },
    );
  });
}
