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

  GenerativeModel? _model;

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

  GenerativeModel get _generativeModel {
    return _model ??= FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(
        // TODO(ide): パラメーターの意味を確認
        temperature: 0.7,
        topP: 0.8,
        topK: 40,
        maxOutputTokens: 2048,
      ),
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      _logger.info('チャットメッセージを送信: $message');

      final response = await _generativeModel.generateContent([
        Content.text(_systemPrompt),
        Content.text(message),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw const AiChatException('AIからの応答が空です');
      }

      _logger.info('AIから応答を受信: ${response.text}');
      return response.text!;
    } catch (e, stackTrace) {
      _logger.severe('チャットメッセージの送信に失敗: $e');
      await errorReportService.recordError(e, stackTrace);
      throw AiChatException('チャットメッセージの送信に失敗しました: $e');
    }
  }

  Stream<String> sendMessageStream(String message) async* {
    try {
      _logger.info('ストリーミングチャットメッセージを送信: $message');

      final response = _generativeModel.generateContentStream([
        Content.text(_systemPrompt),
        Content.text(message),
      ]);

      await for (final chunk in response) {
        if (chunk.text != null && chunk.text!.isNotEmpty) {
          yield chunk.text!;
        }
      }
    } catch (e, stackTrace) {
      _logger.severe('ストリーミングチャットメッセージの送信に失敗: $e');
      await errorReportService.recordError(e, stackTrace);
      throw AiChatException('ストリーミングチャットメッセージの送信に失敗しました: $e');
    }
  }

  Future<String> sendConversation(List<ChatMessage> messages) async {
    try {
      _logger.info('会話履歴を含むメッセージを送信: ${messages.length}件');

      final history = [
        Content.text(_systemPrompt),
        ...messages.map((message) {
          return Content.text(message.content);
        }),
      ];

      final response = await _generativeModel.generateContent(history);

      if (response.text == null || response.text!.isEmpty) {
        throw const AiChatException('AIからの応答が空です');
      }

      _logger.info('AIから応答を受信: ${response.text}');
      return response.text!;
    } catch (e, stackTrace) {
      _logger.severe('会話履歴を含むメッセージの送信に失敗: $e');
      await errorReportService.recordError(e, stackTrace);
      throw AiChatException('会話履歴を含むメッセージの送信に失敗しました: $e');
    }
  }
}

class AiChatException implements Exception {
  const AiChatException(this.message);

  final String message;

  @override
  String toString() => 'AiChatException: $message';
}
