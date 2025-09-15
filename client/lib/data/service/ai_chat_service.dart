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

  GenerativeModel get _generativeModel {
    return _model ??= FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.0-flash',
      generationConfig: GenerationConfig(
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

      final history = messages.map((message) {
        return Content.text(message.content);
      }).toList();

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
