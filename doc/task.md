# チャット吹き出しデザイン切り替え機能 実装タスクリスト

## 参考資料

- [設計書: チャット吹き出しデザイン切り替え機能](./design/switch-design.md)

## Data Layer

### 1. ChatBubbleDesign ドメインモデルの作成

- [x] `client/lib/data/model/chat_bubble_design.dart` を作成
- [x] enum ChatBubbleDesign を定義
  - [x] `square` - 四角デザイン
  - [x] `rounded` - 角削りデザイン

### 2. PreferenceKey の拡張

- [x] `client/lib/data/model/preference_key.dart` を編集
- [x] enum に `chatBubbleDesign` を追加

### 3. ChatBubbleDesignRepository の実装

- [x] `client/lib/data/repository/chat_bubble_design_repository.dart` を作成
- [x] Riverpod の @riverpod アノテーションを使用
- [x] `build()` メソッドを実装
  - [x] SharedPreferences から設定を読み込み
  - [x] デフォルト値として `square` を返す
- [x] `save(ChatBubbleDesign design)` メソッドを実装
  - [x] enum.name を文字列として SharedPreferences に保存
  - [x] state を更新

## UI Layer - Component

### 4. ChatBubbleDesignExtension の作成

- [x] `client/lib/ui/component/chat_bubble_design_extension.dart` を作成
- [x] ChatBubbleDesign の extension を定義
- [x] `borderRadius` getter を実装
  - [x] square → BorderRadius.circular(2)
  - [x] rounded → BorderRadius.circular(16)
- [x] `displayName` getter を実装
  - [x] square → "四角"
  - [x] rounded → "角削り"

## UI Layer - Home Screen

### 5. 吹き出しウィジェットの更新

- [x] `client/lib/ui/feature/home/home_screen.dart` を編集
- [x] `_UserChatBubble` を更新
  - [x] ref.watch で ChatBubbleDesignRepository を監視
  - [x] design.borderRadius を BoxDecoration に適用
  - [x] 固定値を動的な値に変更
- [x] `_AiChatBubble` を更新
  - [x] ref.watch で ChatBubbleDesignRepository を監視
  - [x] design.borderRadius を BoxDecoration に適用
  - [x] 固定値を動的な値に変更
- [x] `_AppChatBubble` を更新
  - [x] ref.watch で ChatBubbleDesignRepository を監視
  - [x] design.borderRadius を BoxDecoration に適用
  - [x] 固定値を動的な値に変更

## UI Layer - Settings

### 6. デザイン選択ダイアログの作成

- [x] `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart` を作成
- [x] ダイアログウィジェットを実装
  - [x] 2 つのデザインを RadioListTile で表示
  - [x] 各デザインのプレビューを表示
  - [x] 初期値として現在のデザインを設定
- [x] OK/キャンセルボタンを実装
  - [x] OK タップ時に Repository.save() を呼び出し
  - [x] キャンセルタップ時に変更を破棄

### 7. 設定画面の更新

- [x] `client/lib/ui/feature/settings/settings_screen.dart` を編集
- [x] "表示設定" セクションを追加
- [x] "吹き出しデザイン" ListTile を追加
  - [x] アイコン: Icons.chat_bubble_outline
  - [x] サブタイトルに現在のデザイン名を表示
  - [x] ref.watch で ChatBubbleDesignRepository を監視
  - [x] タップでデザイン選択ダイアログを表示

## Testing

### 8. ユニットテストの作成

- [x] `client/test/data/repository/chat_bubble_design_repository_test.dart` を作成
  - [x] デフォルト値が square であることをテスト
  - [x] save メソッドが正しく保存することをテスト
  - [x] 保存した値が正しく読み込まれることをテスト

### 9. ウィジェットテストの作成（オプション）

- [ ] `client/test/ui/component/chat_bubble_design_extension_test.dart` を作成
  - [ ] borderRadius が正しい値を返すことをテスト
  - [ ] displayName が正しい値を返すことをテスト

## Code Quality

### 10. コードフォーマットと静的解析

- [x] `dart format` を実行して全ファイルをフォーマット
- [x] `dart fix --apply` を実行して自動修正を適用
- [x] `flutter analyze` を実行して警告がないことを確認

### 11. テストの実行

- [x] 全ユニットテストを実行して成功することを確認
- [ ] 必要に応じてウィジェットテストを実行

## Documentation

### 12. ドキュメントの更新

- [x] 必要に応じて要件定義書を更新
- [x] 必要に応じて設計書を更新

## Final

### 13. コミット

- [x] 適切なコミットメッセージを作成
- [x] 変更をコミット
