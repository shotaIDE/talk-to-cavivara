# チャット吹き出しデザイン切り替え機能 概要設計書

## 目的

チャット画面の吹き出し形状を「四角」と「角削り」から選択できる機能の技術的な設計概要を示す。

## アーキテクチャ

### レイヤー構成

本機能は以下の3層アーキテクチャで実装する：

1. **UI Layer** - ユーザーインターフェース
   - 吹き出しウィジェット（HomeScreen内）
   - 設定画面（SettingsScreen）
   - デザイン選択ダイアログ

2. **Repository Layer** - データ永続化
   - ChatBubbleDesignRepository

3. **Data Layer** - ストレージ
   - SharedPreferences

データフローは、UI Layer → Repository Layer → Data Layer の順で、Riverpodの状態管理により双方向に連携する。

## 主要コンポーネント

### 1. ChatBubbleDesign（ドメインモデル）

**配置**: `client/lib/data/model/chat_bubble_design.dart`

**役割**: デザインタイプを表すenum

**内容**:
- `square`: 四角デザイン
- `rounded`: 角削りデザイン

**特徴**:
- UIに依存しない純粋なドメインモデル
- borderRadiusやdisplayNameなどのUI関連プロパティは持たない
- Dart標準のenumのみを使用

### 2. ChatBubbleDesignExtension（UI拡張）

**配置**: `client/lib/ui/component/chat_bubble_design_extension.dart`

**役割**: ChatBubbleDesignにUI関連の機能を拡張

**提供機能**:
- `borderRadius`: 各デザインに対応するBorderRadiusを返す
  - square → BorderRadius.circular(2)
  - rounded → BorderRadius.circular(16)
- `displayName`: UI表示用の日本語名を返す
  - square → "四角"
  - rounded → "角削り"

**設計意図**:
- 関心の分離：データモデルとUIロジックを分離
- 依存関係の明確化：data/modelはFlutter UIに依存しない
- テスタビリティ：モデル層のテストがUI非依存
- 再利用性：同じモデルを異なるUI実装で使用可能

### 3. ChatBubbleDesignRepository（永続化）

**配置**: `client/lib/data/repository/chat_bubble_design_repository.dart`

**役割**: デザイン設定の読み込みと保存

**主要機能**:
- `build()`: SharedPreferencesから設定を読み込み、デフォルトはsquare
- `save(design)`: 選択されたデザインをSharedPreferencesに保存

**実装方式**:
- Riverpodの@riverpodアノテーション
- AsyncValueで非同期状態を管理
- enum.nameを文字列として保存

### 4. PreferenceKey拡張

**配置**: `client/lib/data/model/preference_key.dart`

**変更内容**: enumに`chatBubbleDesign`を追加

**保存形式**:
- キー: "chatBubbleDesign"
- 値: "square" または "rounded"（enum.name）

### 5. 吹き出しウィジェット更新

**配置**: `client/lib/ui/feature/home/home_screen.dart`

**変更対象**:
- `_UserChatBubble`: ユーザーの送信メッセージ吹き出し
- `_AiChatBubble`: AIの返信メッセージ吹き出し
- `_AppChatBubble`: アプリからのシステムメッセージ吹き出し

**実装方法**:
- ref.watchでChatBubbleDesignRepositoryを監視
- design.borderRadiusをBoxDecorationに適用
- 固定値BorderRadius.circular(2)を動的な値に変更

### 6. デザイン選択ダイアログ

**配置**: `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart`

**機能**:
- 2つのデザインをRadioListTileで表示
- 各デザインのプレビューを表示
- OK/キャンセルボタン

**動作**:
- 初期値として現在のデザインを表示
- OKタップでRepositoryに保存
- キャンセルタップで変更を破棄

### 7. 設定画面の更新

**配置**: `client/lib/ui/feature/settings/settings_screen.dart`

**追加内容**:
- "表示設定"セクションを追加
- "吹き出しデザイン"ListTileを追加
  - アイコン: Icons.chat_bubble_outline
  - サブタイトルに現在のデザイン名を表示
  - タップでデザイン選択ダイアログを表示

## データフロー

### アプリ起動時

1. ChatBubbleDesignRepositoryがbuildされる
2. SharedPreferencesから保存値を読み込み
3. 値が存在しない場合はsquareをデフォルトとして返す
4. 吹き出しウィジェットがref.watchで値を取得
5. design.borderRadiusをBoxDecorationに適用

### デザイン変更時

1. ユーザーが設定画面の「吹き出しデザイン」をタップ
2. デザイン選択ダイアログを表示
3. ユーザーがデザインを選択して「OK」をタップ
4. Repository.save()でSharedPreferencesに保存
5. Riverpodのstateを更新
6. ref.watchしている全ウィジェットが自動的に再ビルド
7. 新しいborderRadiusが適用される

## 影響範囲

### 新規作成ファイル（4ファイル）

1. `client/lib/data/model/chat_bubble_design.dart` - デザインタイプenum
2. `client/lib/ui/component/chat_bubble_design_extension.dart` - UI拡張
3. `client/lib/data/repository/chat_bubble_design_repository.dart` - 永続化
4. `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart` - 選択UI

### 変更ファイル（3ファイル）

1. `client/lib/data/model/preference_key.dart` - enumに1行追加
2. `client/lib/ui/feature/home/home_screen.dart` - 3箇所の吹き出し更新
3. `client/lib/ui/feature/settings/settings_screen.dart` - UI追加

### 変更内容詳細

