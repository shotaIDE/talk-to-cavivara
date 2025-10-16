# チャット吹き出しデザイン切り替え機能 技術設計書

## 概要

チャット画面の吹き出し形状を動的に変更する機能の技術的な実装設計。

## アーキテクチャ

### レイヤー構成

```
┌─────────────────────────────────────┐
│ UI Layer                            │
│ - HomeScreen (吹き出しウィジェット)  │
│ - SettingsScreen (設定UI)           │
│ - ChatBubbleDesignSelectionDialog   │
└─────────────────────────────────────┘
              ↓ ref.watch
┌─────────────────────────────────────┐
│ Repository Layer                    │
│ - ChatBubbleDesignRepository        │
└─────────────────────────────────────┘
              ↓ read/write
┌─────────────────────────────────────┐
│ Data Layer                          │
│ - SharedPreferences                 │
└─────────────────────────────────────┘
```

## 主要コンポーネント

### 1. ChatBubbleDesign (Model)

**ファイル**: `client/lib/data/model/chat_bubble_design.dart`

```dart
enum ChatBubbleDesign {
  square,   // 四角デザイン
  rounded;  // 角削りデザイン

  BorderRadius get borderRadius {
    return switch (this) {
      ChatBubbleDesign.square => BorderRadius.circular(2),
      ChatBubbleDesign.rounded => BorderRadius.circular(16),
    };
  }

  String get displayName {
    return switch (this) {
      ChatBubbleDesign.square => '四角',
      ChatBubbleDesign.rounded => '角削り',
    };
  }
}
```

**責務**:

- デザインタイプの定義
- 各デザインに対応する `BorderRadius` を提供
- UI 表示用の名前を提供

### 2. ChatBubbleDesignRepository (Repository)

**ファイル**: `client/lib/data/repository/chat_bubble_design_repository.dart`

```dart
@riverpod
class ChatBubbleDesignRepository extends _$ChatBubbleDesignRepository {
  @override
  Future<ChatBubbleDesign> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString(PreferenceKey.chatBubbleDesign.name);

    if (savedValue == null) {
      return ChatBubbleDesign.square;  // デフォルト
    }

    return ChatBubbleDesign.values.firstWhere(
      (e) => e.name == savedValue,
      orElse: () => ChatBubbleDesign.square,
    );
  }

  Future<void> save(ChatBubbleDesign design) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKey.chatBubbleDesign.name, design.name);
    state = AsyncValue.data(design);
  }
}
```

**責務**:

- SharedPreferences からデザイン設定を読み込み
- デザイン設定を保存
- Riverpod を通じて UI に状態を提供

### 3. PreferenceKey の拡張

**ファイル**: `client/lib/data/model/preference_key.dart`

```dart
enum PreferenceKey {
  // ... 既存のキー
  chatBubbleDesign,  // 追加
}
```

**保存形式**:

- キー: `"chatBubbleDesign"`
- 値: `"square"` または `"rounded"` (enum の name)

### 4. HomeScreen の吹き出しウィジェット

**ファイル**: `client/lib/ui/feature/home/home_screen.dart`

#### 変更箇所

##### \_UserChatBubble (538 行目付近)

```dart
@override
Widget build(BuildContext context) {
  final design = ref.watch(chatBubbleDesignRepositoryProvider).valueOrNull
    ?? ChatBubbleDesign.square;

  // ... 既存のコード ...

  final bubble = Container(
    // ... 既存のコード ...
    decoration: BoxDecoration(
      color: bubbleColor,
      borderRadius: design.borderRadius,  // 動的に変更
    ),
    child: bodyText,
  );

  // ... 既存のコード ...
}
```

##### \_AiChatBubble (644 行目付近)

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final design = ref.watch(chatBubbleDesignRepositoryProvider).valueOrNull
    ?? ChatBubbleDesign.square;

  // ... 既存のコード ...

  final bubble = Container(
    // ... 既存のコード ...
    decoration: BoxDecoration(
      color: bubbleColor,
      borderRadius: design.borderRadius,  // 動的に変更
    ),
    child: bodyText,
  );

  // ... 既存のコード ...
}
```

##### \_AppChatBubble (719 行目付近)

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final design = ref.watch(chatBubbleDesignRepositoryProvider).valueOrNull
    ?? ChatBubbleDesign.square;

  // ... 既存のコード ...

  final bubble = Container(
    // ... 既存のコード ...
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(100),
      borderRadius: design.borderRadius,  // 動的に変更
    ),
    child: bodyText,
  );

  // ... 既存のコード ...
}
```

