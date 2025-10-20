# 吹き出しのツノ排除と角丸デザイン 技術設計書

## 目的

チャット画面の吹き出しデザインにおいて、ツノ(tail)部分を排除し、角ごとに異なる角丸を適用する機能の技術的な設計概要を示す。ツノがあった角には小さい角丸(radius 4)、それ以外の角には大きい角丸(radius 10)を適用することで、より洗練された吹き出しデザインを実現する。

## アーキテクチャ

### レイヤー構成

本機能は既存のデザイン切り替え機能を拡張する形で実装する：

1. **UI Layer** - ユーザーインターフェース

   - 吹き出しウィジェット（HomeScreen 内）
   - デザイン選択ダイアログのプレビュー更新

2. **Repository Layer** - データ永続化

   - 既存の ChatBubbleDesignRepository を継続使用（変更なし）

3. **Data Layer** - ストレージ
   - SharedPreferences（変更なし）

データフローは既存の設計を踏襲し、UI Layer の表示ロジックのみを変更する。

## 主要コンポーネント

### 1. ChatBubbleDesignExtension の拡張

**配置**: `client/lib/ui/component/chat_bubble_design_extension.dart`

**役割**: ChatBubbleDesign に角ごとに異なる BorderRadius を返すメソッドを追加

**変更内容**:

既存の `borderRadius` getter を拡張し、メッセージタイプごとに異なる BorderRadius を返すメソッドを追加する。

**実装方針**:

1. 既存の `borderRadius` getter は後方互換性のため残す
2. 新しいメソッド `borderRadiusForMessageType` を追加
3. メッセージタイプを表す enum `MessageType` を導入

**メソッドシグネチャ**:

```dart
enum MessageType {
  user,    // ユーザーメッセージ
  ai,      // AIメッセージ
  system,  // システムメッセージ
}

extension ChatBubbleDesignExtension on ChatBubbleDesign {
  BorderRadius borderRadiusForMessageType(MessageType messageType) {
    // 実装内容
  }
}
```

**角丸の仕様**:

- `ChatBubbleDesign.square` の場合:

  - 全メッセージタイプで `BorderRadius.circular(2)` を返す（既存の動作を維持）

- `ChatBubbleDesign.rounded` の場合:
  - ユーザーメッセージ:
    ```dart
    BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(4),    // ツノがあった位置
      bottomRight: Radius.circular(10),
      bottomLeft: Radius.circular(10),
    )
    ```
  - AI メッセージ:
    ```dart
    BorderRadius.only(
      topLeft: Radius.circular(4),     // ツノがあった位置
      topRight: Radius.circular(10),
      bottomRight: Radius.circular(10),
      bottomLeft: Radius.circular(10),
    )
    ```
  - システムメッセージ:
    ```dart
    BorderRadius.circular(10)  // 全て同じ角丸
    ```

### 2. 吹き出しウィジェット更新

**配置**: `client/lib/ui/feature/home/home_screen.dart`

**変更対象**:

- `_UserChatBubble`: ユーザーの送信メッセージ吹き出し
- `_AiChatBubble`: AI の返信メッセージ吹き出し
- `_AppChatBubble`: アプリからのシステムメッセージ吹き出し

**実装方法**:

既存の実装では:

```dart
decoration: BoxDecoration(
  color: backgroundColor,
  borderRadius: design.borderRadius,
)
```

新しい実装:

```dart
// _UserChatBubble 内
decoration: BoxDecoration(
  color: backgroundColor,
  borderRadius: design.borderRadiusForMessageType(MessageType.user),
)

// _AiChatBubble 内
decoration: BoxDecoration(
  color: backgroundColor,
  borderRadius: design.borderRadiusForMessageType(MessageType.ai),
)

// _AppChatBubble 内
decoration: BoxDecoration(
  color: backgroundColor,
  borderRadius: design.borderRadiusForMessageType(MessageType.system),
)
```

### 3. デザイン選択ダイアログのプレビュー更新

**配置**: `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart`

**変更内容**:

「角削り」デザインのプレビュー表示を更新する。

**実装方針**:

1. 既存のプレビューサンプルに新しい角丸仕様を適用
2. サンプルは1つのみ表示（既存の実装を踏襲）
3. 視覚的に角丸の違いが分かるようにする

**プレビューレイアウト**:

```
角削り
┌─────────────────────────────────┐
│   ╭──────────╮                  │  ← サンプル（新しい角丸仕様を適用）
│   │ サンプル │                  │
│   ╰─────────╯                   │
└─────────────────────────────────┘
```

### 4. ChatBubbleDesign（ドメインモデル）

**配置**: `client/lib/data/model/chat_bubble_design.dart`

**変更**: なし

既存の enum 定義を維持する：

- `square`: 四角デザイン
- `rounded`: 角削りデザイン

### 5. ChatBubbleDesignRepository

**配置**: `client/lib/data/repository/chat_bubble_design_repository.dart`

**変更**: なし

既存のリポジトリをそのまま使用する。

## データフロー

### アプリ起動時

1. ChatBubbleDesignRepository が build される
2. SharedPreferences から保存値を読み込み（既存の実装）
3. 吹き出しウィジェットが ref.watch で値を取得
4. **新**: `design.borderRadiusForMessageType(messageType)` でメッセージタイプに応じた BorderRadius を取得
5. **新**: メッセージタイプごとに異なる角丸が適用される

