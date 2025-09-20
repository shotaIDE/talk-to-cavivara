import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/data/service/employment_state_service.dart';
import 'package:house_worker/ui/feature/resume/resume_screen.dart';

void main() {
  group('ResumeScreen', () {
    const testCavivaraId = 'cavivara_default';

    testWidgets(
      'displays resume content for given cavivara',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ResumeScreen(cavivaraId: testCavivaraId),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // AppBarにカヴィヴァラの名前が表示されることを確認
        expect(find.text('カヴィヴァラ'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'shows hire button when cavivara is not employed',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ResumeScreen(cavivaraId: testCavivaraId),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 雇用するボタンが表示されることを確認
        expect(find.text('雇用する'), findsOneWidget);
        expect(find.text('解雇する'), findsNothing);
        expect(find.text('相談する'), findsNothing);
      },
    );

    testWidgets(
      'shows fire and consult buttons when cavivara is employed',
      (WidgetTester tester) async {
        late ProviderContainer container;
        await tester.pumpWidget(
          ProviderScope(
            child: Builder(
              builder: (context) {
                container = ProviderScope.containerOf(context);
                return const MaterialApp(
                  home: ResumeScreen(cavivaraId: testCavivaraId),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // カヴィヴァラを雇用
        container.read(employmentStateProvider.notifier).hire(testCavivaraId);
        await tester.pumpAndSettle();

        // 解雇ボタンと相談ボタンが表示されることを確認
        expect(find.text('解雇する'), findsOneWidget);
        expect(find.text('相談する'), findsOneWidget);
        expect(find.text('雇用する'), findsNothing);
      },
    );

    testWidgets(
      'employment state changes are reflected in button display',
      (WidgetTester tester) async {
        late ProviderContainer container;
        await tester.pumpWidget(
          ProviderScope(
            child: Builder(
              builder: (context) {
                container = ProviderScope.containerOf(context);
                return const MaterialApp(
                  home: ResumeScreen(cavivaraId: testCavivaraId),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 初期状態: 雇用するボタンのみ
        expect(find.text('雇用する'), findsOneWidget);
        expect(find.text('解雇する'), findsNothing);
        expect(find.text('相談する'), findsNothing);

        // 雇用後: 解雇と相談ボタン
        container.read(employmentStateProvider.notifier).hire(testCavivaraId);
        await tester.pumpAndSettle();

        expect(find.text('雇用する'), findsNothing);
        expect(find.text('解雇する'), findsOneWidget);
        expect(find.text('相談する'), findsOneWidget);

        // 解雇後: 雇用するボタンのみ
        container.read(employmentStateProvider.notifier).fire(testCavivaraId);
        await tester.pumpAndSettle();

        expect(find.text('雇用する'), findsOneWidget);
        expect(find.text('解雇する'), findsNothing);
        expect(find.text('相談する'), findsNothing);
      },
    );

    testWidgets('can be created without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ResumeScreen(cavivaraId: testCavivaraId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ウィジェットが正常に作成されることを確認
      expect(find.byType(ResumeScreen), findsOneWidget);
    });

    testWidgets(
      'handles valid cavivara id correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ResumeScreen(cavivaraId: testCavivaraId),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // 履歴書画面が正常に表示されることを確認
        expect(find.byType(ResumeScreen), findsOneWidget);
        expect(find.text('雇用する'), findsOneWidget);
      },
    );
  });
}
