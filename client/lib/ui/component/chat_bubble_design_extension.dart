import 'package:flutter/material.dart';
import 'package:house_worker/data/model/chat_bubble_design.dart';
import 'package:house_worker/ui/component/harmonized_bubble_clipper.dart';

enum MessageType {
  user, // ユーザーメッセージ
  ai, // AIメッセージ
  system, // システムメッセージ
}

extension ChatBubbleDesignExtension on ChatBubbleDesign {
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

  bool get shouldWithPointer {
    switch (this) {
      case ChatBubbleDesign.corporateStandard:
        return true;
      case ChatBubbleDesign.nextGeneration:
        return false;
      case ChatBubbleDesign.harmonized:
        return false;
    }
  }

  Widget buildBubble({
    required BuildContext context,
    required MessageType messageType,
    required Color backgroundColor,
    required Widget child,
  }) {
    const padding = EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    );
    final constraints = BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.8,
    );

    switch (this) {
      case ChatBubbleDesign.corporateStandard:
        return Container(
          constraints: constraints,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        );

      case ChatBubbleDesign.nextGeneration:
        final BorderRadius borderRadius;
        switch (messageType) {
          case MessageType.user:
            borderRadius = const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(2), // ツノがあった位置
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            );
          case MessageType.ai:
            borderRadius = const BorderRadius.only(
              topLeft: Radius.circular(2), // ツノがあった位置
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            );
          case MessageType.system:
            borderRadius = BorderRadius.circular(8);
        }

        return Container(
          constraints: constraints,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: child,
        );

      case ChatBubbleDesign.harmonized:
        return ClipPath(
          clipper: HarmonizedBubbleClipper(
            messageType: messageType,
          ),
          child: Container(
            constraints: constraints,
            padding: padding,
            color: backgroundColor,
            child: child,
          ),
        );
    }
  }
}
