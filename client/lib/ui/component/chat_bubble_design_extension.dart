import 'package:flutter/material.dart';
import 'package:house_worker/data/model/chat_bubble_design.dart';

extension ChatBubbleDesignExtension on ChatBubbleDesign {
  BorderRadius get borderRadius {
    switch (this) {
      case ChatBubbleDesign.square:
        return BorderRadius.circular(2);
      case ChatBubbleDesign.rounded:
        return BorderRadius.circular(16);
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