### デザイン変更時

1. ユーザーが設定画面の「吹き出しデザイン」をタップ
2. デザイン選択ダイアログを表示
3. **新**: プレビューで新しい角丸仕様が表示される
4. ユーザーがデザインを選択して「OK」をタップ
5. Repository.save()で SharedPreferences に保存（既存の実装）
6. Riverpod の state を更新
7. ref.watch している全ウィジェットが自動的に再ビルド
8. **新**: 新しい角丸仕様が適用される

## 実装手順

### フェーズ 1: Extension の拡張

1. `chat_bubble_design_extension.dart` に `MessageType` enum を追加
2. `borderRadiusForMessageType` メソッドを実装
3. ユニットテストを作成・実行

### フェーズ 2: 吹き出しウィジェットの更新

1. `home_screen.dart` の各吹き出しウィジェットを更新
   - `_UserChatBubble`: `MessageType.user` を使用
   - `_AiChatBubble`: `MessageType.ai` を使用
   - `_AppChatBubble`: `MessageType.system` を使用
2. `dart format` を実行
3. `dart fix --apply` を実行
4. ウィジェットテストで視覚確認

### フェーズ 3: プレビューの更新

1. `chat_bubble_design_selection_dialog.dart` のプレビュー部分を更新
2. ユーザーメッセージと AI メッセージのサンプルを両方表示
3. `dart format` を実行
4. `dart fix --apply` を実行
5. 実機で視覚確認

### フェーズ 4: テストと検証

1. iOS でビルド・実行
2. Android でビルド・実行
3. デザイン切り替え動作確認
4. 永続化の確認（アプリ再起動後も設定が保持されること）

## テスト戦略

### ユニットテスト

**対象**: `ChatBubbleDesignExtension`

**テストケース**:

```dart
group('borderRadiusForMessageType', () {
  test('square design returns uniform small radius for all message types', () {
    final design = ChatBubbleDesign.square;
    expect(
      design.borderRadiusForMessageType(MessageType.user),
      BorderRadius.circular(2),
    );
    expect(
      design.borderRadiusForMessageType(MessageType.ai),
      BorderRadius.circular(2),
    );
    expect(
      design.borderRadiusForMessageType(MessageType.system),
      BorderRadius.circular(2),
    );
  });

  test('rounded design returns custom radius for user message', () {
    final design = ChatBubbleDesign.rounded;
    final result = design.borderRadiusForMessageType(MessageType.user);
    expect(result.topLeft, Radius.circular(10));
    expect(result.topRight, Radius.circular(4));
    expect(result.bottomRight, Radius.circular(10));
    expect(result.bottomLeft, Radius.circular(10));
  });

  test('rounded design returns custom radius for ai message', () {
    final design = ChatBubbleDesign.rounded;
    final result = design.borderRadiusForMessageType(MessageType.ai);
    expect(result.topLeft, Radius.circular(4));
    expect(result.topRight, Radius.circular(10));
    expect(result.bottomRight, Radius.circular(10));
    expect(result.bottomLeft, Radius.circular(10));
  });

  test('rounded design returns uniform radius for system message', () {
    final design = ChatBubbleDesign.rounded;
    final result = design.borderRadiusForMessageType(MessageType.system);
    expect(result, BorderRadius.circular(10));
  });
});
```

### ウィジェットテスト

**対象**: 吹き出しウィジェット

**テスト内容**:

- 各吹き出しウィジェットが正しい BorderRadius を適用しているか確認
- Golden test でビジュアルリグレッションを検出

### 統合テスト

**対象**: デザイン選択機能全体

**テストシナリオ**:

1. デザイン選択ダイアログを開く
2. 「角削り」を選択
3. プレビューで新しい角丸が表示されることを確認
4. OK をタップ
5. チャット画面で新しい角丸が適用されることを確認
6. アプリを再起動
7. 設定が保持されていることを確認

## 後方互換性

### 既存機能への影響

- ✅ `ChatBubbleDesign` enum: 変更なし
- ✅ `ChatBubbleDesignRepository`: 変更なし
- ✅ 既存の `borderRadius` getter: 残すため互換性維持
- ✅ SharedPreferences の保存形式: 変更なし

### マイグレーション

マイグレーション不要。既存のユーザー設定はそのまま有効。

## 制約事項と考慮事項

### 技術的制約

- Flutter の `BorderRadius.only()` を使用
- iOS, Android 両プラットフォームで同一の見た目を保証
- パフォーマンスへの影響: 微小（BorderRadius の生成コストのみ）

### デザイン的制約

- radius 値は要件定義書に従い、4 と 10 に固定
- システムメッセージは対称的なデザイン（全角 radius 10）

### 将来の拡張性

- radius 値を設定可能にする場合:

  - `borderRadiusForMessageType` にパラメータを追加
  - または新しい設定項目を追加

- 新しいメッセージタイプを追加する場合:
  - `MessageType` enum に値を追加
  - `borderRadiusForMessageType` に case を追加

## 関連ドキュメント

- [要件定義書: 吹き出しのツノ排除と角丸デザイン](../requirement/bubble-tail-removal.md)
- [技術設計書: チャット吹き出しデザイン切り替え](./switch-design.md)
- [要件定義書: チャット吹き出しデザイン切り替え](../requirement/switch-design.md)
