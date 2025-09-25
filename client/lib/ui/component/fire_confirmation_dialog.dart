import 'package:flutter/material.dart';

class FireConfirmationDialog extends StatelessWidget {
  const FireConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('解雇しますか？'),
      content: const Text('本当に解雇すると、再度雇用するまで相談できなくなります。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('解雇する'),
        ),
      ],
    );
  }
}