### 5. ChatBubbleDesignSelectionDialog

**ファイル**: `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart`

```dart
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
    _selectedDesign = ref.read(chatBubbleDesignRepositoryProvider).valueOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('吹き出しデザインの選択'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final design in ChatBubbleDesign.values)
            RadioListTile<ChatBubbleDesign>(
              title: Text(design.displayName),
              subtitle: _buildPreview(design),
              value: design,
              groupValue: _selectedDesign,
              onChanged: (value) {
                setState(() {
                  _selectedDesign = value;
                });
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
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
              Navigator.pop(context);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildPreview(ChatBubbleDesign design) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: design.borderRadius,
      ),
      child: Text(
        'サンプル',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
```

### 6. SettingsScreen の更新

**ファイル**: `client/lib/ui/feature/settings/settings_screen.dart`

```dart
// ListView の children に追加
const SectionHeader(title: '表示設定'),
_buildChatBubbleDesignTile(context, ref),
const Divider(),

// メソッドを追加
Widget _buildChatBubbleDesignTile(BuildContext context, WidgetRef ref) {
  final designAsync = ref.watch(chatBubbleDesignRepositoryProvider);
  final design = designAsync.valueOrNull ?? ChatBubbleDesign.square;

  return ListTile(
    leading: const Icon(Icons.chat_bubble_outline),
    title: const Text('吹き出しデザイン'),
    subtitle: Text(design.displayName),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {
      showDialog<void>(
        context: context,
        builder: (_) => const ChatBubbleDesignSelectionDialog(),
      );
    },
  );
}
```

## データフロー

### 起動時のフロー

```
1. アプリ起動
   ↓
2. ChatBubbleDesignRepository.build() が呼ばれる
   ↓
3. SharedPreferences から値を読み込み
   ↓
4. 値が存在しない → ChatBubbleDesign.square を返す
   値が存在する → 対応する enum 値を返す
   ↓
5. HomeScreen の各吹き出しウィジェットが ref.watch で値を取得
   ↓
6. design.borderRadius を BoxDecoration に適用
```

### デザイン変更時のフロー

```
1. ユーザーが設定画面の「吹き出しデザイン」をタップ
   ↓
2. ChatBubbleDesignSelectionDialog を表示
   ↓
3. ユーザーがデザインを選択して「OK」をタップ
   ↓
4. ChatBubbleDesignRepository.save(design) を呼び出し
   ↓
5. SharedPreferences に値を保存
   ↓
6. state を更新 (AsyncValue.data(design))
   ↓
7. ref.watch している全ウィジェットが自動的に再ビルド
   ↓
8. 新しい borderRadius が適用される
```

## 影響範囲

### 新規作成ファイル

- `client/lib/data/model/chat_bubble_design.dart`
- `client/lib/data/repository/chat_bubble_design_repository.dart`
- `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart`

### 変更ファイル

- `client/lib/data/model/preference_key.dart` (enum に 1 行追加)
- `client/lib/ui/feature/home/home_screen.dart` (3 箇所の吹き出しウィジェット)
- `client/lib/ui/feature/settings/settings_screen.dart` (UI 追加)

### 変更対象のウィジェット

| ウィジェット      | 行番号 | 変更内容                                           |
| ----------------- | ------ | -------------------------------------------------- |
| `_UserChatBubble` | 538    | `BorderRadius.circular(2)` → `design.borderRadius` |
| `_AiChatBubble`   | 644    | `BorderRadius.circular(2)` → `design.borderRadius` |
| `_AppChatBubble`  | 719    | `BorderRadius.circular(2)` → `design.borderRadius` |

## 実装手順

### Phase 1: モデルとリポジトリ

1. `ChatBubbleDesign` enum を作成
2. `PreferenceKey` に `chatBubbleDesign` を追加
3. `ChatBubbleDesignRepository` を実装
4. リポジトリの単体テストを作成

### Phase 2: UI 実装

5. `ChatBubbleDesignSelectionDialog` を実装
6. `SettingsScreen` に UI を追加
7. ダイアログのウィジェットテストを作成

### Phase 3: チャット画面の更新

8. `_UserChatBubble` を更新
9. `_AiChatBubble` を更新
10. `_AppChatBubble` を更新

### Phase 4: テストと仕上げ

