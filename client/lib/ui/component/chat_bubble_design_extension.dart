import 'package:flutter/material.dart';
import 'package:house_worker/data/model/chat_bubble_design.dart';

enum MessageType {
  user, // ユーザーメッセージ
  ai, // AIメッセージ
  system, // システムメッセージ
}

extension ChatBubbleDesignExtension on ChatBubbleDesign {
  BorderRadius get borderRadius {
    switch (this) {
      case ChatBubbleDesign.square:
        return BorderRadius.circular(2);
      case ChatBubbleDesign.rounded:
        return BorderRadius.circular(16);
    }
  }

  BorderRadius borderRadiusForMessageType(MessageType messageType) {
    switch (this) {
      case ChatBubbleDesign.square:
        return BorderRadius.circular(8);
      case ChatBubbleDesign.rounded:
        switch (messageType) {
          case MessageType.user:
            return const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(2), // ツノがあった位置
              bottomRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            );
          case MessageType.ai:
            return const BorderRadius.only(
              topLeft: Radius.circular(2), // ツノがあった位置
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            );
          case MessageType.system:
            return BorderRadius.circular(8);
        }
    }
  }

  String get displayName {
    switch (this) {
      case ChatBubbleDesign.square:
        return '社内標準様式';
      case ChatBubbleDesign.rounded:
        return '次世代様式';
    }
  }
}
