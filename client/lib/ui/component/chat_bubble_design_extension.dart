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
        return BorderRadius.circular(2);
      case ChatBubbleDesign.rounded:
        switch (messageType) {
          case MessageType.user:
            return const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(4), // ツノがあった位置
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            );
          case MessageType.ai:
            return const BorderRadius.only(
              topLeft: Radius.circular(4), // ツノがあった位置
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            );
          case MessageType.system:
            return BorderRadius.circular(10);
        }
    }
  }

  String get displayName {
    switch (this) {
      case ChatBubbleDesign.square:
        return '四角';
      case ChatBubbleDesign.rounded:
        return '角削り';
    }
  }
}
