import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/models/task.dart';
import 'package:house_worker/repositories/task_repository.dart';
import 'package:house_worker/services/auth_service.dart';
import 'package:intl/intl.dart';

// ランダムな絵文字を生成するためのリスト
const List<String> _emojiList = [
  '🧹',
  '🧼',
  '🧽',
  '🧺',
  '🛁',
  '🚿',
  '🚽',
  '🧻',
  '🧯',
  '🔥',
  '💧',
  '🌊',
  '🍽️',
  '🍴',
  '🥄',
  '🍳',
  '🥘',
  '🍲',
  '🥣',
  '🥗',
  '🧂',
  '🧊',
  '🧴',
  '🧷',
  '🧺',
  '🧹',
  '🧻',
  '🧼',
  '🧽',
  '🧾',
  '📱',
  '💻',
  '🖥️',
  '🖨️',
  '⌨️',
  '🖱️',
  '🧮',
  '📔',
  '📕',
  '📖',
  '📗',
  '📘',
  '📙',
  '📚',
  '📓',
  '📒',
  '📃',
  '📜',
  '📄',
  '📰',
];

// ランダムな絵文字を取得する関数
String getRandomEmoji() {
  final random = Random();
  return _emojiList[random.nextInt(_emojiList.length)];
}

class TaskLogAddScreen extends ConsumerStatefulWidget {
  final Task? existingTask;

  const TaskLogAddScreen({super.key, this.existingTask});

  // 既存のタスクから新しいタスクを作成するためのファクトリコンストラクタ
  factory TaskLogAddScreen.fromExistingTask(Task task) {
    return TaskLogAddScreen(existingTask: task);
  }

  @override
  ConsumerState<TaskLogAddScreen> createState() => _TaskLogAddScreenState();
}

class _TaskLogAddScreenState extends ConsumerState<TaskLogAddScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _iconController;

  late DateTime _completedAt;

  @override
  void initState() {
    super.initState();
    // 既存のタスクがある場合は、そのデータを初期値として設定
    if (widget.existingTask != null) {
      _titleController = TextEditingController(
        text: widget.existingTask!.title,
      );
      _iconController = TextEditingController(text: widget.existingTask!.icon);
      _completedAt = DateTime.now(); // 現在時刻を設定
    } else {
      _titleController = TextEditingController();
      // 新規作成時はランダムな絵文字を初期値として設定
      _iconController = TextEditingController(text: getRandomEmoji());
      _completedAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authServiceProvider).currentUser;
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask != null ? '家事ログを記録' : '家事ログ追加'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 家事ログの名前入力欄
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '家事ログの名前',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '家事ログの名前を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 家事ログのアイコン入力欄
              TextFormField(
                controller: _iconController,
                decoration: const InputDecoration(
                  labelText: '家事ログのアイコン',
                  border: OutlineInputBorder(),
                  hintText: '絵文字1文字を入力',
                ),
                maxLength: 1, // 1文字のみ入力可能
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'アイコンを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 家事ログの完了時刻入力欄
              ListTile(
                title: const Text('完了時刻'),
                subtitle: Text(dateFormat.format(_completedAt)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 16),

              // 家事ログの実行したユーザー表示
              ListTile(
                title: const Text('実行したユーザー'),
                subtitle: Text(currentUser?.displayName ?? 'ゲスト'),
                leading: const Icon(Icons.person),
              ),
              const SizedBox(height: 24),

              // 登録ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '家事ログを登録する',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _completedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      // BuildContextをローカル変数に保存して、マウント状態を確認した後に使用
      final TimeOfDay? pickedTime = await showTimePicker(
        context: mounted ? context : throw StateError('Widget is not mounted'),
        initialTime: TimeOfDay.fromDateTime(_completedAt),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _completedAt = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final taskRepository = ref.read(taskRepositoryProvider);
      final currentUser = ref.read(authServiceProvider).currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ユーザー情報が取得できませんでした')));
        return;
      }

      // 既存のタスクを元にした場合でも、常に新規タスクとして登録するためIDは空文字列を指定
      final task = Task(
        id: '', // 常に新規タスクとして登録するため空文字列を指定
        title: _titleController.text,
        icon: _iconController.text, // アイコンを設定
        createdAt: DateTime.now(),
        completedAt: _completedAt,
        createdBy: currentUser.uid,
        completedBy: currentUser.uid,
        isShared: true, // デフォルトで共有
        isRecurring: false, // 家事ログは繰り返しなし
        isCompleted: true, // 家事ログは完了済み
      );

      try {
        // タスクを保存
        taskRepository.save(task);

        // 保存成功メッセージを表示
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('家事ログを登録しました')));

          // 一覧画面に戻る（更新フラグをtrueにして渡す）
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        // エラー時の処理
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラーが発生しました: ${e.toString()}')),
          );
        }
      }
    }
  }
}
