import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/ui/component/chat_bubble_design_extension.dart';
import 'package:house_worker/ui/component/harmonized_bubble_clipper.dart';

void main() {
  group('HarmonizedBubbleClipper', () {
    test('user message creates 7-point path', () {
      const clipper = HarmonizedBubbleClipper(
        messageType: MessageType.user,
      );
      final path = clipper.getClip(const Size(100, 100));

      expect(path, isNotNull);
    });

    test('ai message creates 7-point path', () {
      const clipper = HarmonizedBubbleClipper(
        messageType: MessageType.ai,
      );
      final path = clipper.getClip(const Size(100, 100));

      expect(path, isNotNull);
    });

    test('system message creates 6-point path', () {
      const clipper = HarmonizedBubbleClipper(
        messageType: MessageType.system,
      );
      final path = clipper.getClip(const Size(100, 100));

      expect(path, isNotNull);
    });

    test('shouldReclip returns false', () {
      const clipper = HarmonizedBubbleClipper(
        messageType: MessageType.user,
      );
      const oldClipper = HarmonizedBubbleClipper(
        messageType: MessageType.ai,
      );

      expect(clipper.shouldReclip(oldClipper), isFalse);
    });
  });
}
