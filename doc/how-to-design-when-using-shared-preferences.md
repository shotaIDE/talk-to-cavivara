# SharedPreferences を利用する際の設計ガイド

このドキュメントでは、本アプリケーションにおいて SharedPreferences を使用したデータ永続化のアーキテクチャ設計について説明します。

## アーキテクチャ概要

### レイヤー構成

```
UI Layer (Screen/Widget)
├── Presenter Layer (ui/feature/**/presenter)
├── Repository Layer (data/repository/)
└── Service Layer (data/service/)
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

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_talked_cavivara_repository.g.dart';

@riverpod
LastTalkedCavivaraRepository lastTalkedCavivaraRepository(Ref ref) {
  return LastTalkedCavivaraRepository(
    preferenceService: ref.read(preferenceServiceProvider),
  );
}

/// 最後に会話したカヴィヴァラIDの永続化を管理するリポジトリ
class LastTalkedCavivaraRepository {
  const LastTalkedCavivaraRepository({
    required this.preferenceService,
  });

  final PreferenceService preferenceService;

  /// 最後に会話したカヴィヴァラIDを取得する
  Future<String?> get() {
    return preferenceService.getString(PreferenceKey.lastTalkedCavivaraId);
  }

  /// 最後に会話したカヴィヴァラIDを保存する
  Future<void> save(String cavivaraId) async {
    await preferenceService.setString(
      PreferenceKey.lastTalkedCavivaraId,
      value: cavivaraId,
    );
  }
}
```

## Presenter Layer での使用方法

Presenter Layer では、Repository を使用してビジネスロジックを実装します。

### 実装例：Presenter での Repository 使用

```dart
/// 最後に話したカヴィヴァラIDを更新する
@riverpod
Future<void> updateLastTalkedCavivaraId(Ref ref, String cavivaraId) async {
  final repository = ref.read(lastTalkedCavivaraRepositoryProvider);
  await repository.save(cavivaraId);
}

/// アプリ初期画面の決定ロジック
@riverpod
Future<AppInitialRoute> appInitialRoute(Ref ref) async {
  // ... 他の処理 ...

  final repository = ref.read(lastTalkedCavivaraRepositoryProvider);
  final lastTalkedCavivaraId = await repository.get();
  if (lastTalkedCavivaraId != null) {
    return AppInitialRoute.home(cavivaraId: lastTalkedCavivaraId);
  }

  // ... 他の処理 ...
}
```

## Service Layer の設計

Service Layer は、外部リソース（SharedPreferences、API、データベースなど）への低レベルアクセスを担当します。

### PreferenceService の実装例

```dart
@riverpod
PreferenceService preferenceService(Ref ref) {
  return PreferenceService();
}

class PreferenceService {
  Future<String?> getString(PreferenceKey key) {
    final preferences = SharedPreferencesAsync();
    return preferences.getString(key.name);
  }

  Future<void> setString(PreferenceKey key, {required String value}) async {
    final preferences = SharedPreferencesAsync();
    await preferences.setString(key.name, value);
  }

  Future<List<String>?> getStringList(PreferenceKey key) {
    final preferences = SharedPreferencesAsync();
    return preferences.getStringList(key.name);
  }

  Future<void> setStringList(
    PreferenceKey key, {
    required List<String> value,
  }) async {
    final preferences = SharedPreferencesAsync();
    await preferences.setStringList(key.name, value);
  }
}
```

## 設計メリット

### 1. テスタビリティの向上

Repository 層を抽象化することで、テスト時にモックオブジェクトを注入しやすくなります。

```dart
// テスト例
testWidgets('should save cavivara id', (tester) async {
  final mockRepository = MockLastTalkedCavivaraRepository();

  // Repository をモック化してテスト
  // ...
});
```

### 2. 責務の明確化

- **Repository**: データアクセスの抽象化
- **Service**: 外部リソースへの低レベルアクセス
- **Presenter**: ビジネスロジックと UI 状態管理

### 3. 変更に対する柔軟性

データストレージの実装（SharedPreferences → SQLite 等）が変更になっても、Repository 層のインターフェースが同じであれば、Presenter 層は影響を受けません。

## 実装ガイドライン

### 1. Repository 命名規則

```
{データ型}Repository
例: LastTalkedCavivaraRepository, UserProfileRepository
```

### 2. メソッド命名規則

- **取得**: `get()`, `getById(String id)`, `getAll()`
- **保存**: `save(T data)`, `saveAll(List<T> data)`
- **削除**: `delete()`, `deleteById(String id)`, `deleteAll()`

### 3. ファイル配置

```
lib/
├── data/
│   ├── repository/
│   │   └── {feature}_repository.dart
│   └── service/
│       └── preference_service.dart
└── ui/
    └── feature/
        └── {feature}/
            └── {feature}_presenter.dart
```

### 4. 依存関係の注入

Repository は Riverpod のコード生成を使用して Provider として定義し、Presenter で使用します。

```dart
// Repository
@riverpod
MyRepository myRepository(Ref ref) {
  return MyRepository(
    preferenceService: ref.read(preferenceServiceProvider),
  );
}

// Presenter
@riverpod
Future<void> doSomething(Ref ref) async {
  final repository = ref.read(myRepositoryProvider);
  await repository.save(data);
}
```

## まとめ

この設計パターンにより：

1. **コードの可読性向上**: 各レイヤーの責務が明確
2. **テスト容易性**: Repository 層のモック化が簡単
3. **保守性向上**: データストレージの変更に対する影響範囲を限定
4. **再利用性**: Repository 層を他の機能でも利用可能

UseCase 層を削除し、Presenter → Repository → Service の 3 層構造にすることで、よりシンプルで保守しやすいアーキテクチャを実現できます。
