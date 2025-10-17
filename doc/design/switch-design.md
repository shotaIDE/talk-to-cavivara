# チャット吹き出しデザイン切り替え機能 概要設計書

## 目的

チャット画面の吹き出し形状を「四角」と「角削り」から選択できる機能の技術的な設計概要を示す。

## アーキテクチャ

### レイヤー構成

本機能は以下の 3 層アーキテクチャで実装する：

1. **UI Layer** - ユーザーインターフェース

   - 吹き出しウィジェット（HomeScreen 内）
   - 設定画面（SettingsScreen）
   - デザイン選択ダイアログ

2. **Repository Layer** - データ永続化

   - ChatBubbleDesignRepository

3. **Data Layer** - ストレージ
   - SharedPreferences

データフローは、UI Layer → Repository Layer → Data Layer の順で、Riverpod の状態管理により双方向に連携する。

## 主要コンポーネント

### 1. ChatBubbleDesign（ドメインモデル）

**配置**: `client/lib/data/model/chat_bubble_design.dart`

**役割**: デザインタイプを表す enum

**内容**:

- `square`: 四角デザイン
- `rounded`: 角削りデザイン

**特徴**:

- UI に依存しない純粋なドメインモデル
- borderRadius や displayName などの UI 関連プロパティは持たない
- Dart 標準の enum のみを使用

### 2. ChatBubbleDesignExtension（UI 拡張）

**配置**: `client/lib/ui/component/chat_bubble_design_extension.dart`

**役割**: ChatBubbleDesign に UI 関連の機能を拡張

**提供機能**:

- `borderRadius`: 各デザインに対応する BorderRadius を返す
  - square → BorderRadius.circular(2)
  - rounded → BorderRadius.circular(16)
- `displayName`: UI 表示用の日本語名を返す
  - square → "四角"
  - rounded → "角削り"

**設計意図**:

- 関心の分離：データモデルと UI ロジックを分離
- 依存関係の明確化：data/model は Flutter UI に依存しない
- テスタビリティ：モデル層のテストが UI 非依存
- 再利用性：同じモデルを異なる UI 実装で使用可能

### 3. ChatBubbleDesignRepository（永続化）

**配置**: `client/lib/data/repository/chat_bubble_design_repository.dart`

**役割**: デザイン設定の読み込みと保存

**主要機能**:

- `build()`: SharedPreferences から設定を読み込み、デフォルトは square
- `save(design)`: 選択されたデザインを SharedPreferences に保存

**実装方式**:

- Riverpod の@riverpod アノテーション
- AsyncValue で非同期状態を管理
- enum.name を文字列として保存

### 4. PreferenceKey 拡張

**配置**: `client/lib/data/model/preference_key.dart`

**変更内容**: enum に`chatBubbleDesign`を追加

**保存形式**:

- キー: "chatBubbleDesign"
- 値: "square" または "rounded"（enum.name）

### 5. 吹き出しウィジェット更新

**配置**: `client/lib/ui/feature/home/home_screen.dart`

**変更対象**:

- `_UserChatBubble`: ユーザーの送信メッセージ吹き出し
- `_AiChatBubble`: AI の返信メッセージ吹き出し
- `_AppChatBubble`: アプリからのシステムメッセージ吹き出し

**実装方法**:

- ref.watch で ChatBubbleDesignRepository を監視
- design.borderRadius を BoxDecoration に適用
- 固定値 BorderRadius.circular(2)を動的な値に変更

### 6. デザイン選択ダイアログ

**配置**: `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart`

**機能**:

- 2 つのデザインを RadioListTile で表示
- 各デザインのプレビューを表示
- OK/キャンセルボタン

**動作**:

- 初期値として現在のデザインを表示
- OK タップで Repository に保存
- キャンセルタップで変更を破棄

### 7. 設定画面の更新

**配置**: `client/lib/ui/feature/settings/settings_screen.dart`

**追加内容**:

- "表示設定"セクションを追加
- "吹き出しデザイン"ListTile を追加
  - アイコン: Icons.chat_bubble_outline
  - サブタイトルに現在のデザイン名を表示
  - タップでデザイン選択ダイアログを表示

## データフロー

### アプリ起動時

1. ChatBubbleDesignRepository が build される
2. SharedPreferences から保存値を読み込み
3. 値が存在しない場合は square をデフォルトとして返す
4. 吹き出しウィジェットが ref.watch で値を取得
5. design.borderRadius を BoxDecoration に適用

### デザイン変更時

1. ユーザーが設定画面の「吹き出しデザイン」をタップ
2. デザイン選択ダイアログを表示
3. ユーザーがデザインを選択して「OK」をタップ
4. Repository.save()で SharedPreferences に保存
5. Riverpod の state を更新
6. ref.watch している全ウィジェットが自動的に再ビルド
7. 新しい borderRadius が適用される

## 関連ドキュメント

- [要件定義書: チャット吹き出しデザイン切り替え](../spec/switch-design-feature.md)
- [SharedPreferences 使用時の設計方法](../how-to-design-when-using-shared-preferences.md)
- [Reward 機能仕様書](../spec/reward-feature.md) - SharedPreferences 使用の参考例
