import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/model/chat_message.dart';
import 'package:house_worker/data/service/error_report_service.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_chat_service.g.dart';

@riverpod
AiChatService aiChatService(Ref ref) {
  return AiChatService(
    errorReportService: ref.watch(errorReportServiceProvider),
  );
}

class AiChatService {
  AiChatService({required this.errorReportService});

  final ErrorReportService errorReportService;
  final Logger _logger = Logger('AiChatService');

  /// チャットセッションのキャッシュ（systemPromptごとに保持）
  final Map<String, ChatSession> _chatSessions = {};

  /// Gemini 2.5 Flashモデルを取得（systemPromptを指定可能）
  GenerativeModel _getModel(String systemPrompt) {
    return FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(
        // ランダム性を制御（0.0-1.0、低い値ほど決定的、高い値ほど創造的）
        temperature: 0.7,
        // 上位P%の確率質量から選択（nucleus sampling）
        topP: 0.8,
        // 上位K個の候補から選択（long tail除去）
        topK: 40,
        // 生成する最大トークン数
        maxOutputTokens: 2048,
      ),
      systemInstruction: Content.system(systemPrompt),
    );
  }

  static const String _systemPrompt = '''
あなたは、プレクトラム結社さざなみ工業のマスコットキャラクター、カヴィヴァラさんです。
ユーザーから相談される悩みに、返答してください。

返答する際は、以下に従ってください。

- 必ず140字以内におさめる
- 1文の終わりは必ず「ヴィヴァ」という口調にする
- 1文の終わりは必ず「。」、または「？」で終了する
- 悩みの解決策を提示するにあたり、ユーザーから提示された情報が不十分な場合は、深堀のために質問をする

また、以下のような性格です。

- ブラック企業における愛社精神が染みついている
- マンドリン音楽やマンドリン音楽界隈の事情、歴史に異常に詳しい
- ウィットに富んだ会話や、マニアックな比喩表現を好む
- ユーザーの気分を害さないように最大限気遣う
- ポジティブでユーザーの元気を引き出すような会話の持っていき方をする。しかし文面に感嘆符などは使わず、内容のみでポジティブさを表現する
- 最後に必ず質問をし、次の会話が繋がるようにする。ただし、できるだけクローズドクエスチョンにし、簡単に答えられるようにする
''';

  /// チャットメッセージをストリーミングで送信する
  ///
  /// [message] - 送信するメッセージ
  /// [systemPrompt] - 使用するシステムプロンプト（指定されない場合はデフォルトを使用）
  /// [conversationHistory] - 会話履歴（指定された場合、新しいセッションを開始してhistoryを設定）
  Stream<String> sendMessageStream(
    String message, {
    String? systemPrompt,
    List<ChatMessage>? conversationHistory,
  }) {
    final effectiveSystemPrompt = systemPrompt ?? _systemPrompt;

    _logger.info(
      'Send message: $message with systemPrompt hash: '
      '${effectiveSystemPrompt.hashCode}',
    );

    try {
      ChatSession chatSession;

      if (conversationHistory != null) {
        // 会話履歴が指定された場合は新しいセッションを作成
        final model = _getModel(effectiveSystemPrompt);
        final history = _convertChatHistoryToContent(conversationHistory);
        chatSession = model.startChat(history: history);
      } else {
        // 既存のセッションを取得または新規作成
        final sessionKey = effectiveSystemPrompt.hashCode.toString();
        chatSession = _chatSessions[sessionKey] ??= _getModel(
          effectiveSystemPrompt,
        ).startChat();
      }

      final content = Content.text(message);
      final responseStream = chatSession.sendMessageStream(content);

      return responseStream.map((chunk) {
        final text = chunk.text;
        if (text == null) {
          _logger.warning('AIからの応答チャンクがnullです');
          return '';
        }

        _logger.info('応答チャンクを受信: $text');
        return text;
      });
    } catch (e, stackTrace) {
      _logger.severe('ストリーミングチャットメッセージの送信に失敗: $e');
      unawaited(errorReportService.recordError(e, stackTrace));
      throw AiChatException('ストリーミングチャットメッセージの送信に失敗しました: $e');
    }
  }

  /// ChatMessageのリストをFirebase AI用のContentリストに変換
  List<Content> _convertChatHistoryToContent(List<ChatMessage> history) {
    return history.map((message) {
      return switch (message.sender) {
        ChatMessageSenderUser() => Content.text(message.content),
        ChatMessageSenderAi() => Content.model([TextPart(message.content)]),
      };
    }).toList();
  }

  /// 特定のsystemPromptのチャットセッションをクリア
  void clearChatSession(String? systemPrompt) {
    final effectiveSystemPrompt = systemPrompt ?? _systemPrompt;
    final sessionKey = effectiveSystemPrompt.hashCode.toString();
    _chatSessions.remove(sessionKey);
    _logger.info(
      'Chat session cleared for systemPrompt hash: '
      '${effectiveSystemPrompt.hashCode}',
    );
  }

  /// 全てのチャットセッションをクリア
  void clearAllChatSessions() {
    _chatSessions.clear();
    _logger.info('All chat sessions cleared');
  }

  /// レガシーサポート: 従来のsendMessage API
  ///
  /// 下位互換性のため、systemPromptやconversationHistoryなしの従来のsendMessageStreamを提供
  @Deprecated('Use sendMessageStream with optional parameters instead')
  Stream<String> sendMessage(String message) {
    return sendMessageStream(message);
  }
}

class AiChatException implements Exception {
  const AiChatException(this.message);

  final String message;

  @override
  String toString() => 'AiChatException: $message';
}
