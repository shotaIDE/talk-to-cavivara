# 調整済吹き出しデザイン 実装タスク一覧

## 概要

チャット画面の吹き出しに「調整済様式」(harmonized)を追加する。調整済様式は、ツノを持たず、3隅の角を二等辺三角形（等辺10pt）で削り取った7角形（システムメッセージは6角形）の幾何学的な形状。

## フェーズ 1: enum の追加

- [x] `client/lib/data/model/chat_bubble_design.dart` に `harmonized` を追加
  - `ChatBubbleDesign` enum に `harmonized` 値を追加
- [x] `dart format` を実行
- [x] コンパイルエラーの確認（全ての switch 文で exhaustive check が働く）

## フェーズ 2: CustomClipper の実装

- [x] `client/lib/ui/component/harmonized_bubble_clipper.dart` を新規作成
- [x] `HarmonizedBubbleClipper` クラスを実装
  - [x] クラス定義とコンストラクタ（messageType, cutSize パラメータ）
  - [x] `MessageType.user` 用の Path 生成ロジック（7角形、左上の角を残す）
  - [x] `MessageType.ai` 用の Path 生成ロジック（7角形、右上の角を残す）
  - [x] `MessageType.system` 用の Path 生成ロジック（6角形）
  - [x] `shouldReclip` メソッドの実装（false を返す）
- [x] `dart format` を実行
- [x] `dart fix --apply` を実行
- [x] ユニットテストを作成
  - [x] `client/test/ui/component/harmonized_bubble_clipper_test.dart` を作成
  - [x] user message creates 7-point path のテスト
  - [x] ai message creates 7-point path のテスト
  - [x] system message creates 6-point path のテスト
  - [x] shouldReclip returns false のテスト
- [x] ユニットテストを実行して全て成功することを確認

## フェーズ 3: Extension の拡張

- [x] `client/lib/ui/component/chat_bubble_design_extension.dart` を更新
  - [x] `displayName` プロパティに `harmonized` のケースを追加（戻り値: `'調整済様式'`）
  - [x] **注意**: `borderRadiusForMessageType` には追加しない
- [x] `dart format` を実行
- [x] `dart fix --apply` を実行
- [x] ユニットテストを更新
  - [x] `client/test/ui/component/chat_bubble_design_extension_test.dart` に harmonized design のテストケースを追加
  - [x] displayName returns correct Japanese name のテスト
- [x] ユニットテストを実行して全て成功することを確認

## フェーズ 4: 吹き出しウィジェットの更新

- [x] `client/lib/ui/feature/home/home_screen.dart` を更新
  - [x] `_UserChatBubble` を更新
    - [x] `buildBubble()` メソッドを実装
    - [x] `harmonized` の場合に `ClipPath` + `HarmonizedBubbleClipper` を使用
    - [x] それ以外の場合は既存の `BoxDecoration` + `BorderRadius` を使用
  - [x] `_AiChatBubble` を更新
    - [x] `buildBubble()` メソッドを実装
    - [x] `harmonized` の場合に `ClipPath` + `HarmonizedBubbleClipper` を使用
    - [x] それ以外の場合は既存の `BoxDecoration` + `BorderRadius` を使用
  - [x] `_AppChatBubble` を更新
    - [x] `buildBubble()` メソッドを実装
    - [x] `harmonized` の場合に `ClipPath` + `HarmonizedBubbleClipper` を使用
    - [x] それ以外の場合は既存の `BoxDecoration` + `BorderRadius` を使用
- [x] `dart format` を実行
- [x] `dart fix --apply` を実行
- [x] 警告がないことを確認
- [ ] 実機またはシミュレータで視覚確認
  - [ ] ユーザーメッセージが7角形で表示されること（左上の角が残る）
  - [ ] AIメッセージが7角形で表示されること（右上の角が残る）
  - [ ] システムメッセージが6角形で表示されること

## フェーズ 5: デザイン選択ダイアログの更新

