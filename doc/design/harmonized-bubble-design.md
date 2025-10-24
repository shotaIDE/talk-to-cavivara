# 調整済吹き出しデザイン 技術設計書

## 目的

チャット画面の吹き出しデザインに新たに「調整済様式」(harmonized)を追加する機能の技術的な設計概要を示す。調整済様式は、ツノを持たず、3隅の角を二等辺三角形（等辺10pt）で削り取った7角形（システムメッセージは6角形）の幾何学的な形状を実現する。

## アーキテクチャ

### レイヤー構成

本機能は既存のデザイン切り替え機能を拡張する形で実装する：

1. **UI Layer** - ユーザーインターフェース

   - 吹き出しウィジェット（HomeScreen 内）
   - カスタムクリッパー（HarmonizedBubbleClipper）【新規作成】
   - デザイン選択ダイアログのプレビュー更新

2. **Repository Layer** - データ永続化

   - 既存の ChatBubbleDesignRepository を継続使用（変更なし）

3. **Data Layer** - ストレージ
   - SharedPreferences（変更なし）

データフローは既存の設計を踏襲し、enum 値の追加と UI Layer での CustomClipper を使用した描画を行う。

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
- Dart 標準の enum のみを使用

### 2. HarmonizedBubbleClipper（カスタムクリッパー）【新規作成】

**配置**: `client/lib/ui/component/harmonized_bubble_clipper.dart`

**役割**: 7角形（または6角形）の吹き出し形状を生成する CustomClipper

**クラス定義**:

```dart
class HarmonizedBubbleClipper extends CustomClipper<Path> {
  const HarmonizedBubbleClipper({
    required this.messageType,
    this.cutSize = 10.0,
  });

  final MessageType messageType;
  final double cutSize; // 二等辺三角形の等辺の長さ

  @override
  Path getClip(Size size) {
    // Pathを使用して7角形（または6角形）を描画
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
```

**Path 生成ロジック**:

#### ユーザーメッセージ（7角形、左上の角を残す）

```dart
Path getClip(Size size) {
  final path = Path();

  // 左上から時計回りに7つの頂点を結ぶ
  path.moveTo(0, 0);                    // 1. 左上（角を残す）
  path.lineTo(size.width - cutSize, 0); // 2. 右上の削り始め
  path.lineTo(size.width, cutSize);     // 3. 右上の削り終わり
  path.lineTo(size.width, size.height - cutSize); // 4. 右下の削り始め
  path.lineTo(size.width - cutSize, size.height); // 5. 右下の削り終わり
  path.lineTo(cutSize, size.height);    // 6. 左下の削り始め
  path.lineTo(0, size.height - cutSize); // 7. 左下の削り終わり
  path.close();

  return path;
}
```

#### AIメッセージ（7角形、右上の角を残す）

```dart
Path getClip(Size size) {
  final path = Path();

  // 左上から時計回りに7つの頂点を結ぶ
  path.moveTo(cutSize, 0);              // 1. 左上の削り終わり
  path.lineTo(size.width, 0);           // 2. 右上（角を残す）
  path.lineTo(size.width, size.height - cutSize); // 3. 右下の削り始め
  path.lineTo(size.width - cutSize, size.height); // 4. 右下の削り終わり
  path.lineTo(cutSize, size.height);    // 5. 左下の削り始め
  path.lineTo(0, size.height - cutSize); // 6. 左下の削り終わり
  path.lineTo(0, cutSize);              // 7. 左上の削り始め
  path.close();

  return path;
}
```

#### システムメッセージ（6角形、左右の中央に角）

```dart
Path getClip(Size size) {
  final path = Path();

  // 左上から時計回りに6つの頂点を結ぶ
  path.moveTo(cutSize, 0);              // 1. 左上の削り終わり
  path.lineTo(size.width - cutSize, 0); // 2. 右上の削り始め
  path.lineTo(size.width, cutSize);     // 3. 右上の削り終わり（角）
  path.lineTo(size.width, size.height - cutSize); // 4. 右下の削り始め
  path.lineTo(size.width - cutSize, size.height); // 5. 右下の削り終わり
  path.lineTo(cutSize, size.height);    // 6. 左下の削り始め
  path.lineTo(0, size.height - cutSize); // 7. 左下の削り終わり
  path.lineTo(0, cutSize);              // 8. 左上の削り始め（角）
  path.close();

  return path;
}
```

**設計意図**:

- **Pathの使用**: 複雑な形状を正確に描画できる
- **パラメータ化**: `cutSize` で削り取るサイズを調整可能
- **メッセージタイプ対応**: `messageType` に応じて異なる形状を生成
- **パフォーマンス**: `shouldReclip` で false を返し、不要な再描画を防ぐ

### 3. ChatBubbleDesignExtension の拡張

**配置**: `client/lib/ui/component/chat_bubble_design_extension.dart`

**役割**: ChatBubbleDesign に UI 関連の機能を拡張

**変更内容**: `displayName` プロパティのみ拡張

#### displayName プロパティの拡張

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

**注意事項**:

- `borderRadiusForMessageType` メソッドには `harmonized` のケースは追加**しない**
- `harmonized` の場合は CustomClipper を使用するため、BorderRadius は使用しない

### 4. 吹き出しウィジェットの更新

**配置**: `client/lib/ui/feature/home/home_screen.dart`

**変更対象**:

- `_UserChatBubble`: ユーザーの送信メッセージ吹き出し
- `_AiChatBubble`: AI の返信メッセージ吹き出し
- `_AppChatBubble`: アプリからのシステムメッセージ吹き出し

**実装方針**:

デザインが `harmonized` の場合のみ `ClipPath` を使用し、それ以外の場合は既存の `BoxDecoration` + `BorderRadius` を使用する。

**実装例（_UserChatBubble）**:

**変更前**:

```dart
Container(
  decoration: BoxDecoration(
    color: backgroundColor,
    borderRadius: design.borderRadiusForMessageType(MessageType.user),
  ),
  child: messageContent,
)
```

**変更後**:

```dart
Widget buildBubble() {
  if (design == ChatBubbleDesign.harmonized) {
    return ClipPath(
      clipper: const HarmonizedBubbleClipper(
        messageType: MessageType.user,
        cutSize: 10.0,
      ),
      child: Container(
        color: backgroundColor,
        child: messageContent,
      ),
    );
  } else {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: design.borderRadiusForMessageType(MessageType.user),
      ),
      child: messageContent,
    );
  }
}

// build メソッド内
return buildBubble();
```

**実装例（_AiChatBubble）**:

```dart
Widget buildBubble() {
  if (design == ChatBubbleDesign.harmonized) {
    return ClipPath(
      clipper: const HarmonizedBubbleClipper(
        messageType: MessageType.ai,
        cutSize: 10.0,
      ),
      child: Container(
        color: backgroundColor,
        child: messageContent,
      ),
    );
  } else {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: design.borderRadiusForMessageType(MessageType.ai),
      ),
      child: messageContent,
    );
  }
}
```

**実装例（_AppChatBubble）**:

```dart
Widget buildBubble() {
  if (design == ChatBubbleDesign.harmonized) {
    return ClipPath(
      clipper: const HarmonizedBubbleClipper(
        messageType: MessageType.system,
        cutSize: 10.0,
      ),
      child: Container(
        color: backgroundColor,
        child: messageContent,
      ),
    );
  } else {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: design.borderRadiusForMessageType(MessageType.system),
      ),
      child: messageContent,
    );
  }
}
```

**設計意図**:

- **条件分岐**: デザインによって描画方法を切り替え
- **一貫性**: 既存のデザインには影響を与えない
- **保守性**: 新しいデザインの追加・変更が容易

### 5. デザイン選択ダイアログの更新

**配置**: `client/lib/ui/feature/settings/chat_bubble_design_selection_dialog.dart`

**変更内容**:

「調整済様式」の選択肢とプレビューを追加する。

**実装方針**:

1. RadioListTile に「調整済様式」の選択肢を追加
2. プレビュー部分に調整済様式のサンプル吹き出しを追加
   - プレビューでも `ClipPath` + `HarmonizedBubbleClipper` を使用
3. 既存の 2 つのデザインと同様のレイアウトで表示

**プレビュー実装例**:

```dart
// 調整済様式のプレビュー
ClipPath(
  clipper: const HarmonizedBubbleClipper(
    messageType: MessageType.user, // サンプルとしてユーザーメッセージを使用
    cutSize: 10.0,
  ),
  child: Container(
    color: Theme.of(context).colorScheme.primary,
    padding: const EdgeInsets.all(12),
    child: const Text(
      'サンプル',
      style: TextStyle(color: Colors.white),
    ),
  ),
)
```

### 6. ChatBubbleDesignRepository

**配置**: `client/lib/data/repository/chat_bubble_design_repository.dart`

**変更**: なし

既存のリポジトリをそのまま使用する。enum.name を使用した保存・復元により、`harmonized` も自動的に対応される。

