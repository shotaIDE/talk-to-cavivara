import 'package:flutter/material.dart';
import 'package:house_worker/ui/component/chat_bubble_design_extension.dart';

class HarmonizedBubbleClipper extends CustomClipper<Path> {
  const HarmonizedBubbleClipper({
    required this.messageType,
    this.cutSize = 10.0,
  });

  final MessageType messageType;
  final double cutSize;

  @override
  Path getClip(Size size) {
    final path = Path();

    switch (messageType) {
      case MessageType.user:
        // 7角形、右上の角を残す
        path.moveTo(cutSize, 0); // 1. 左上の削り終わり
        path.lineTo(size.width, 0); // 2. 右上（角を残す）
        path.lineTo(size.width, size.height - cutSize); // 3. 右下の削り始め
        path.lineTo(size.width - cutSize, size.height); // 4. 右下の削り終わり
        path.lineTo(cutSize, size.height); // 5. 左下の削り始め
        path.lineTo(0, size.height - cutSize); // 6. 左下の削り終わり
        path.lineTo(0, cutSize); // 7. 左上の削り始め
        path.close();

      case MessageType.ai:
        // 7角形、左上の角を残す
        path.moveTo(0, 0); // 1. 左上（角を残す）
        path.lineTo(size.width - cutSize, 0); // 2. 右上の削り始め
        path.lineTo(size.width, cutSize); // 3. 右上の削り終わり
        path.lineTo(size.width, size.height - cutSize); // 4. 右下の削り始め
        path.lineTo(size.width - cutSize, size.height); // 5. 右下の削り終わり
        path.lineTo(cutSize, size.height); // 6. 左下の削り始め
        path.lineTo(0, size.height - cutSize); // 7. 左下の削り終わり
        path.close();

      case MessageType.system:
        // 6角形、左右の中央に角
        path.moveTo(cutSize, 0); // 1. 左上の削り終わり
        path.lineTo(size.width - cutSize, 0); // 2. 右上の削り始め
        path.lineTo(size.width, cutSize); // 3. 右上の削り終わり（角）
        path.lineTo(size.width, size.height - cutSize); // 4. 右下の削り始め
        path.lineTo(size.width - cutSize, size.height); // 5. 右下の削り終わり
        path.lineTo(cutSize, size.height); // 6. 左下の削り始め
        path.lineTo(0, size.height - cutSize); // 7. 左下の削り終わり
        path.lineTo(0, cutSize); // 8. 左上の削り始め（角）
        path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
