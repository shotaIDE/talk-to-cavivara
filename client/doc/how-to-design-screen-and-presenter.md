# Screen と Presenter の設計ガイド

このドキュメントでは、Flutter アプリケーションにおける Screen と Presenter の適切な設計パターンについて説明します。

## 基本原則

### アーキテクチャの分離

- UI 層（Screen）: ウィジェットの構築とユーザーインタラクションの処理
- プレゼンテーション層（Presenter）: ビジネスロジックと状態管理
- データ層（Repository/Service）: データの取得・保存

### 責任の分担

- Screen は Presenter を通じてビジネスロジックにアクセス
- 直接的なデータ層への呼び出しは Presenter に集約
- UI の状態変更は Presenter が管理

## 実践例: didUpdateWidget の処理

### 問題のケース

```dart
// ❌ 悪い例: ScreenからUsecaseを直接呼び出し
class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cavivaraId != widget.cavivaraId) {
      unawaited(
        ref
            .read(lastTalkedCavivaraIdProvider.notifier)
            .updateCavivaraId(widget.cavivaraId),
      );
    }
  }
}
```

### 改善されたアプローチ

```dart
// ✅ 良い例: Presenter経由でのアクセス
class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cavivaraId != widget.cavivaraId) {
      unawaited(
        ref.read(updateLastTalkedCavivaraIdProvider(widget.cavivaraId).future),
      );
    }
  }
}
```

## Presenter 側の実装

### Riverpod プロバイダーの定義

```dart
/// 最後に話したカヴィヴァラIDを更新する
@riverpod
Future<void> updateLastTalkedCavivaraId(Ref ref, String cavivaraId) async {
  await ref
      .read(lastTalkedCavivaraIdProvider.notifier)
      .updateCavivaraId(cavivaraId);
}
```
