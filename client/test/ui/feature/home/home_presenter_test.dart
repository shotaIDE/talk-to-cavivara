import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/data/model/cavivara_profile.dart';
import 'package:house_worker/data/model/chat_message.dart';
import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/repository/received_chat_string_count_repository.dart';
import 'package:house_worker/data/repository/sent_chat_string_count_repository.dart';
import 'package:house_worker/data/service/ai_chat_service.dart';
import 'package:house_worker/data/service/cavivara_directory_service.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:house_worker/ui/feature/home/home_presenter.dart';
import 'package:mocktail/mocktail.dart';

class MockAiChatService extends Mock implements AiChatService {}

class MockPreferenceService extends Mock implements PreferenceService {}

// 簡単な実装でテスト用のリポジトリを作成
class TestReceivedChatStringCountRepository
    extends ReceivedChatStringCountRepository {
  @override
  Future<int> build() async => 0;

  @override
  Future<void> add(int stringCount) async {
    // テスト用の空実装
  }
}

class TestSentChatStringCountRepository extends SentChatStringCountRepository {
  @override
  Future<int> build() async => 0;

  @override
  Future<void> add(int stringCount) async {
    // テスト用の空実装
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(PreferenceKey.currentHouseId);
  });

  group('Home Presenter - Chat Messages', () {
    late MockAiChatService mockAiChatService;
    late MockPreferenceService mockPreferenceService;
    late TestReceivedChatStringCountRepository
        testReceivedChatStringCountRepository;
    late TestSentChatStringCountRepository testSentChatStringCountRepository;
    late ProviderContainer container;

    setUp(() {
      mockAiChatService = MockAiChatService();
      mockPreferenceService = MockPreferenceService();
      testReceivedChatStringCountRepository =
          TestReceivedChatStringCountRepository();
      testSentChatStringCountRepository = TestSentChatStringCountRepository();

      // モックの設定 - UserStatisticsRepository用
      when(
        () => mockPreferenceService.getInt(any()),
      ).thenAnswer((_) async => 0);
      when(
        () => mockPreferenceService.setInt(any(), value: any(named: 'value')),
      ).thenAnswer((_) async {});

      // ChatStringCountRepository用のモックはテスト実装で対応

      // テスト用のカヴィヴァラプロフィールを作成
      const testCavivaraProfile1 = CavivaraProfile(
        id: 'cavivara_default',
        displayName: 'テストカヴィヴァラ1',
        title: 'テスト用',
        description: 'テスト用のカヴィヴァラです',
        iconPath: 'test_icon.png',
        aiPrompt: 'You are a helpful assistant.',
        tags: ['test'],
        resumeSections: [],
      );
      
      const testCavivaraProfile2 = CavivaraProfile(
        id: 'cavivara_mascot',
        displayName: 'テストカヴィヴァラ2',
        title: 'テスト用マスコット',
        description: 'テスト用のマスコットカヴィヴァラです',
        iconPath: 'test_mascot_icon.png',
        aiPrompt: 'You are a mascot assistant.',
        tags: ['test', 'mascot'],
        resumeSections: [],
      );

      container = ProviderContainer(
        overrides: [
          aiChatServiceProvider.overrideWith((ref) => mockAiChatService),
          preferenceServiceProvider.overrideWith(
            (ref) => mockPreferenceService,
          ),
          receivedChatStringCountRepositoryProvider
              .overrideWith(() => testReceivedChatStringCountRepository),
          sentChatStringCountRepositoryProvider
              .overrideWith(() => testSentChatStringCountRepository),
          cavivaraDirectoryProvider.overrideWith(
            (ref) => [testCavivaraProfile1, testCavivaraProfile2],
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('chatMessagesProvider', () {
      test('初期状態では空のメッセージリストが返されること', () {
        const cavivaraId = 'cavivara_default';
        final messages = container.read(chatMessagesProvider(cavivaraId));

        expect(messages, isEmpty);
      });

      test(
        '異なるカヴィヴァラIDに対して独立したメッセージリストが管理されること',
        () {
          const cavivaraId1 = 'cavivara_default';
          const cavivaraId2 = 'cavivara_mascot';

          final messages1 = container.read(chatMessagesProvider(cavivaraId1));
          final messages2 = container.read(chatMessagesProvider(cavivaraId2));

          expect(messages1, isEmpty);
          expect(messages2, isEmpty);
          expect(identical(messages1, messages2), isFalse);
        },
      );
    });

    group('sendMessage', () {
      test('メッセージ送信に成功した場合、メッセージリストが更新されること', () async {
        const cavivaraId = 'cavivara_default';
        const messageText = 'テストメッセージ';

        // AI サービスのモック設定
        when(
          () => mockAiChatService.sendMessageStream(
            messageText,
            systemPrompt: any<String>(named: 'systemPrompt'),
            conversationHistory: any<List<ChatMessage>?>(
              named: 'conversationHistory',
            ),
          ),
        ).thenAnswer((_) => Stream.value('AIからの返信'));

        final notifier = container.read(
          chatMessagesProvider(cavivaraId).notifier,
        );

        // メッセージ送信
        await notifier.sendMessage(messageText);

        final messages = container.read(chatMessagesProvider(cavivaraId));

        // ユーザーメッセージとAIメッセージが追加されていることを確認
        expect(messages, hasLength(2));
        expect(messages[0].content, equals(messageText));
        expect(messages[0].sender, equals(const ChatMessageSender.user()));
        expect(messages[1].content, equals('AIからの返信'));
        expect(messages[1].sender, equals(const ChatMessageSender.ai()));
      });

      test(
        'AI サービス呼び出し時に適切なパラメーターが渡されること',
        () async {
          const cavivaraId = 'cavivara_default';
          const messageText = 'テストメッセージ';

          when(
            () => mockAiChatService.sendMessageStream(
              messageText,
              systemPrompt: any<String>(named: 'systemPrompt'),
              conversationHistory: any<List<ChatMessage>?>(
                named: 'conversationHistory',
              ),
            ),
          ).thenAnswer((_) => Stream.value('AIからの返信'));

          final notifier = container.read(
            chatMessagesProvider(cavivaraId).notifier,
          );
          await notifier.sendMessage(messageText);

          // AI サービスが適切なパラメーターで呼び出されたことを確認
          verify(
            () => mockAiChatService.sendMessageStream(
              messageText,
              systemPrompt: any<String>(named: 'systemPrompt'),
              conversationHistory: any<List<ChatMessage>?>(
                named: 'conversationHistory',
              ),
            ),
          ).called(1);
        },
      );

      test('メッセージ送信エラー時に適切に処理されること', () {
        const cavivaraId = 'cavivara_default';
        const messageText = 'エラーテスト';

        when(
          () => mockAiChatService.sendMessageStream(
            messageText,
            systemPrompt: any<String>(named: 'systemPrompt'),
            conversationHistory: any<List<ChatMessage>?>(
              named: 'conversationHistory',
            ),
          ),
        ).thenThrow(Exception('AI service error'));

        final notifier = container.read(
          chatMessagesProvider(cavivaraId).notifier,
        );

        // エラーが発生してもメッセージリストが破綻しないことを確認
        expect(
          () => notifier.sendMessage(messageText),
          returnsNormally,
        );

        final messages = container.read(chatMessagesProvider(cavivaraId));

        // ユーザーメッセージとエラーメッセージが追加されていることを確認
        expect(messages, hasLength(2));
        expect(messages[0].content, equals(messageText));
        expect(messages[0].sender, equals(const ChatMessageSender.user()));
        expect(messages[1].content, contains('エラーが発生しました'));
        expect(messages[1].sender, equals(const ChatMessageSender.app()));
      });

      test('ストリーミングレスポンスが部分的に更新されること', () async {
        const cavivaraId = 'cavivara_default';
        const messageText = 'ストリーミングテスト';

        // ストリーミングレスポンスのモック設定
        when(
          () => mockAiChatService.sendMessageStream(
            messageText,
            systemPrompt: any<String>(named: 'systemPrompt'),
            conversationHistory: any<List<ChatMessage>?>(
              named: 'conversationHistory',
            ),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            'AI',
            ' から',
            'の返信',
          ]),
        );

        final notifier = container.read(
          chatMessagesProvider(cavivaraId).notifier,
        );
        await notifier.sendMessage(messageText);

        final messages = container.read(chatMessagesProvider(cavivaraId));

        // 最終的にストリーミングが完了したメッセージが保存されることを確認
        expect(messages, hasLength(2));
        expect(messages[1].content, equals('AI からの返信'));
        expect(messages[1].sender, equals(const ChatMessageSender.ai()));
      });
    });

    group('clearMessages', () {
      test('特定のカヴィヴァラのメッセージのみクリアされること', () async {
        const cavivaraId1 = 'cavivara_default';
        const cavivaraId2 = 'cavivara_mascot';

        // AI サービスのモック設定
        when(
          () => mockAiChatService.sendMessageStream(
            any<String>(),
            systemPrompt: any<String>(named: 'systemPrompt'),
            conversationHistory: any<List<ChatMessage>?>(
              named: 'conversationHistory',
            ),
          ),
        ).thenAnswer((_) => Stream.value('AIからの返信'));

        // 両方のカヴィヴァラにメッセージを追加
        final notifier1 = container.read(
          chatMessagesProvider(cavivaraId1).notifier,
        );
        final notifier2 = container.read(
          chatMessagesProvider(cavivaraId2).notifier,
        );

        await notifier1.sendMessage('メッセージ1');
        await notifier2.sendMessage('メッセージ2');

        // 1つ目のカヴィヴァラのメッセージをクリア
        notifier1.clearMessages();

        final messages1 = container.read(chatMessagesProvider(cavivaraId1));
        final messages2 = container.read(chatMessagesProvider(cavivaraId2));

        // 1つ目だけクリアされ、2つ目は残っていることを確認
        expect(messages1, isEmpty);
        expect(messages2, hasLength(2));
      });
    });
  });
}
