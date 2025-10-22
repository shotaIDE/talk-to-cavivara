import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/data/model/chat_bubble_design.dart';
import 'package:house_worker/ui/component/chat_bubble_design_extension.dart';

void main() {
  group('borderRadiusForMessageType', () {
    test(
      'corporateStandard design returns uniform small radius '
      'for all message types',
      () {
        const design = ChatBubbleDesign.corporateStandard;
        expect(
          design.borderRadiusForMessageType(MessageType.user),
          BorderRadius.circular(8),
        );
        expect(
          design.borderRadiusForMessageType(MessageType.ai),
          BorderRadius.circular(8),
        );
        expect(
          design.borderRadiusForMessageType(MessageType.system),
          BorderRadius.circular(8),
        );
      },
    );

    test('nextGeneration design returns custom radius for user message', () {
      const design = ChatBubbleDesign.nextGeneration;
      final result = design.borderRadiusForMessageType(MessageType.user);
      expect(result.topLeft, const Radius.circular(20));
      expect(result.topRight, const Radius.circular(2));
      expect(result.bottomRight, const Radius.circular(20));
      expect(result.bottomLeft, const Radius.circular(20));
    });

    test('nextGeneration design returns custom radius for ai message', () {
      const design = ChatBubbleDesign.nextGeneration;
      final result = design.borderRadiusForMessageType(MessageType.ai);
      expect(result.topLeft, const Radius.circular(2));
      expect(result.topRight, const Radius.circular(20));
      expect(result.bottomRight, const Radius.circular(20));
      expect(result.bottomLeft, const Radius.circular(20));
    });

    test('nextGeneration design returns uniform radius for system message', () {
      const design = ChatBubbleDesign.nextGeneration;
      final result = design.borderRadiusForMessageType(MessageType.system);
      expect(result, BorderRadius.circular(8));
    });
  });

  group('harmonized design', () {
    test('displayName returns correct Japanese name', () {
      const design = ChatBubbleDesign.harmonized;
      expect(design.displayName, '調整済様式');
    });
  });
}