11. `dart format` でフォーマット
12. `dart fix --apply` で linter 自動修正
13. 全テストの実行と確認
14. 手動での動作確認

## 非機能要件の実装方針

### NFR-1: パフォーマンス - 即座の反映

**要件定義書の要求:**
- デザイン変更から画面反映まで1秒以内
- 100件のメッセージがある状態でも同様のパフォーマンス維持

**実装方針:**

#### リビルドの最適化
- `ref.watch` により、デザイン変更時のみウィジェットが再ビルドされる
- Riverpod の状態管理により、関連するウィジェットのみが効率的に更新される
- `BorderRadius` オブジェクトは軽量で、毎回生成してもパフォーマンス影響は最小限

#### パフォーマンス目標の達成
- SharedPreferences の読み書きは非同期だが、高速（通常10-50ms）
- Riverpod の `state` 更新は同期的で即座に反映（数ms）
- ウィジェットの再ビルドはフレーム単位（16ms）で完了
- **合計: 設定保存から画面反映まで約100ms以内を実現**

#### メモリ使用量
- `SharedPreferences` は1つの文字列値のみを保存（約10バイト）
- メモリへの影響は無視できる程度

### NFR-2: 一貫性 - 統一されたデザイン

**要件定義書の要求:**
- 全ての吹き出しに同じデザインルールが適用される
- 他のデザイン要素（色、サイズ）には影響しない

**実装方針:**

#### 単一の真実の源
- `ChatBubbleDesignRepository` が唯一のデザイン状態を管理
- 全ての吹き出しウィジェットが同じプロバイダーを監視
- `design.borderRadius` プロパティを使用することで、一貫した値を保証

#### 影響範囲の限定
- `borderRadius` プロパティのみを動的に変更
- `color`、`padding`、`margin` などの他のプロパティは既存のまま
- `BoxDecoration` の他のパラメータには手を加えない

### NFR-3: 拡張性 - 将来の機能追加

**要件定義書の要求:**
- 新しいデザインタイプの追加は3ファイル以内、50行以内
- 他の設定機能と独立して動作

**実装方針:**

#### enum ベースの設計
```dart
// 新しいデザインタイプの追加例
enum ChatBubbleDesign {
  square,
  rounded,
  extraRounded,  // 追加: 1行

  BorderRadius get borderRadius {
    return switch (this) {
      // ... 既存のケース
      ChatBubbleDesign.extraRounded => BorderRadius.circular(24),  // 追加: 1行
    };
  }

  String get displayName {
    return switch (this) {
      // ... 既存のケース
      ChatBubbleDesign.extraRounded => '超角削り',  // 追加: 1行
    };
  }
}
```

**必要な変更:**
- ファイル数: 1ファイル（`chat_bubble_design.dart`）
- 行数: 約3行
- ダイアログとプレビューは自動的に対応（`ChatBubbleDesign.values` を使用）

#### 独立性の確保
- `ChatBubbleDesignRepository` は他のリポジトリに依存しない
- SharedPreferences のキーは独立（`chatBubbleDesign`）
- 将来的なテーマ機能との衝突を避ける設計

## テスト戦略

### 単体テスト

#### ChatBubbleDesignRepository のテスト

**テスト対象:** リポジトリの基本機能

```dart
test('デフォルト値がsquareであること', () async {
  // SharedPreferencesに何も保存されていない状態
  final repository = ChatBubbleDesignRepository();
  final design = await repository.build();
  expect(design, ChatBubbleDesign.square);
});

test('保存・読み込みが正しく動作すること', () async {
  final repository = ChatBubbleDesignRepository();
  await repository.save(ChatBubbleDesign.rounded);
  final design = await repository.build();
  expect(design, ChatBubbleDesign.rounded);
});

test('不正な値の場合にsquareにフォールバックすること', () async {
  // SharedPreferencesに不正な値を直接保存
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('chatBubbleDesign', 'invalid_value');

  final repository = ChatBubbleDesignRepository();
  final design = await repository.build();
  expect(design, ChatBubbleDesign.square);
});
```

### ウィジェットテスト

#### ChatBubbleDesignSelectionDialog のテスト

**テスト対象:** ダイアログUI と操作