- [x] `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart` を更新
  - [x] RadioListTile に「調整済様式」の選択肢を追加
  - [x] プレビュー部分に調整済様式のサンプル吹き出しを追加
    - [x] `ClipPath` + `HarmonizedBubbleClipper` を使用
    - [x] サンプルテキストとスタイリングを既存のデザインと統一
- [x] `dart format` を実行
- [x] `dart fix --apply` を実行
- [x] 警告がないことを確認
- [ ] 実機またはシミュレータで視覚確認
  - [ ] ダイアログに「調整済様式」の選択肢が表示されること
  - [ ] プレビューが7角形で表示されること
  - [ ] 選択してOKをタップすると設定が保存されること

## フェーズ 6: テストと検証

- [x] 全ユニットテストを実行して成功することを確認
  - [x] `flutter test` または `dart test` を実行（69テスト全て成功）
- [ ] iOS でビルド・実行
  - [ ] エラーなくビルドできること
  - [ ] 吹き出しが正しく表示されること
- [ ] Android でビルド・実行
  - [ ] エラーなくビルドできること
  - [ ] 吹き出しが正しく表示されること
- [ ] デザイン切り替え動作確認
  - [ ] 社内標準様式 → 調整済様式
  - [ ] 次世代様式 → 調整済様式
  - [ ] 調整済様式 → 社内標準様式
  - [ ] 調整済様式 → 次世代様式
- [ ] 永続化の確認
  - [ ] 調整済様式を選択
  - [ ] アプリを完全に終了
  - [ ] アプリを再起動
  - [ ] 調整済様式が保持されていることを確認

## フェーズ 7: ドキュメントとコミット

- [x] 必要に応じてドキュメントを更新
  - [x] 要件定義書: `doc/requirement/harmonized-bubble-design.md`（既存）
  - [x] 技術設計書: `doc/design/harmonized-bubble-design.md`（既存）
- [x] 適切なコミットメッセージを考える
- [x] 変更をコミット（コミットID: 9b607b2）

## 注意事項

### 実装時の注意

- `ChatBubbleDesignExtension` の `borderRadiusForMessageType` には `harmonized` のケースを追加しない（CustomClipper を使用するため BorderRadius は不要）
- `cutSize` パラメータは正確に 10.0 とする
- 削り取られた辺は直線とする（曲線は使用しない）
- ツノ(tail)は実装しない

### コーディング規約

実装前に以下を確認すること:
- [doc/coding-rule/](/doc/coding-rule/) のコーディング規約
- 類似の既存コード約5つを参照

実装後は必ず以下を実行すること:
1. `dart format` でフォーマット
2. `dart fix --apply` で自動修正
3. linter と compiler の警告を解決
4. ユニットテストを実行して全て成功することを確認

## 関連ファイル

### 既存ファイル（変更対象）

- [client/lib/data/model/chat_bubble_design.dart](client/lib/data/model/chat_bubble_design.dart)
- [client/lib/ui/component/chat_bubble_design_extension.dart](client/lib/ui/component/chat_bubble_design_extension.dart)
- [client/lib/ui/feature/home/home_screen.dart](client/lib/ui/feature/home/home_screen.dart)
- [client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart](client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart)

### 新規ファイル（作成対象）

- [client/lib/ui/component/harmonized_bubble_clipper.dart](client/lib/ui/component/harmonized_bubble_clipper.dart)
- [client/test/ui/component/harmonized_bubble_clipper_test.dart](client/test/ui/component/harmonized_bubble_clipper_test.dart)

### 既存ファイル（変更なし）

- [client/lib/data/repository/chat_bubble_design_repository.dart](client/lib/data/repository/chat_bubble_design_repository.dart) - enum.name を使用した保存・復元により自動的に対応

## 設計書

- [doc/design/harmonized-bubble-design.md](doc/design/harmonized-bubble-design.md) - 技術設計書
- [doc/requirement/harmonized-bubble-design.md](doc/requirement/harmonized-bubble-design.md) - 要件定義書
