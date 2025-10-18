import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/model/chat_bubble_design.dart';
import 'package:house_worker/data/repository/chat_bubble_design_repository.dart';
import 'package:house_worker/ui/component/chat_bubble_design_extension.dart';

class ChatBubbleDesignSelectionDialog extends ConsumerStatefulWidget {
  const ChatBubbleDesignSelectionDialog({super.key});

  @override
  ConsumerState<ChatBubbleDesignSelectionDialog> createState() =>
      _ChatBubbleDesignSelectionDialogState();
}

class _ChatBubbleDesignSelectionDialogState
    extends ConsumerState<ChatBubbleDesignSelectionDialog> {
  ChatBubbleDesign? _selectedDesign;

  @override
  void initState() {
    super.initState();
    // 初期値として現在のデザインを設定
    final currentDesign = ref.read(chatBubbleDesignRepositoryProvider).value;
    _selectedDesign = currentDesign ?? ChatBubbleDesign.square;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('吹き出しデザイン'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: ChatBubbleDesign.values.map((design) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Radio<ChatBubbleDesign>(
              value: design,
              groupValue: _selectedDesign,
              onChanged: (value) {
                setState(() {
                  _selectedDesign = value;
                });
              },
            ),
            title: Text(design.displayName),
            subtitle: _DesignPreview(design: design),
            onTap: () {
              setState(() {
                _selectedDesign = design;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () async {
            if (_selectedDesign != null) {
              await ref
                  .read(chatBubbleDesignRepositoryProvider.notifier)
                  .save(_selectedDesign!);
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _DesignPreview extends StatelessWidget {
  const _DesignPreview({
    required this.design,
  });

  final ChatBubbleDesign design;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: design.borderRadius,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 80,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: design.borderRadius,
            ),
          ),
        ],
      ),
    );
  }
}