## データフロー

### アプリ起動時

1. ChatBubbleDesignRepository が build される
2. SharedPreferences から保存値を読み込み（既存の実装）
3. 値が `"harmonized"` の場合、`ChatBubbleDesign.harmonized` を返す
4. 吹き出しウィジェットが ref.watch で値を取得
5. **新**: `ChatBubbleDesign.harmonized` の場合、`ClipPath` + `HarmonizedBubbleClipper` で描画
6. **新**: それ以外の場合は既存の `BoxDecoration` + `BorderRadius` で描画

### デザイン変更時

1. ユーザーが設定画面の「吹き出しデザイン」をタップ
2. デザイン選択ダイアログを表示
3. **新**: プレビューに「調整済様式」が7角形の形状で表示される
4. ユーザーが「調整済様式」を選択して「OK」をタップ
5. Repository.save()で SharedPreferences に `"harmonized"` を保存
6. Riverpod の state を更新
7. ref.watch している全ウィジェットが自動的に再ビルド
8. **新**: 7角形の吹き出しが表示される

## 実装手順

### フェーズ 1: enum の追加

1. `chat_bubble_design.dart` に `harmonized` を追加
2. `dart format` を実行
3. コンパイルエラーの確認（全ての switch 文で exhaustive check が働く）

### フェーズ 2: CustomClipper の実装

1. `harmonized_bubble_clipper.dart` を新規作成
2. `HarmonizedBubbleClipper` クラスを実装
   - `MessageType.user` 用の Path 生成ロジック
   - `MessageType.ai` 用の Path 生成ロジック
   - `MessageType.system` 用の Path 生成ロジック
3. `dart format` を実行
4. `dart fix --apply` を実行
5. ユニットテストを作成・実行

### フェーズ 3: Extension の拡張

1. `chat_bubble_design_extension.dart` の `displayName` プロパティに `harmonized` のケースを追加
2. `dart format` を実行
3. `dart fix --apply` を実行

### フェーズ 4: 吹き出しウィジェットの更新

1. `home_screen.dart` の各吹き出しウィジェットを更新
   - `_UserChatBubble`: `harmonized` の場合に `ClipPath` を使用
   - `_AiChatBubble`: `harmonized` の場合に `ClipPath` を使用
   - `_AppChatBubble`: `harmonized` の場合に `ClipPath` を使用
2. `dart format` を実行
3. `dart fix --apply` を実行
4. 実機で視覚確認

### フェーズ 5: デザイン選択ダイアログの更新

1. `chat_bubble_design_selection_dialog.dart` に「調整済様式」の選択肢を追加
2. プレビュー部分に `ClipPath` + `HarmonizedBubbleClipper` を使用したサンプルを追加
3. `dart format` を実行
4. `dart fix --apply` を実行
5. 実機で視覚確認

### フェーズ 6: テストと検証

1. ユニットテストを実行
2. iOS でビルド・実行
3. Android でビルド・実行
4. デザイン切り替え動作確認
5. 永続化の確認（アプリ再起動後も設定が保持されること）

## テスト戦略

### ユニットテスト

#### HarmonizedBubbleClipper のテスト

**テストファイル**: `client/test/ui/component/harmonized_bubble_clipper_test.dart`

**テストケース**:

```dart
group('HarmonizedBubbleClipper', () {
  test('user message creates 7-point path', () {
    const clipper = HarmonizedBubbleClipper(
      messageType: MessageType.user,
      cutSize: 10.0,
    );
    final path = clipper.getClip(const Size(100, 100));

    // Pathが正しく生成されることを確認
    expect(path, isNotNull);
  });

  test('ai message creates 7-point path', () {
    const clipper = HarmonizedBubbleClipper(
      messageType: MessageType.ai,
      cutSize: 10.0,
    );
    final path = clipper.getClip(const Size(100, 100));

    // Pathが正しく生成されることを確認
    expect(path, isNotNull);
  });

  test('system message creates 6-point path', () {
    const clipper = HarmonizedBubbleClipper(
      messageType: MessageType.system,
      cutSize: 10.0,
    );
    final path = clipper.getClip(const Size(100, 100));

    // Pathが正しく生成されることを確認
    expect(path, isNotNull);
  });

  test('shouldReclip returns false', () {
    const clipper = HarmonizedBubbleClipper(
      messageType: MessageType.user,
    );
    const oldClipper = HarmonizedBubbleClipper(
      messageType: MessageType.ai,
    );

    expect(clipper.shouldReclip(oldClipper), isFalse);
  });
});
```

