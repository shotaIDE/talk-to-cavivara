import 'package:flutter/material.dart';

class FireConfirmationDialog extends StatelessWidget {
  const FireConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('解雇しますか？'),
      content: const Text('解雇すると、再度雇用するまで会議できなくなります。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            '解雇する',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}