```dart
testWidgets('2つの選択肢が表示されること', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: ChatBubbleDesignSelectionDialog()),
  );

  expect(find.text('四角'), findsOneWidget);
  expect(find.text('角削り'), findsOneWidget);
});

testWidgets('ラジオボタンの選択が正しく動作すること', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: ChatBubbleDesignSelectionDialog()),
  );

  // 角削りを選択
  await tester.tap(find.text('角削り'));
  await tester.pump();

  // 角削りが選択されていることを確認
  // (RadioListTileの状態を確認)
});

testWidgets('OK/キャンセルボタンの動作を確認', (tester) async {
  // キャンセルボタンでダイアログが閉じる
  // OKボタンで保存されてダイアログが閉じる
});
```

#### 吹き出しウィジェットのテスト

**テスト対象:** デザインの適用

```dart
testWidgets('ユーザー吹き出しにデザインが適用されること', (tester) async {
  // ChatBubbleDesignRepositoryをモック
  // squareデザインで吹き出しを表示
  // borderRadiusがBorderRadius.circular(2)であることを確認

  // roundedデザインに変更
  // borderRadiusがBorderRadius.circular(16)であることを確認
});
```

### 統合テスト

#### NFR-1の検証: パフォーマンス

**テスト内容:** デザイン変更から画面反映までの時間を計測

```dart
testWidgets('デザイン変更が1秒以内に反映されること', (tester) async {
  await tester.pumpWidget(MyApp());

  // チャット画面に移動
  await tester.tap(find.byIcon(Icons.chat));
  await tester.pumpAndSettle();

  // 設定画面を開く
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();

  final startTime = DateTime.now();

  // デザインを変更
  await tester.tap(find.text('吹き出しデザイン'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('角削り'));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  // チャット画面に戻る
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();

  final endTime = DateTime.now();
  final duration = endTime.difference(startTime);

  expect(duration.inMilliseconds, lessThan(1000));
});

testWidgets('100件のメッセージがあってもパフォーマンスが維持されること', (tester) async {
  // 100件のメッセージを作成
  // デザイン変更の時間を計測
  // 1秒以内に反映されることを確認
});
```

#### NFR-2の検証: 一貫性

**テスト内容:** 全ての吹き出しに統一して適用されること

```dart
testWidgets('全ての吹き出しに同じデザインが適用されること', (tester) async {
  await tester.pumpWidget(MyApp());

  // チャット画面に移動
  // ユーザー、AI、システムの各メッセージを表示

  // デザインをroundedに変更
  // 全ての吹き出しがBorderRadius.circular(16)であることを確認

  // デザインをsquareに変更
  // 全ての吹き出しがBorderRadius.circular(2)であることを確認
});
```

#### NFR-3の検証: 拡張性

**テスト内容:** 新しいデザインタイプの追加が容易であること

```dart
test('新しいデザインタイプを追加できること', () {
  // ChatBubbleDesign enumに新しい値を追加
  // borderRadius getterに新しいケースを追加
  // displayName getterに新しいケースを追加
  // 変更ファイル数を確認（1ファイルのみ）
  // 変更行数を確認（3行のみ）
});
```

#### 永続化のテスト

**テスト内容:** アプリ再起動後も設定が保持されること

```dart
testWidgets('アプリ再起動後も設定が保持されること', (tester) async {
  // デザインをroundedに変更
  // アプリを再起動（WidgetTesterで再構築）
  // roundedデザインが適用されていることを確認
});
```

## エラーハンドリング

### SharedPreferences 読み込みエラー

- 読み込みに失敗した場合は `ChatBubbleDesign.square` をデフォルトとして使用
- エラーログを出力するが、アプリは正常に動作する

### 不正な保存値

- enum に存在しない値が保存されている場合は `orElse` でデフォルト値を返す

## 現状の制限事項への対応方針

要件定義書に記載された制限事項に対する将来の対応方針を示します。

### 対象範囲の制限への対応

**制限事項:**
- 吹き出しのポインター（矢印）は角の形状変更の対象外
- 提案カードのデザインは変更の対象外

**将来の対応方針:**

#### ポインターの丸み対応

```dart
class _BubblePointerPainter extends CustomPainter {
  final ChatBubbleDesign design;  // 追加

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path;
    if (design == ChatBubbleDesign.rounded) {
      // 角削りデザインの場合、ポインターにも丸みを持たせる
      path = Path()
        ..moveTo(size.width, 0)
        ..quadraticBezierTo(0, size.height / 2, 0, size.height / 2)  // 曲線
        ..quadraticBezierTo(0, size.height / 2, size.width, size.height)
        ..close();
    } else {
      // 既存の三角形ロジック
    }

    canvas.drawPath(path, paint);
  }
}
```

