# 吹き出しのツノ排除と角丸デザイン 実装タスク

## 参考資料

- [要件定義書: 吹き出しのツノ排除と角丸デザイン](./requirement/bubble-tail-removal.md)
- [技術設計書: 吹き出しのツノ排除と角丸デザイン](./design/bubble-tail-removal.md)

## フェーズ 1: Extension の拡張

### MessageType enum の追加

- [ ] `client/lib/ui/component/chat_bubble_design_extension.dart` を編集
- [ ] `MessageType` enum を追加
  - [ ] `MessageType.user` を定義
  - [ ] `MessageType.ai` を定義
  - [ ] `MessageType.system` を定義

### borderRadiusForMessageType メソッドの実装

- [ ] `borderRadiusForMessageType` メソッドを実装
  - [ ] `ChatBubbleDesign.square` の場合の実装（全メッセージタイプで radius 2）
  - [ ] `ChatBubbleDesign.rounded` のユーザーメッセージの実装
    - [ ] 左上: radius 10
    - [ ] 右上: radius 4（ツノがあった位置）
    - [ ] 右下: radius 10
    - [ ] 左下: radius 10
  - [ ] `ChatBubbleDesign.rounded` の AI メッセージの実装
    - [ ] 左上: radius 4（ツノがあった位置）
    - [ ] 右上: radius 10
    - [ ] 右下: radius 10
    - [ ] 左下: radius 10
  - [ ] `ChatBubbleDesign.rounded` のシステムメッセージの実装（全て radius 10）

### ユニットテストの作成

- [ ] `client/test/ui/component/chat_bubble_design_extension_test.dart` を作成または編集
  - [ ] square デザインのテスト（全メッセージタイプで radius 2）
  - [ ] rounded デザインのユーザーメッセージテスト
    - [ ] 右上が radius 4
    - [ ] 他の角が radius 10
  - [ ] rounded デザインの AI メッセージテスト
    - [ ] 左上が radius 4
    - [ ] 他の角が radius 10
  - [ ] rounded デザインのシステムメッセージテスト（全て radius 10）

### コード品質チェック

- [ ] テストを実行して全て通ることを確認
- [ ] `dart format client/lib/ui/component/chat_bubble_design_extension.dart` を実行
- [ ] `dart fix --apply` を実行
- [ ] `flutter analyze` でリンター・コンパイラ警告の確認と解決

## フェーズ 2: 吹き出しウィジェットの更新

### _UserChatBubble の更新

- [ ] `client/lib/ui/feature/home/home_screen.dart` の `_UserChatBubble` を編集
- [ ] `MessageType.user` を使用して borderRadius を取得
- [ ] `design.borderRadiusForMessageType(MessageType.user)` を BoxDecoration に適用

### _AiChatBubble の更新

- [ ] `client/lib/ui/feature/home/home_screen.dart` の `_AiChatBubble` を編集
- [ ] `MessageType.ai` を使用して borderRadius を取得
- [ ] `design.borderRadiusForMessageType(MessageType.ai)` を BoxDecoration に適用

### _AppChatBubble の更新

- [ ] `client/lib/ui/feature/home/home_screen.dart` の `_AppChatBubble` を編集
- [ ] `MessageType.system` を使用して borderRadius を取得
- [ ] `design.borderRadiusForMessageType(MessageType.system)` を BoxDecoration に適用

### コード品質チェック

- [ ] `dart format client/lib/ui/feature/home/home_screen.dart` を実行
- [ ] `dart fix --apply` を実行
- [ ] `flutter analyze` でリンター・コンパイラ警告の確認と解決
- [ ] ウィジェットテストで視覚確認（オプション）

## フェーズ 3: プレビューの更新

### デザイン選択ダイアログのプレビュー更新

- [ ] `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart` を編集
- [ ] 「角削り」デザインのプレビューに新しい borderRadius を適用
- [ ] 適切な MessageType を選択して `borderRadiusForMessageType` を使用

### コード品質チェック

- [ ] `dart format client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart` を実行
- [ ] `dart fix --apply` を実行
- [ ] `flutter analyze` でリンター・コンパイラ警告の確認と解決
- [ ] 実機またはシミュレータで視覚確認

## フェーズ 4: テストと検証

### iOS での確認

- [ ] iOS でビルド・実行
- [ ] ユーザーメッセージの右上角が radius 4 で表示される
- [ ] ユーザーメッセージの他の角が radius 10 で表示される
- [ ] AI メッセージの左上角が radius 4 で表示される
- [ ] AI メッセージの他の角が radius 10 で表示される
- [ ] システムメッセージの全ての角が radius 10 で表示される

### Android での確認

- [ ] Android でビルド・実行
- [ ] ユーザーメッセージの右上角が radius 4 で表示される
- [ ] ユーザーメッセージの他の角が radius 10 で表示される
- [ ] AI メッセージの左上角が radius 4 で表示される
- [ ] AI メッセージの他の角が radius 10 で表示される
- [ ] システムメッセージの全ての角が radius 10 で表示される

### クロスプラットフォーム確認

- [ ] iOS/Android 間で見た目の差異がないことを確認

### 機能テスト

- [ ] デザイン選択ダイアログを開く
- [ ] 「四角」デザインは変更されていない（radius 2 の一律適用）
- [ ] 「角削り」デザインを選択すると新しい角丸が適用される
- [ ] デザイン選択ダイアログのプレビューが新しい仕様を反映している

### 永続化テスト

- [ ] デザイン選択が永続化される
- [ ] アプリを完全に終了
- [ ] アプリを再起動
- [ ] 選択したデザインが保持されている

## 完了後

### ドキュメント更新

- [ ] 必要に応じて要件定義書を更新
- [ ] 必要に応じて設計書を更新

### コミット

- [ ] 適切なコミットメッセージを作成
- [ ] 変更をコミット
