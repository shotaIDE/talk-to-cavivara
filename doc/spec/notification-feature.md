# 通知機能仕様書

## 概要

Firebase Remote Config から取得したお知らせ情報をアプリ内で表示する機能。既読管理をローカルに保存し、未読通知がある場合はドロワーメニューとハンバーガーアイコンにバッジを表示する。

## 主要コンポーネント

### Notification ([notification.dart](../../client/lib/data/model/notification.dart))

通知情報を表すドメインモデル。`freezed` を使用して定義する。

```dart
@freezed
class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String title,
    required String body,
    required DateTime publishedAt,
    String? detailUrl,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}
```

プロパティ:

- `id`: 通知の一意識別子
- `title`: 通知タイトル
- `body`: 通知本文(プレーンテキスト)
- `publishedAt`: 公開日時
- `detailUrl`: 詳細 URL(オプション)

### NotificationService ([notification_service.dart](../../client/lib/data/service/notification_service.dart))

Firebase Remote Config から通知情報を取得するサービス。

```dart
@riverpod
class Notifications extends _$Notifications {
  @override
  Future<List<Notification>> build() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final jsonString = remoteConfig.getString('notifications');

    if (jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Notification.fromJson(json as Map<String, dynamic>))
        .toList()
        .sortedBy<num>((notification) => -notification.publishedAt.millisecondsSinceEpoch);
  }
}
```

主要機能:

- Remote Config の `notifications` キーから JSON 配列を取得
- 通知リストを `Notification` オブジェクトに変換
- 公開日時の降順でソート

Firebase Remote Config の設定例:

```json
[
  {
    "id": "notification_001",
    "title": "新機能追加のお知らせ",
    "body": "新しいカヴィヴァラが追加されました。ぜひお話ししてみてください。",
    "publishedAt": "2025-10-14T10:00:00Z",
    "detailUrl": "https://example.com/news/001"
  },
  {
    "id": "notification_002",
    "title": "メンテナンスのお知らせ",
    "body": "10月20日2:00-4:00にメンテナンスを実施します。",
    "publishedAt": "2025-10-13T15:00:00Z"
  }
]
```

### ReadNotificationIdsRepository ([read_notification_ids_repository.dart](../../client/lib/data/repository/read_notification_ids_repository.dart))

既読通知 ID のリストを SharedPreferences で永続化するリポジトリ。

```dart
@riverpod
class ReadNotificationIds extends _$ReadNotificationIds {
  @override
  Future<List<String>> build() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    final ids = await preferenceService.getStringList(
      PreferenceKey.readNotificationIds,
    );
    return ids ?? [];
  }

  Future<void> markAsRead(String notificationId) async {
    final current = await future;
    if (current.contains(notificationId)) {
      return;
    }

    final updated = [...current, notificationId];
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setStringList(
      PreferenceKey.readNotificationIds,
      value: updated,
    );

    state = AsyncValue.data(updated);
  }

  Future<void> resetForDebug() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setStringList(
      PreferenceKey.readNotificationIds,
      value: [],
    );

    state = const AsyncValue.data([]);
  }
}
```

主要メソッド:

- `markAsRead(String notificationId)`: 指定された ID を既読としてマーク
- `resetForDebug()`: デバッグ用のリセット機能

### UnreadNotificationCountProvider ([notification_presenter.dart](../../client/lib/ui/feature/notification/notification_presenter.dart))

未読通知数を計算するプロバイダー。

```dart
@riverpod
Future<int> unreadNotificationCount(Ref ref) async {
  final notifications = await ref.watch(notificationsProvider.future);
  final readIds = await ref.watch(readNotificationIdsProvider.future);

  return notifications.where((notification) => !readIds.contains(notification.id)).length;
}
```

主要機能:

- 全通知リストと既読 ID リストを比較
- 未読通知の件数を計算

### NotificationListScreen ([notification_list_screen.dart](../../client/lib/ui/feature/notification/notification_list_screen.dart))

通知一覧を表示する画面。

```dart
static const name = 'NotificationListScreen';

static MaterialPageRoute<NotificationListScreen> route() =>
    MaterialPageRoute<NotificationListScreen>(
      builder: (_) => const NotificationListScreen(),
      settings: const RouteSettings(name: name),
    );
```

表示内容:

- 通知リストを公開日時の降順で表示
- 未読通知にはバッジまたは背景色で視覚的に区別
- タップすると詳細ダイアログを表示し、自動的に既読としてマーク
- 通知がない場合は「お知らせはありません」と表示

UI 構成:

```
AppBar
  title: "お知らせ"

ListView
  - NotificationListItem (繰り返し)
    - 未読バッジ (未読の場合)
    - タイトル
    - 公開日時
    - タップ → NotificationDetailDialog を表示
```

### NotificationDetailDialog ([notification_detail_dialog.dart](../../client/lib/ui/feature/notification/notification_detail_dialog.dart))

通知の詳細を表示するダイアログ。

表示内容:

- タイトル
- 本文(プレーンテキスト)
- 詳細 URL がある場合は「詳しく見る」ボタンを表示
- 「閉じる」ボタン

```dart
static Future<void> show(
  BuildContext context,
  Notification notification,
) async {
  return showDialog<void>(
    context: context,
    builder: (context) => NotificationDetailDialog(
      notification: notification,
    ),
  );
}
```

動作:

- ダイアログ表示時に自動的に既読としてマーク
- 詳細 URL がある場合、「詳しく見る」ボタンタップで外部ブラウザを起動

### AppDrawer の拡張

[AppDrawer](../../client/lib/ui/component/app_drawer.dart) に「お知らせ」項目を追加し、未読バッジを表示する。

追加するプロパティ:

```dart
final bool isNotificationSelected;
final VoidCallback onSelectNotification;
```

追加する ListTile:

```dart
Widget _buildNotificationTile(BuildContext context) {
  final unreadCountAsync = ref.watch(unreadNotificationCountProvider);

  final badge = unreadCountAsync.when(
    data: (count) => count > 0
        ? Badge(
            label: Text('$count'),
            child: const Icon(Icons.notifications),
          )
        : const Icon(Icons.notifications),
    loading: () => const Icon(Icons.notifications),
    error: (_, _) => const Icon(Icons.notifications),
  );

  return ListTile(
    leading: badge,
    title: const Text('お知らせ'),
    selected: isNotificationSelected,
    onTap: () {
      Navigator.of(context).pop();
      if (!isNotificationSelected) {
        onSelectNotification();
      }
    },
  );
}
```

挿入位置:

```dart
_buildTalkTile(context),
_buildJobMarketTile(context),
_buildAchievementTile(context),
_buildNotificationTile(context), // 追加
const Divider(),
_buildSettingsTile(context),
```

### ハンバーガーアイコンへのバッジ表示

[HomeScreen](../../client/lib/ui/feature/home/home_screen.dart) の AppBar の `leading` プロパティをカスタマイズし、未読通知がある場合はバッジを表示する。

```dart
@override
Widget build(BuildContext context) {
  final unreadCountAsync = ref.watch(unreadNotificationCountProvider);

  Widget? leading;
  final unreadCount = unreadCountAsync.whenOrNull(data: (count) => count);
  if (unreadCount != null && unreadCount > 0) {
    leading = Builder(
      builder: (context) => IconButton(
        icon: Badge(
          label: Text('$unreadCount'),
          child: const Icon(Icons.menu),
        ),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    );
  }

  return Scaffold(
    appBar: AppBar(
      leading: leading,
      title: title,
      actions: [clearButton],
    ),
    // ...
  );
}
```

## データフロー

### 通知取得時

1. アプリ起動時、`NotificationService` が Firebase Remote Config から通知リストを取得
2. JSON 文字列をパースして `Notification` オブジェクトのリストに変換
3. 公開日時の降順でソート
4. `ReadNotificationIdsRepository` から既読 ID リストを取得
5. `UnreadNotificationCountProvider` が未読通知数を計算

### お知らせ一覧画面表示時

1. `NotificationListScreen` が通知リストと既読 ID リストを取得
2. 各通知の既読状態を判定し、未読の場合はバッジまたは背景色を表示
3. タップすると `NotificationDetailDialog` を表示
4. ダイアログ表示時に `ReadNotificationIdsRepository.markAsRead()` を呼び出し、既読としてマーク
5. 既読マーク後、`UnreadNotificationCountProvider` が自動的に再計算され、バッジが更新される

### 未読バッジ更新時

1. `UnreadNotificationCountProvider` が通知リストまたは既読 ID リストの変更を監視
2. 変更があった場合、未読通知数を再計算
3. `AppDrawer` と `HomeScreen` の AppBar が自動的に更新される

## 永続化

[PreferenceKey](../../client/lib/data/model/preference_key.dart) に以下のキーを追加:

```dart
enum PreferenceKey {
  // ... 既存のキー
  readNotificationIds, // 既読通知IDのリスト
}
```

SharedPreferences に保存:

- `readNotificationIds`: 既読通知 ID のリスト (List\<String\>)

## エラーハンドリング

### Remote Config 取得失敗時

- 通知リストが空の場合、空のリストを返す
- ネットワークエラーなどで取得に失敗した場合、`NotificationListScreen` でエラーメッセージを表示
- バッジは非表示

### JSON パースエラー時

- 不正な JSON 形式の場合、ログに記録し、空のリストを返す
- ユーザーには「お知らせはありません」と表示

### 外部 URL 起動失敗時

- `url_launcher` で外部 URL を開けない場合、SnackBar でエラーメッセージを表示
- 例: 「URL を開けませんでした」

## 設計ポイント

- **スケーラビリティ**: Remote Config を使用することで、アプリ更新なしで通知を追加・更新可能
- **シンプルな既読管理**: 既読 ID リストのみをローカルに保存することで、実装をシンプルに保つ
- **自動的なバッジ更新**: Riverpod の `ref.watch` を使用して、既読状態の変更を自動的に UI に反映
- **Reward 機能との一貫性**: 既存の Reward 機能と同様のアーキテクチャを採用し、コードベースの一貫性を保つ
- **アクセシビリティ**: バッジとテキストで未読状態を明示し、視覚的にわかりやすい UI を提供

