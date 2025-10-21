# 調整済吹き出しデザイン 技術設計書

## 目的

チャット画面の吹き出しデザインに新たに「調整済様式」(harmonized)を追加する機能の技術的な設計概要を示す。調整済様式は、ツノを持たず、全ての角を radius 2 で統一的に丸めたシャープで幾何学的な形状を実現する。

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

データフローは既存の設計を踏襲し、enum 値の追加と UI Layer の表示ロジック拡張を行う。

## 主要コンポーネント

### 1. ChatBubbleDesign（ドメインモデル）

**配置**: `client/lib/data/model/chat_bubble_design.dart`

**役割**: デザインタイプを表す enum

**変更内容**: 新しい enum 値を追加

**変更前**:

```dart
enum ChatBubbleDesign {
  corporateStandard,  // 社内標準様式
  nextGeneration,     // 次世代様式
}
```

**変更後**:

```dart
enum ChatBubbleDesign {
  corporateStandard,  // 社内標準様式
  nextGeneration,     // 次世代様式
  harmonized,         // 調整済様式（新規追加）
}
```

**特徴**:

- UI に依存しない純粋なドメインモデル
- borderRadius や displayName などの UI 関連プロパティは持たない
- Dart 標準の enum のみを使用

### 2. ChatBubbleDesignExtension の拡張

**配置**: `client/lib/ui/component/chat_bubble_design_extension.dart`

**役割**: ChatBubbleDesign に UI 関連の機能を拡張

**変更内容**: `harmonized` デザインのケースを追加

#### 2.1 displayName プロパティの拡張

**変更前**:

```dart
String get displayName {
  switch (this) {
    case ChatBubbleDesign.corporateStandard:
      return '社内標準様式';
    case ChatBubbleDesign.nextGeneration:
      return '次世代様式';
  }
}
```

**変更後**:

```dart
String get displayName {
  switch (this) {
    case ChatBubbleDesign.corporateStandard:
      return '社内標準様式';
    case ChatBubbleDesign.nextGeneration:
      return '次世代様式';
    case ChatBubbleDesign.harmonized:
      return '調整済様式';
  }
}
```

#### 2.2 borderRadiusForMessageType メソッドの拡張

**変更前**:

```dart
BorderRadius borderRadiusForMessageType(MessageType messageType) {
  switch (this) {
    case ChatBubbleDesign.corporateStandard:
      return BorderRadius.circular(8);
    case ChatBubbleDesign.nextGeneration:
      switch (messageType) {
        case MessageType.user:
          return const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(2),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          );
        case MessageType.ai:
          return const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          );
        case MessageType.system:
          return BorderRadius.circular(8);
      }
  }
}
```

**変更後**:

```dart
BorderRadius borderRadiusForMessageType(MessageType messageType) {
  switch (this) {
    case ChatBubbleDesign.corporateStandard:
      return BorderRadius.circular(8);
    case ChatBubbleDesign.nextGeneration:
      switch (messageType) {
        case MessageType.user:
          return const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(2),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          );
        case MessageType.ai:
          return const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          );
        case MessageType.system:
          return BorderRadius.circular(8);
      }
    case ChatBubbleDesign.harmonized:
      // 調整済様式: 全ての角を radius 2 で統一
      return BorderRadius.circular(2);
  }
}
```

**角丸の仕様**:

調整済様式では、メッセージタイプに関わらず全ての角を `BorderRadius.circular(2)` で統一する。

- ユーザーメッセージ: `BorderRadius.circular(2)`
- AI メッセージ: `BorderRadius.circular(2)`
- システムメッセージ: `BorderRadius.circular(2)`

**設計意図**:

- **シンプルさ**: 全ての角を同じ radius で統一することで、実装をシンプルに保つ
- **一貫性**: メッセージタイプによらず同じ形状を維持し、視覚的な一貫性を確保
- **幾何学性**: 小さい radius (2) により、シャープで幾何学的な印象を実現

### 3. デザイン選択ダイアログの更新

**配置**: `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart`

**変更内容**:

「調整済様式」の選択肢とプレビューを追加する。

**実装方針**:

1. RadioListTile に「調整済様式」の選択肢を追加
2. プレビュー部分に調整済様式のサンプル吹き出しを追加
3. 既存の 2 つのデザインと同様のレイアウトで表示

**プレビューレイアウト**:

```
調整済様式
┌─────────────────────────────────┐
│   ╱─────────╲                   │  ← サンプル（radius 2 の統一角丸）
│   │ サンプル │                   │
│   ╲─────────╱                   │
└─────────────────────────────────┘
```

### 4. 吹き出しウィジェット

**配置**: `client/lib/ui/feature/home/home_screen.dart`

**変更**: なし

既存の実装で `design.borderRadiusForMessageType(messageType)` を使用しているため、Extension の変更のみで自動的に新しいデザインが適用される。

**既存の実装**:

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

### 5. ChatBubbleDesignRepository

**配置**: `client/lib/data/repository/chat_bubble_design_repository.dart`

**変更**: なし

既存のリポジトリをそのまま使用する。enum.name を使用した保存・復元により、`harmonized` も自動的に対応される。

## データフロー

### アプリ起動時

1. ChatBubbleDesignRepository が build される
2. SharedPreferences から保存値を読み込み（既存の実装）
3. 値が `"harmonized"` の場合、`ChatBubbleDesign.harmonized` を返す
4. 吹き出しウィジェットが ref.watch で値を取得
5. **新**: `ChatBubbleDesign.harmonized` の場合、`borderRadiusForMessageType` は全てのメッセージタイプで `BorderRadius.circular(2)` を返す
6. 新しい角丸仕様が適用される

### デザイン変更時

