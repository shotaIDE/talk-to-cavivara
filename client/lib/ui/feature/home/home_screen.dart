import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/model/chat_message.dart';
import 'package:house_worker/data/service/cavivara_directory_service.dart';
import 'package:house_worker/ui/component/app_drawer.dart';
import 'package:house_worker/ui/component/cavivara_avatar.dart';
import 'package:house_worker/ui/feature/home/home_presenter.dart';
import 'package:house_worker/ui/feature/job_market/job_market_screen.dart';
import 'package:house_worker/ui/feature/resume/resume_screen.dart';
import 'package:house_worker/ui/feature/settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.cavivaraId});

  static const defaultCavivaraId = 'cavivara_default';

  /// 対象のカヴィヴァラID
  final String cavivaraId;

  static const name = 'HomeScreen';

  static MaterialPageRoute<HomeScreen> route(String cavivaraId) =>
      MaterialPageRoute<HomeScreen>(
        builder: (_) => HomeScreen(cavivaraId: cavivaraId),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    unawaited(
      ref.read(updateLastTalkedCavivaraIdProvider(widget.cavivaraId).future),
    );
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cavivaraId != widget.cavivaraId) {
      unawaited(
        ref.read(updateLastTalkedCavivaraIdProvider(widget.cavivaraId).future),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cavivaraProfile = ref.watch(cavivaraByIdProvider(widget.cavivaraId));

    final title = Row(
      children: [
        CavivaraAvatar(
          size: 32,
          assetPath: cavivaraProfile.iconPath,
          cavivaraId: widget.cavivaraId,
          onTap: () => Navigator.of(context).push(
            ResumeScreen.route(widget.cavivaraId),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            cavivaraProfile.displayName,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );

    final clearButton = IconButton(
      onPressed: _clearChat,
      tooltip: 'チャット履歴をクリアする',
      icon: const Icon(Icons.clear_all),
    );

    final body = Column(
      children: [
        Expanded(
          child: _ChatMessageList(
            controller: _scrollController,
            onMessageSent: _onMessageSent,
            cavivaraId: widget.cavivaraId,
          ),
        ),
        _messageInput(),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [clearButton],
      ),
      drawer: AppDrawer(
        isTalkSelected: true,
        isJobMarketSelected: false,
        onSelectTalk: () {
          Navigator.of(context).pushAndRemoveUntil(
            HomeScreen.route(widget.cavivaraId),
            (route) => false,
          );
        },
        onSelectJobMarket: () {
          Navigator.of(context).pushAndRemoveUntil(
            JobMarketScreen.route(),
            (route) => false,
          );
        },
        onSelectSettings: () {
          Navigator.of(context).push(SettingsScreen.route());
        },
      ),
      body: body,
    );
  }

  void _clearChat() {
    ref.read(chatMessagesProvider(widget.cavivaraId).notifier).clearMessages();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      ref
          .read(chatMessagesProvider(widget.cavivaraId).notifier)
          .sendMessage(message);
      _messageController.clear();
    }
  }

  void _onMessageSent() {
    // メッセージ送信後の処理をここで行う（必要に応じて）
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
              textInputAction: TextInputAction.newline,
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

class _ChatMessageList extends ConsumerStatefulWidget {
  const _ChatMessageList({
    required this.controller,
    required this.onMessageSent,
    required this.cavivaraId,
  });

  final ScrollController controller;
  final VoidCallback onMessageSent;
  final String cavivaraId;

  @override
  ConsumerState<_ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends ConsumerState<_ChatMessageList> {
  bool _isAtBottom = true;
  int _previousMessageCount = 0;
  bool _previousHasStreamingMessages = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.hasClients) {
      return;
    }

    final maxScrollExtent = widget.controller.position.maxScrollExtent;
    final currentPosition = widget.controller.position.pixels;
    const threshold = 100.0; // 100px以内なら「最下部」とみなす

    _isAtBottom = (maxScrollExtent - currentPosition) <= threshold;
  }

  void _scrollToBottom() {
    if (!widget.controller.hasClients) {
      return;
    }

    widget.controller.animateTo(
      widget.controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.cavivaraId));
    final hasStreamingMessages = messages.any(
      (ChatMessage message) => message.isStreaming,
    );

    // メッセージ数が増えた場合、またはストリーミングが終了した場合で、ユーザーが最下部にいる場合のみ自動スクロール
    final shouldAutoScroll =
        _isAtBottom &&
        (messages.length > _previousMessageCount ||
            (_previousHasStreamingMessages && !hasStreamingMessages));

    if (shouldAutoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    _previousMessageCount = messages.length;
    _previousHasStreamingMessages = hasStreamingMessages;

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
      controller: widget.controller,
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
          child: _ChatBubble(
            message: message,
            cavivaraId: widget.cavivaraId,
          ),
        );
      },
    );
  }
}

class _ChatBubble extends ConsumerWidget {
  const _ChatBubble({
    required this.message,
    required this.cavivaraId,
  });

  final ChatMessage message;
  final String cavivaraId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cavivaraProfile = ref.watch(cavivaraByIdProvider(cavivaraId));
    final isUser = message.sender == const ChatMessageSender.user();
    final isStreaming = message.isStreaming;
    final theme = Theme.of(context);
    final textColor = isUser
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final indicatorColor = isUser
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.primary;

    Widget messageContent;
    if (isStreaming && message.content.isEmpty) {
      messageContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${cavivaraProfile.displayName}が考え中…',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
            ),
          ),
        ],
      );
    } else {
      final textWidget = Text(
        message.content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
        ),
      );

      if (isStreaming) {
        messageContent = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: textWidget),
            const SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              ),
            ),
          ],
        );
      } else {
        messageContent = textWidget;
      }
    }

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          messageContent,
          if (!isStreaming || message.content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:'
              '${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isUser
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          CavivaraAvatar(
            assetPath: cavivaraProfile.iconPath,
            cavivaraId: cavivaraId,
            onTap: () => Navigator.of(context).push(
              ResumeScreen.route(cavivaraId),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(child: bubble),
      ],
    );
  }
}
