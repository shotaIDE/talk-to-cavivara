# チャット吹き出しデザイン切り替え機能 実装タスクリスト

## 参考資料

- [設計書: チャット吹き出しデザイン切り替え機能](./design/switch-design.md)

## Data Layer

### 1. ChatBubbleDesign ドメインモデルの作成
- [ ] `client/lib/data/model/chat_bubble_design.dart` を作成
- [ ] enum ChatBubbleDesign を定義
  - [ ] `square` - 四角デザイン
  - [ ] `rounded` - 角削りデザイン

### 2. PreferenceKey の拡張
- [ ] `client/lib/data/model/preference_key.dart` を編集
- [ ] enum に `chatBubbleDesign` を追加

### 3. ChatBubbleDesignRepository の実装
- [ ] `client/lib/data/repository/chat_bubble_design_repository.dart` を作成
- [ ] Riverpod の @riverpod アノテーションを使用
- [ ] `build()` メソッドを実装
  - [ ] SharedPreferences から設定を読み込み
  - [ ] デフォルト値として `square` を返す
- [ ] `save(ChatBubbleDesign design)` メソッドを実装
  - [ ] enum.name を文字列として SharedPreferences に保存
  - [ ] state を更新

## UI Layer - Component

### 4. ChatBubbleDesignExtension の作成
- [ ] `client/lib/ui/component/chat_bubble_design_extension.dart` を作成
- [ ] ChatBubbleDesign の extension を定義
- [ ] `borderRadius` getter を実装
  - [ ] square → BorderRadius.circular(2)
  - [ ] rounded → BorderRadius.circular(16)
- [ ] `displayName` getter を実装
  - [ ] square → "四角"
  - [ ] rounded → "角削り"

## UI Layer - Home Screen

### 5. 吹き出しウィジェットの更新
- [ ] `client/lib/ui/feature/home/home_screen.dart` を編集
- [ ] `_UserChatBubble` を更新
  - [ ] ref.watch で ChatBubbleDesignRepository を監視
  - [ ] design.borderRadius を BoxDecoration に適用
  - [ ] 固定値を動的な値に変更
- [ ] `_AiChatBubble` を更新
  - [ ] ref.watch で ChatBubbleDesignRepository を監視
  - [ ] design.borderRadius を BoxDecoration に適用
  - [ ] 固定値を動的な値に変更
- [ ] `_AppChatBubble` を更新
  - [ ] ref.watch で ChatBubbleDesignRepository を監視
  - [ ] design.borderRadius を BoxDecoration に適用
  - [ ] 固定値を動的な値に変更

## UI Layer - Settings

### 6. デザイン選択ダイアログの作成
- [ ] `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart` を作成
- [ ] ダイアログウィジェットを実装
  - [ ] 2つのデザインを RadioListTile で表示
  - [ ] 各デザインのプレビューを表示
  - [ ] 初期値として現在のデザインを設定
- [ ] OK/キャンセルボタンを実装
  - [ ] OK タップ時に Repository.save() を呼び出し
  - [ ] キャンセルタップ時に変更を破棄

### 7. 設定画面の更新
- [ ] `client/lib/ui/feature/settings/settings_screen.dart` を編集
- [ ] "表示設定" セクションを追加
- [ ] "吹き出しデザイン" ListTile を追加
  - [ ] アイコン: Icons.chat_bubble_outline
  - [ ] サブタイトルに現在のデザイン名を表示
  - [ ] ref.watch で ChatBubbleDesignRepository を監視
  - [ ] タップでデザイン選択ダイアログを表示

## Testing

### 8. ユニットテストの作成
- [ ] `client/test/data/repository/chat_bubble_design_repository_test.dart` を作成
  - [ ] デフォルト値が square であることをテスト
  - [ ] save メソッドが正しく保存することをテスト
  - [ ] 保存した値が正しく読み込まれることをテスト

### 9. ウィジェットテストの作成（オプション）
- [ ] `client/test/ui/component/chat_bubble_design_extension_test.dart` を作成
  - [ ] borderRadius が正しい値を返すことをテスト
  - [ ] displayName が正しい値を返すことをテスト

## Code Quality

### 10. コードフォーマットと静的解析
- [ ] `dart format` を実行して全ファイルをフォーマット
- [ ] `dart fix --apply` を実行して自動修正を適用
- [ ] `flutter analyze` を実行して警告がないことを確認

### 11. テストの実行
- [ ] 全ユニットテストを実行して成功することを確認
- [ ] 必要に応じてウィジェットテストを実行

## Documentation

### 12. ドキュメントの更新
- [ ] 必要に応じて要件定義書を更新
- [ ] 必要に応じて設計書を更新

## Final

### 13. コミット
- [ ] 適切なコミットメッセージを作成
- [ ] 変更をコミット