| コンポーネント | 変更内容 |
|------------|---------|
| _UserChatBubble | BorderRadius.circular(2) → design.borderRadius |
| _AiChatBubble | BorderRadius.circular(2) → design.borderRadius |
| _AppChatBubble | BorderRadius.circular(2) → design.borderRadius |

## 実装手順

### Phase 1: モデル層（UI非依存）

1. ChatBubbleDesign enumを作成（squareとroundedのみ）
2. PreferenceKeyにchatBubbleDesignを追加
3. ChatBubbleDesignRepositoryを実装
4. リポジトリの単体テストを作成

### Phase 2: UI層の拡張

5. ChatBubbleDesignExtensionを作成
   - borderRadiusプロパティを実装
   - displayNameプロパティを実装
6. 拡張のテストを作成

### Phase 3: 設定画面

7. デザイン選択ダイアログを実装
   - displayNameを使用
   - borderRadiusでプレビュー表示
8. SettingsScreenにUIを追加
9. ダイアログのウィジェットテストを作成

### Phase 4: チャット画面

10. _UserChatBubbleを更新（design.borderRadiusを使用）
11. _AiChatBubbleを更新
12. _AppChatBubbleを更新

### Phase 5: テストと仕上げ

13. dart formatでフォーマット
14. dart fix --applyでlinter自動修正
15. 全テストの実行と確認
16. 手動での動作確認

## 非機能要件への対応

### NFR-1: パフォーマンス（1秒以内の反映）

**実現方法**:
- SharedPreferencesの読み書き: 10-50ms
- Riverpodのstate更新: 数ms（同期的）
- ウィジェット再ビルド: 16ms（1フレーム）
- 合計: 約100ms以内で実現

**最適化**:
- ref.watchにより必要な部分のみ再ビルド
- BorderRadiusは軽量オブジェクト

### NFR-2: 一貫性（全吹き出しで統一）

**実現方法**:
- 単一の真実の源（ChatBubbleDesignRepository）
- 全ウィジェットが同じプロバイダーを監視
- design.borderRadiusで一貫した値を保証

**制御範囲**:
- borderRadiusプロパティのみを動的変更
- color、padding等の他要素は既存のまま

### NFR-3: 拡張性（3ファイル以内、50行以内）

**実現方法**:
- enumベースの設計
- ChatBubbleDesign.valuesで自動対応

**新デザイン追加時の変更**:
- モデル層: enum値を1行追加
- UI層: switch caseに2行追加（borderRadius、displayName）
- 合計: 2ファイル、3行のみ

## テスト戦略

### 単体テスト

**ChatBubbleDesignRepositoryのテスト**:
- デフォルト値がsquareであることを確認
- 保存・読み込みが正しく動作することを確認
- 不正な値の場合にsquareにフォールバックすることを確認

### ウィジェットテスト

**デザイン選択ダイアログのテスト**:
- 2つの選択肢が表示されること
- ラジオボタンの選択が正しく動作すること
- OK/キャンセルボタンの動作を確認

**吹き出しウィジェットのテスト**:
- デザインが正しく適用されること
- デザイン変更時に再ビルドされること

### 統合テスト

**パフォーマンス検証（NFR-1）**:
- デザイン変更から画面反映までの時間を計測
- 1秒以内に反映されることを確認
- 100件のメッセージがあっても同様のパフォーマンスを維持

**一貫性検証（NFR-2）**:
- 全ての吹き出しに同じデザインが適用されること
- 他のデザイン要素（色、サイズ）に影響がないこと

**拡張性検証（NFR-3）**:
- 新しいデザインタイプの追加が容易であること
- 変更ファイル数と変更行数を確認

**永続化検証**:
- アプリ再起動後も設定が保持されること

## エラーハンドリング

### SharedPreferences読み込みエラー

**対応**: デフォルト値（square）を使用し、エラーログを出力するがアプリは正常動作

### 不正な保存値

**対応**: enum.valuesから検索し、見つからない場合はorElseでデフォルト値を返す

## 現状の制限事項への対応方針

### 対象範囲の制限

**制限**: ポインター（矢印）と提案カードは対象外

**将来の対応**:
- ポインター: designパラメータを追加し、角削り時は曲線描画
- 提案カード: ConsumerWidgetに変更し、design.borderRadiusを使用

### デザインタイプの制限

**制限**: 2種類のみ

**将来の拡張**:
- extraRounded（超角削り）: BorderRadius.circular(24)
- pill（ピル型）: BorderRadius.circular(999)
- asymmetric（非対称）: BorderRadius.only指定

### UI/UXの制限

**制限**: アニメーションなし

**将来の対応**:
- ContainerをAnimatedContainerに変更
- duration: 300ms、curve: Curves.easeInOut
- 変更: 3箇所、各2行（計6行）

### 機能の制限

**制限**: 色、サイズ等のカスタマイズ不可

**将来の対応**:
- ChatBubbleStyleクラスを導入
- 別リポジトリで管理
- デザイン設定と独立して動作

## セキュリティとプライバシー

- SharedPreferencesに保存される値は端末内のみ
- enum.nameを使用し型安全性を確保
- ユーザーデータは含まれず、プライバシーへの影響なし

## アクセシビリティ

- デザイン変更は視覚的変更のみ
- スクリーンリーダーの読み上げに影響なし
- コントラスト比は変更前後で同じ
- タップ領域のサイズは不変

## 関連ドキュメント

- [要件定義書: チャット吹き出しデザイン切り替え](../spec/switch-design-feature.md)
- [SharedPreferences使用時の設計方法](../how-to-design-when-using-shared-preferences.md)
- [Reward機能仕様書](../spec/reward-feature.md) - SharedPreferences使用の参考例
