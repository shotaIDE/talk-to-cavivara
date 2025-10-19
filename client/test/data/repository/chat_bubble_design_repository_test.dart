import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/data/model/chat_bubble_design.dart';
import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/repository/chat_bubble_design_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  group('ChatBubbleDesignRepository', () {
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

    group('初期状態', () {
      test('永続化データがない場合はデフォルト値(square)が返されること', () async {
        final design = await container.read(
          chatBubbleDesignRepositoryProvider.future,
        );

        expect(design, equals(ChatBubbleDesign.square));
      });

      test('永続化データが存在する場合は永続化された値で初期化されること', () async {
        container.dispose();
        SharedPreferences.setMockInitialValues({
          PreferenceKey.chatBubbleDesign.name: 'rounded',
        });
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData({
              PreferenceKey.chatBubbleDesign.name: 'rounded',
            });
        container = ProviderContainer();

        final design = await container.read(
          chatBubbleDesignRepositoryProvider.future,
        );

        expect(design, equals(ChatBubbleDesign.rounded));
      });

      test('不正な値が保存されている場合はデフォルト値(square)が返されること', () async {
        container.dispose();
        SharedPreferences.setMockInitialValues({
          PreferenceKey.chatBubbleDesign.name: 'invalid_value',
        });
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData({
              PreferenceKey.chatBubbleDesign.name: 'invalid_value',
            });
        container = ProviderContainer();

        final design = await container.read(
          chatBubbleDesignRepositoryProvider.future,
        );

        expect(design, equals(ChatBubbleDesign.square));
      });
    });

    group('保存処理', () {
      test('デザインを保存できること', () async {
        await container
            .read(chatBubbleDesignRepositoryProvider.notifier)
            .save(ChatBubbleDesign.rounded);

        final design = await container.read(
          chatBubbleDesignRepositoryProvider.future,
        );
        expect(design, equals(ChatBubbleDesign.rounded));
      });

      test('保存したデザインが永続化されること', () async {
        await container
            .read(chatBubbleDesignRepositoryProvider.notifier)
            .save(ChatBubbleDesign.rounded);

        final newContainer = ProviderContainer();
        addTearDown(newContainer.dispose);
        final design = await newContainer.read(
          chatBubbleDesignRepositoryProvider.future,
        );

        expect(design, equals(ChatBubbleDesign.rounded));
      });

      test('squareからroundedに変更できること', () async {
        final notifier = container.read(
          chatBubbleDesignRepositoryProvider.notifier,
        );

        var design = await container.read(
          chatBubbleDesignRepositoryProvider.future,
        );
        expect(design, equals(ChatBubbleDesign.square));

        await notifier.save(ChatBubbleDesign.rounded);

        design = await container.read(
          chatBubbleDesignRepositoryProvider.future,
        );
        expect(design, equals(ChatBubbleDesign.rounded));
      });

      test('roundedからsquareに変更できること', () async {
        final notifier = container.read(
          chatBubbleDesignRepositoryProvider.notifier,
        );

        await notifier.save(ChatBubbleDesign.rounded);
        var design = await container.read(
          chatBubbleDesignRepositoryProvider.future,
        );
        expect(design, equals(ChatBubbleDesign.rounded));

        await notifier.save(ChatBubbleDesign.square);

        design = await container.read(
          chatBubbleDesignRepositoryProvider.future,
        );
        expect(design, equals(ChatBubbleDesign.square));
      });
    });

    group('状態通知', () {
      test('デザイン変更でプロバイダーが通知されること', () async {
        // 初期化のために一度読み込む
        await container.read(chatBubbleDesignRepositoryProvider.future);

        final notifier = container.read(
          chatBubbleDesignRepositoryProvider.notifier,
        );
        var notificationCount = 0;

        container.listen<AsyncValue<ChatBubbleDesign>>(
          chatBubbleDesignRepositoryProvider,
          (previous, next) {
            notificationCount++;
          },
        );

        await notifier.save(ChatBubbleDesign.rounded);
        expect(notificationCount, equals(1));

        await notifier.save(ChatBubbleDesign.square);
        expect(notificationCount, equals(2));
      });
    });
  });
}
