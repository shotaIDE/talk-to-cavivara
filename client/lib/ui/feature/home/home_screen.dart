import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/model/chat_message.dart';
import 'package:house_worker/ui/feature/home/home_presenter.dart';
import 'package:house_worker/ui/feature/settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const name = 'HomeScreen';

  static MaterialPageRoute<HomeScreen> route() => MaterialPageRoute<HomeScreen>(
    builder: (_) => const HomeScreen(),
    settings: const RouteSettings(name: name),
  );

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const title = Text('AI チャット');

    final settingsButton = IconButton(
      onPressed: () {
        Navigator.of(context).push(SettingsScreen.route());
      },
      tooltip: '設定を表示する',
      icon: const Icon(Icons.settings),
    );

    final clearButton = IconButton(
      onPressed: _clearChat,
      tooltip: 'チャット履歴をクリアする',
      icon: const Icon(Icons.clear_all),
    );

    final body = Column(
      children: [
        const Expanded(child: _ChatMessageList()),
        _messageInput(),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [clearButton, settingsButton],
      ),
      body: body,
    );
  }

  void _clearChat() {
    ref.read(chatMessagesProvider.notifier).clearMessages();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      ref.read(chatMessagesProvider.notifier).sendMessage(message);
      _messageController.clear();

      // 新しいメッセージが追加された後にスクロール
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Widget _messageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16 + MediaQuery.of(context).viewPadding.left,
        right: 16 + MediaQuery.of(context).viewPadding.right,
        bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'メッセージを入力...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            tooltip: 'メッセージを送信',
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageList extends ConsumerWidget {
  const _ChatMessageList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider);

    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'AIとチャットを始めましょう！\n下のテキストフィールドにメッセージを入力してください。',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        left: 16 + MediaQuery.of(context).viewPadding.left,
        right: 16 + MediaQuery.of(context).viewPadding.right,
        top: 16,
        bottom: 8,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ChatBubble(message: message),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == const ChatMessageSender.user();

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isUser
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${message.timestamp.hour.toString().padLeft(2, '0')}:'
            '${message.timestamp.minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isUser
                  ? Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.7)
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );

    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [bubble],
    );
  }
}