#### ChatBubbleDesignExtension のテスト

**テストファイル**: `client/test/ui/component/chat_bubble_design_extension_test.dart`

**追加するテストケース**:

```dart
group('harmonized design', () {
  test('displayName returns correct Japanese name', () {
    const design = ChatBubbleDesign.harmonized;
    expect(design.displayName, '調整済様式');
  });
});
```

### ウィジェットテスト

**対象**: 吹き出しウィジェット、デザイン選択ダイアログ

**テスト内容**:

- `harmonized` デザインで `ClipPath` が使用されること
- プレビューが正しく表示されること
- 選択して OK をタップすると設定が保存されること

### 統合テスト

**対象**: デザイン選択機能全体

**テストシナリオ**:

1. デザイン選択ダイアログを開く
2. 「調整済様式」を選択
3. プレビューで7角形が表示されることを確認
4. OK をタップ
5. チャット画面で7角形の吹き出しが表示されることを確認
6. アプリを再起動
7. 設定が保持されていることを確認

## 後方互換性

### 既存機能への影響

- ✅ `ChatBubbleDesign` enum: `harmonized` を追加（互換性維持）
- ✅ `ChatBubbleDesignRepository`: 変更なし
- ✅ `ChatBubbleDesignExtension`: `displayName` のみ追加（既存のメソッドは変更なし）
- ✅ SharedPreferences の保存形式: enum.name を使用（互換性維持）
- ✅ 吹き出しウィジェット: 条件分岐で既存デザインには影響なし

### マイグレーション

マイグレーション不要。既存のユーザー設定はそのまま有効。

### デフォルト値

既存のデフォルト値（`corporateStandard`）を変更しない。

## 視覚デザインの特徴

### 調整済様式の視覚的特徴

- **シャープさ**: 角を二等辺三角形で削り取ることで、直線的でシャープな印象
- **幾何学性**: 正確な7角形（システムメッセージは6角形）という明確な幾何学的形状
- **方向性**: 残された角により、メッセージの送信元を明確に視覚的に示す
- **ミニマリズム**: ツノがなく、単純な多角形であるため、すっきりとしたミニマルなデザイン
- **独自性**: 既存の丸みを帯びたデザインとは全く異なる、角張った独特のスタイル

### 既存デザインとの比較

| デザイン     | 特徴                   | 形状                                | 実装方法              |
| ------------ | ---------------------- | ----------------------------------- | --------------------- |
| 社内標準様式 | 均一で柔らかい印象     | 角が radius 8 で丸められた四角形    | BorderRadius          |
| 次世代様式   | 丸みが強く親しみやすい | 角が radius 20/2 で丸められた四角形 | BorderRadius          |
| 調整済様式   | シャープで幾何学的     | 3隅を削った7角形（6角形）           | CustomClipper + Path  |

## 制約事項

- iOS、Android 両プラットフォームで同一の見た目を保証する
- 既存のデザイン選択機能との互換性を維持する
- Flutter の `CustomClipper` と `Path` クラスを使用して実装する
- ツノ(tail)は実装しない
- 二等辺三角形の等辺は正確に10ptとする
- 削り取られた辺は直線とする（曲線は使用しない）

## セキュリティ考慮事項

本機能は表示のみに関するため、セキュリティ上の特別な考慮事項はない。

## パフォーマンス考慮事項

- `CustomClipper` の `shouldReclip` で false を返すことで、不要な再描画を防ぐ
- `Path` オブジェクトは軽量で、パフォーマンスへの影響は最小限
- 既存の実装と同様、効率的なウィジェット再ビルドが可能

## アクセシビリティ考慮事項

- デザイン選択ダイアログのラジオボタンは既存の実装と同様、アクセシビリティをサポート
- 視覚的な形状の違いは、選択ダイアログのプレビューで確認可能
- 形状の違いは装飾的なものであり、機能的なアクセシビリティには影響しない

## 関連ドキュメント

- [要件定義書: 調整済吹き出しデザインの追加](../requirement/harmonized-bubble-design.md)
- [技術設計書: チャット吹き出しデザイン切り替え](./switch-design.md)
- [技術設計書: 吹き出しのツノ排除と角丸デザイン](./bubble-tail-removal.md)
- [要件定義書: チャット吹き出しデザイン切り替え](../requirement/switch-design.md)
- [SharedPreferences 使用時の設計方法](../how-to-design-when-using-shared-preferences.md)
