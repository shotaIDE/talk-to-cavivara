import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
    generationConfig: GenerationConfig(
      // TODO(ide): パラメーターの意味を確認
      temperature: 0.7,
      topP: 0.8,
      topK: 40,
      maxOutputTokens: 2048,
    ),
    systemInstruction: Content.system(_systemPrompt),
  );
  ChatSession? _chatSession;

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

  Stream<String> sendMessageStream(String message) {
    final chatSession = _chatSession ??= _model.startChat();

    _logger.info('Send message: $message');

    try {
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
}

class AiChatException implements Exception {
  const AiChatException(this.message);

  final String message;

  @override
  String toString() => 'AiChatException: $message';
}