**必要な変更:**
- `_BubblePointer` に `design` パラメータを追加
- `_BubblePointerPainter` で `design` に応じた描画処理を実装
- 変更ファイル数: 1ファイル（`home_screen.dart`）
- 変更行数: 約20行

#### 提案カードの統一

```dart
class _SuggestionCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final design = ref.watch(chatBubbleDesignRepositoryProvider).valueOrNull
      ?? ChatBubbleDesign.square;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: design.borderRadius,  // 吹き出しと統一
      ),
      // ...
    );
  }
}
```

**必要な変更:**
- `_SuggestionCard` を `ConsumerWidget` に変更
- `ref.watch` で `ChatBubbleDesignRepository` を監視
- 変更ファイル数: 1ファイル（`home_screen.dart`）
- 変更行数: 約5行

### デザインタイプの制限への対応

**制限事項:** 選択可能なデザインタイプは「四角」と「角削り」の2種類のみ

**将来の拡張方法:**

```dart
enum ChatBubbleDesign {
  square,
  rounded,
  extraRounded,    // 追加: 超角削り
  pill,            // 追加: ピル型（完全な楕円）
  asymmetric,      // 追加: 非対称（LINE風）

  BorderRadius get borderRadius {
    return switch (this) {
      ChatBubbleDesign.square => BorderRadius.circular(2),
      ChatBubbleDesign.rounded => BorderRadius.circular(16),
      ChatBubbleDesign.extraRounded => BorderRadius.circular(24),
      ChatBubbleDesign.pill => BorderRadius.circular(999),
      ChatBubbleDesign.asymmetric => const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(4),
      ),
    };
  }

  String get displayName {
    return switch (this) {
      ChatBubbleDesign.square => '四角',
      ChatBubbleDesign.rounded => '角削り',
      ChatBubbleDesign.extraRounded => '超角削り',
      ChatBubbleDesign.pill => 'ピル型',
      ChatBubbleDesign.asymmetric => '非対称',
    };
  }
}
```

### UI/UXの制限への対応

**制限事項:** デザイン切り替え時のアニメーションなし

**アニメーション対応方法:**

```dart
// Container を AnimatedContainer に変更
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  decoration: BoxDecoration(
    color: bubbleColor,
    borderRadius: design.borderRadius,  // アニメーションで滑らかに変化
  ),
  child: bodyText,
)
```

**必要な変更:**
- 3つの吹き出しウィジェットで `Container` → `AnimatedContainer` に変更
- `duration` と `curve` パラメータを追加
- 変更ファイル数: 1ファイル（`home_screen.dart`）
- 変更行数: 約6行（各ウィジェット2行×3箇所）

**効果:**
- デザイン変更時に300msかけて滑らかに角の形状が変化
- 視覚的な連続性が向上
- ユーザー体験の向上

### 機能の制限への対応

**制限事項:** 色、サイズ、配置などの他の視覚要素のカスタマイズは不可

**将来の拡張案:**

```dart
class ChatBubbleStyle {
  final ChatBubbleDesign design;
  final Color? userBubbleColor;     // ユーザー吹き出しの色
  final Color? aiBubbleColor;        // AI吹き出しの色
  final double? fontSize;            // フォントサイズ
  final EdgeInsets? padding;         // 内側の余白

  // ...
}
```

**実装方針:**
- `ChatBubbleDesign` とは独立した設定として実装
- 別のリポジトリ（`ChatBubbleStyleRepository`）で管理
- 設定画面に「吹き出しスタイル」セクションを追加
- デザイン設定との組み合わせを許可

## セキュリティ考慮事項

- SharedPreferences に保存される値は端末内のみで、外部に送信されない
- enum の `name` プロパティを使用することで、型安全性を確保
- ユーザーデータは含まれず、プライバシーへの影響はない

## アクセシビリティ

- デザイン変更は視覚的な変更のみで、スクリーンリーダーの読み上げには影響しない
- コントラスト比は変更前後で同じ
- タップ領域のサイズは変わらない

## 関連ドキュメント

- [機能仕様書: チャット吹き出しデザイン切り替え](../spec/switch-design-feature.md)
- [Reward 機能仕様書](../spec/reward-feature.md) (SharedPreferences 使用の参考例)
- [SharedPreferences 使用時の設計方法](../how-to-design-when-using-shared-preferences.md)