1. ユーザーが設定画面の「吹き出しデザイン」をタップ
2. デザイン選択ダイアログを表示
3. **新**: プレビューに「調整済様式」が表示される
4. ユーザーが「調整済様式」を選択して「OK」をタップ
5. Repository.save()で SharedPreferences に `"harmonized"` を保存
6. Riverpod の state を更新
7. ref.watch している全ウィジェットが自動的に再ビルド
8. **新**: 調整済様式の角丸仕様が適用される

## 実装手順

### フェーズ 1: enum の追加

1. `chat_bubble_design.dart` に `harmonized` を追加
2. `dart format` を実行
3. コンパイルエラーの確認（全ての switch 文で exhaustive check が働く）

### フェーズ 2: Extension の拡張

1. `chat_bubble_design_extension.dart` の以下のメソッドに `harmonized` のケースを追加:
   - `displayName` プロパティ
   - `borderRadiusForMessageType` メソッド
2. `dart format` を実行
3. `dart fix --apply` を実行
4. ユニットテストを作成・実行

### フェーズ 3: デザイン選択ダイアログの更新

1. `chat_bubble_design_selection_dialog.dart` に「調整済様式」の選択肢を追加
2. プレビュー部分に調整済様式のサンプルを追加
3. `dart format` を実行
4. `dart fix --apply` を実行
5. 実機で視覚確認

### フェーズ 4: テストと検証

1. iOS でビルド・実行
2. Android でビルド・実行
3. デザイン切り替え動作確認
4. 永続化の確認（アプリ再起動後も設定が保持されること）
5. 全てのユニットテストを実行

## テスト戦略

### ユニットテスト

**対象**: `ChatBubbleDesignExtension`

**テストファイル**: `client/test/ui/component/chat_bubble_design_extension_test.dart`

**追加するテストケース**:

```dart
group('harmonized design', () {
  test('returns uniform small radius for all message types', () {
    const design = ChatBubbleDesign.harmonized;

    // 全てのメッセージタイプで同じ radius を返す
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

  test('displayName returns correct Japanese name', () {
    const design = ChatBubbleDesign.harmonized;
    expect(design.displayName, '調整済様式');
  });
});
```

### ウィジェットテスト

**対象**: デザイン選択ダイアログ

**テスト内容**:

- 「調整済様式」の選択肢が表示されること
- プレビューが正しく表示されること
- 選択して OK をタップすると設定が保存されること

### 統合テスト

**対象**: デザイン選択機能全体

**テストシナリオ**:

1. デザイン選択ダイアログを開く
2. 「調整済様式」を選択
3. プレビューで radius 2 の角丸が表示されることを確認
4. OK をタップ
5. チャット画面で新しい角丸が適用されることを確認
6. アプリを再起動
7. 設定が保持されていることを確認

## 後方互換性

### 既存機能への影響

- ✅ `ChatBubbleDesign` enum: `harmonized` を追加（互換性維持）
- ✅ `ChatBubbleDesignRepository`: 変更なし
- ✅ `ChatBubbleDesignExtension`: 新しいケースを追加（既存のケースは変更なし）
- ✅ SharedPreferences の保存形式: enum.name を使用（互換性維持）

### マイグレーション

マイグレーション不要。既存のユーザー設定はそのまま有効。

### デフォルト値

既存のデフォルト値（`corporateStandard`）を変更しない。

## 視覚デザインの特徴

### 調整済様式の視覚的特徴

- **シャープさ**: 全ての角が radius 2 と小さいため、シャープでエッジの効いた印象
- **幾何学性**: 統一された小さい角丸により、構造的で現代的な印象
- **ミニマリズム**: ツノがなく、全ての角が均一であるため、すっきりとしたミニマルなデザイン
- **一貫性**: メッセージタイプによらず同じ形状を維持

### 既存デザインとの比較

| デザイン     | 特徴                   | 角の丸み                                | メッセージタイプごとの差異 |
| ------------ | ---------------------- | --------------------------------------- | -------------------------- |
| 社内標準様式 | 均一で柔らかい印象     | 全て radius 8                           | なし                       |
| 次世代様式   | 丸みが強く親しみやすい | 大部分 radius 20、ツノ相当位置 radius 2 | あり                       |
| 調整済様式   | シャープで幾何学的     | 全て radius 2                           | なし                       |

## 制約事項

- iOS、Android 両プラットフォームで同一の見た目を保証する
- 既存のデザイン選択機能との互換性を維持する
- Flutter の `BorderRadius` クラスの機能範囲内で実装する
- ツノ(tail)は実装しない
- 全ての角を radius 2 で統一する（角ごとに異なる radius は使用しない）

## セキュリティ考慮事項

本機能は表示のみに関するため、セキュリティ上の特別な考慮事項はない。

## パフォーマンス考慮事項

- `BorderRadius.circular(2)` は軽量なオブジェクトであり、パフォーマンスへの影響は最小限
- 既存の実装と同様、効率的なウィジェット再ビルドが可能

## アクセシビリティ考慮事項

- デザイン選択ダイアログのラジオボタンは既存の実装と同様、アクセシビリティをサポート
- 視覚的な形状の違いは、選択ダイアログのプレビューで確認可能

## 関連ドキュメント

- [要件定義書: 調整済吹き出しデザインの追加](../requirement/harmonized-bubble-design.md)
- [技術設計書: チャット吹き出しデザイン切り替え](./switch-design.md)
- [技術設計書: 吹き出しのツノ排除と角丸デザイン](./bubble-tail-removal.md)
- [要件定義書: チャット吹き出しデザイン切り替え](../requirement/switch-design.md)
- [SharedPreferences 使用時の設計方法](../how-to-design-when-using-shared-preferences.md)
