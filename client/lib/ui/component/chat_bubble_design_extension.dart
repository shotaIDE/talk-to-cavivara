import 'package:flutter/material.dart';
import 'package:house_worker/data/model/chat_bubble_design.dart';
import 'package:house_worker/ui/component/harmonized_bubble_clipper.dart';

enum MessageType {
  user, // ユーザーメッセージ
  ai, // AIメッセージ
  system, // システムメッセージ
}

extension ChatBubbleDesignExtension on ChatBubbleDesign {
  BorderRadius borderRadiusForMessageType(MessageType messageType) {
    switch (this) {
      case ChatBubbleDesign.corporateStandard:
        return BorderRadius.circular(8);
      case ChatBubbleDesign.nextGeneration:
        switch (messageType) {
          case MessageType.user:
            return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(2), // ツノがあった位置
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            );
          case MessageType.ai:
            return const BorderRadius.only(
              topLeft: Radius.circular(2), // ツノがあった位置
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            );
          case MessageType.system:
            return BorderRadius.circular(8);
        }
      case ChatBubbleDesign.harmonized:
        // harmonized uses CustomClipper, not BorderRadius
        return BorderRadius.zero;
    }
  }

  String get displayName {
    switch (this) {
      case ChatBubbleDesign.corporateStandard:
        return '社内標準様式';
      case ChatBubbleDesign.nextGeneration:
        return '次世代様式';
      case ChatBubbleDesign.harmonized:
        return '調整済様式';
    }
  }

  Widget bubble({
    required BuildContext context,
    required MessageType messageType,
    required String text,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return bubbleWithChild(
      context: context,
      messageType: messageType,
      backgroundColor: backgroundColor,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: textColor,
        ),
      ),
    );
  }

  Widget bubbleWithChild({
    required BuildContext context,
    required MessageType messageType,
    required Widget child,
    required Color backgroundColor,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  }) {
    if (this == ChatBubbleDesign.harmonized) {
      return ClipPath(
        clipper: HarmonizedBubbleClipper(
          messageType: messageType,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: padding,
          color: backgroundColor,
          child: child,
        ),
      );
    } else {
      return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadiusForMessageType(messageType),
        ),
        child: child,
      );
    }
  }
}
