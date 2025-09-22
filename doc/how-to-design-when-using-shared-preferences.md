# SharedPreferences を利用する際の設計ガイド

このドキュメントでは、本アプリケーションにおいて SharedPreferences を使用したデータ永続化のアーキテクチャ設計について説明します。

## アーキテクチャ概要

### レイヤー構成

```
UI Layer (Screen/Widget)
├── Presenter Layer (ui/feature/**/presenter)
└── Repository Layer (data/repository/)
```

### 設計原則

- Repository Pattern: データアクセスロジックを抽象化し、ビジネスロジックから分離
- 単一責任: 各レイヤーが明確な責務を持つ
- 依存関係の逆転: 上位レイヤーが下位レイヤーのインターフェースに依存

## Repository Layer の設計

### 目的

Repository レイヤーは、データの永続化を抽象化し、以下の責務を持ちます：

- データアクセスの統一インターフェース提供
- ビジネスロジックからデータストレージの詳細を隠蔽
- テスタビリティの向上（モック化が容易）

### 実装例：LastTalkedCavivaraRepository

**推奨パターン（データを直接返却する Provider + Notifier）:**

```dart
part 'last_talked_cavivara_id_repository.g.dart';

@riverpod
class LastTalkedCavivaraId extends _$LastTalkedCavivaraId {
  @override
  Future<String?> build() {
    final preferenceService = ref.read(preferenceServiceProvider);
    return preferenceService.getString(
      PreferenceKey.lastTalkedCavivaraId,
    );
  }

  Future<void> updateId(String cavivaraId) async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setString(
      PreferenceKey.lastTalkedCavivaraId,
      value: cavivaraId,
    );

    state = AsyncValue.data(cavivaraId);
  }
}
```

**設計原則:**

1. **Repository クラス**: データアクセス処理を定義
2. **Provider**: データを直接返却（Repository インスタンスを返さない）
3. **Notifier**: 変更操作を管理し、保存後に State 更新

## Presenter Layer での使用方法

Presenter Layer では、Repository を使用してビジネスロジックを実装します。

### 実装例：Presenter での新しいパターンの使用

```dart
/// アプリ初期画面の決定ロジック
@riverpod
Future<AppInitialRoute> appInitialRoute(Ref ref) async {
  // ... 他の処理 ...

  // データの取得: Providerから直接取得
  final lastTalkedCavivaraId = await ref.read(
    lastTalkedCavivaraIdProvider.future,
  );
  if (lastTalkedCavivaraId != null) {
    return AppInitialRoute.home(cavivaraId: lastTalkedCavivaraId);
  }

  // ... 他の処理 ...
}
```