## UI/UX の考慮事項

### 未読通知の視覚的表示

- ドロワーメニューの「お知らせ」項目にバッジを表示
- ハンバーガーアイコンにバッジを表示
- 通知一覧画面で未読通知を視覚的に区別(例: 背景色を変更、太字で表示)

### 既読マークのタイミング

- 通知詳細ダイアログを開いた瞬間に既読としてマーク
- ユーザーが一覧画面に戻った際、バッジが自動的に更新される

### 空状態の表示

- 通知がない場合、中央に「お知らせはありません」と表示
- アイコンとテキストで視覚的にわかりやすくする

### 詳細 URL の取り扱い

- 詳細 URL がある場合のみ「詳しく見る」ボタンを表示
- ボタンタップで外部ブラウザを起動
- URL 起動失敗時はエラーメッセージを表示

## テスト計画

### ユニットテスト

- `Notification.fromJson()` の JSON パースロジック
- `ReadNotificationIdsRepository` の既読管理ロジック
- `UnreadNotificationCountProvider` の未読数計算ロジック

### ウィジェットテスト

- `NotificationListScreen` の表示ロジック(通知あり/なし、既読/未読)
- `NotificationDetailDialog` の表示ロジック
- `AppDrawer` のバッジ表示ロジック

### 統合テスト

- Remote Config から通知を取得し、一覧画面に表示
- 通知をタップして詳細ダイアログを表示し、既読としてマーク
- バッジが正しく更新されることを確認

## デバッグ機能

[DebugScreen](../../client/lib/ui/feature/settings/debug_screen.dart) に既読通知リセット機能を追加:

```dart
ListTile(
  leading: const Icon(Icons.refresh),
  title: const Text('既読通知をリセット'),
  onTap: () async {
    await ref.read(readNotificationIdsRepositoryProvider.notifier).resetForDebug();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('既読通知をリセットしました')),
      );
    }
  },
)
```

## 将来の拡張性

### プッシュ通知との連携

- 現在はアプリ内通知のみだが、将来的に Firebase Cloud Messaging と連携可能
- 通知 ID をキーとして、プッシュ通知とアプリ内通知を紐づける

### 通知のカテゴリ分け

- `Notification` モデルに `category` フィールドを追加
- カテゴリごとにフィルタリング機能を追加

### 通知の優先度

- `Notification` モデルに `priority` フィールドを追加
- 高優先度の通知を目立たせる

### 既読期限

- `Notification` モデルに `expiresAt` フィールドを追加
- 期限切れの通知を自動的に非表示

## 関連ファイル

### 新規作成ファイル

- [client/lib/data/model/notification.dart](../../client/lib/data/model/notification.dart): 通知のドメインモデル
- [client/lib/data/service/notification_service.dart](../../client/lib/data/service/notification_service.dart): 通知取得サービス
- [client/lib/data/repository/read_notification_ids_repository.dart](../../client/lib/data/repository/read_notification_ids_repository.dart): 既読通知 ID リポジトリ
- [client/lib/ui/feature/notification/notification_presenter.dart](../../client/lib/ui/feature/notification/notification_presenter.dart): 通知プレゼンテーション層
- [client/lib/ui/feature/notification/notification_list_screen.dart](../../client/lib/ui/feature/notification/notification_list_screen.dart): 通知一覧画面
- [client/lib/ui/feature/notification/notification_detail_dialog.dart](../../client/lib/ui/feature/notification/notification_detail_dialog.dart): 通知詳細ダイアログ

### 更新ファイル

- [client/lib/data/model/preference_key.dart](../../client/lib/data/model/preference_key.dart): `readNotificationIds` キーを追加
- [client/lib/ui/component/app_drawer.dart](../../client/lib/ui/component/app_drawer.dart): 「お知らせ」項目とバッジを追加
- [client/lib/ui/feature/home/home_screen.dart](../../client/lib/ui/feature/home/home_screen.dart): ハンバーガーアイコンにバッジを追加
- [client/lib/ui/feature/job_market/job_market_screen.dart](../../client/lib/ui/feature/job_market/job_market_screen.dart): ハンバーガーアイコンにバッジを追加
- [client/lib/ui/feature/settings/debug_screen.dart](../../client/lib/ui/feature/settings/debug_screen.dart): 既読通知リセット機能を追加

### 参考ファイル

- [client/lib/data/repository/has_earned_part_timer_reward_repository.dart](../../client/lib/data/repository/has_earned_part_timer_reward_repository.dart): リポジトリの実装パターン
- [client/lib/ui/feature/stats/cavivara_reward.dart](../../client/lib/ui/feature/stats/cavivara_reward.dart): ドメインモデルの実装パターン
- [doc/spec/reward-feature.md](../../doc/spec/reward-feature.md): 仕様書の形式
