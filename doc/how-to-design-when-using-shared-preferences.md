# SharedPreferences を利用する際の設計ガイド

このドキュメントでは、本アプリケーションにおいて SharedPreferences を使用したデータ永続化のアーキテクチャ設計について説明します。

## アーキテクチャ概要

### レイヤー構成

```
UI Layer (presentation)
├── UseCase Layer (ui/usecase/)
└── Service Layer (data/service/)
```

## UseCase Layer の設計

### 目的

UseCase レイヤーは、UI とビジネスロジックを分離し、単一責任の原則に従って特定のユースケースを実装します。SharedPreferences を使用する場合、以下の責務を持ちます。

- データの読み取り・更新ロジック

### 実装例：LastTalkedCavivaraId

```dart
import 'dart:async';

import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_talked_cavivara_usecase.g.dart';

@riverpod
class LastTalkedCavivaraId extends _$LastTalkedCavivaraId {
  @override
  Future<String?> build() {
    final preferenceService = ref.read(preferenceServiceProvider);
    return preferenceService.getString(PreferenceKey.lastTalkedCavivaraId);
  }

  Future<void> updateCavivaraId(String cavivaraId) async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setString(
      PreferenceKey.lastTalkedCavivaraId,
      value: cavivaraId,
    );
    state = AsyncValue.data(cavivaraId);
  }
}
```

## Service Layer の設計

Service Layer は、外部リソース（SharedPreferences、API、データベースなど）へのアクセスを担当します。

### PreferenceService の実装例

```dart
@riverpod
PreferenceService preferenceService(Ref ref) {
  return PreferenceService();
}

class PreferenceService {
  Future<String?> getString(PreferenceKey key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key.name);
  }

  Future<void> setString(PreferenceKey key, {required String value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key.name, value);
  }
}
```
