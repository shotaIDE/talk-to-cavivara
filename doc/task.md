# タスクリスト - 通知機能実装

## 概要

Firebase Remote Config から取得したお知らせ情報をアプリ内で表示する機能を実装する。既読管理をローカルに保存し、未読通知がある場合はドロワーメニューとハンバーガーアイコンにバッジを表示する。

詳細な設計は [doc/spec/notification-feature.md](./spec/notification-feature.md) を参照。

---

## 1. ドメインモデルの実装

**目的**: 通知情報を表すドメインモデルを定義する

**実装内容**:

- `client/lib/data/model/notification.dart` を作成
- `freezed` を使用して `Notification` クラスを定義
- `id`, `title`, `body`, `publishedAt`, `detailUrl` のフィールドを含める
- JSON シリアライズ/デシリアライズ機能を追加

**成果物**:

- `client/lib/data/model/notification.dart`
- `client/lib/data/model/notification.freezed.dart` (生成)
- `client/lib/data/model/notification.g.dart` (生成)

**依存関係**: なし

**作業時間見積もり**: 30 分

**確認項目**:

- [ ] `Notification` クラスが正しく定義されている
- [ ] `freezed` の `@freezed` アノテーションが適用されている
- [ ] `fromJson` / `toJson` メソッドが生成されている
- [ ] すべてのフィールドが `required` または Optional として適切に定義されている

---

## 2. PreferenceKey の拡張

**目的**: 既読通知 ID のリストを保存するためのキーを追加する

**実装内容**:

- `client/lib/data/model/preference_key.dart` に `readNotificationIds` を追加

**成果物**:

- `client/lib/data/model/preference_key.dart` (更新)

**依存関係**: なし

**作業時間見積もり**: 5 分

**確認項目**:

- [ ] `PreferenceKey` enum に `readNotificationIds` が追加されている

---

## 3. 通知サービスの実装

**目的**: Firebase Remote Config から通知情報を取得するサービスを実装する

**実装内容**:

- `client/lib/data/service/notification_service.dart` を作成
- `@riverpod` を使用して `Notifications` プロバイダーを定義
- Remote Config の `notifications` キーから JSON 配列を取得
- JSON を `Notification` オブジェクトのリストに変換
- 公開日時の降順でソート

**成果物**:

- `client/lib/data/service/notification_service.dart`
- `client/lib/data/service/notification_service.g.dart` (生成)

**依存関係**: タスク 1

**作業時間見積もり**: 45 分

**確認項目**:

- [ ] `Notifications` プロバイダーが正しく定義されている
- [ ] Remote Config から JSON 文字列を取得している
- [ ] JSON パースエラーを適切にハンドリングしている
- [ ] 通知リストが公開日時の降順でソートされている
- [ ] 空の JSON 文字列の場合、空リストを返す

---

## 4. 既読通知リポジトリの実装

**目的**: 既読通知 ID のリストを SharedPreferences で管理するリポジトリを実装する

**実装内容**:

- `client/lib/data/repository/read_notification_ids_repository.dart` を作成
- `@riverpod` を使用して `ReadNotificationIds` Notifier を定義
- `markAsRead(String notificationId)` メソッドを実装
- `resetForDebug()` メソッドを実装
- SharedPreferences からの読み書きを行う

**成果物**:

- `client/lib/data/repository/read_notification_ids_repository.dart`
- `client/lib/data/repository/read_notification_ids_repository.g.dart` (生成)

**依存関係**: タスク 2

**作業時間見積もり**: 45 分

**確認項目**:

- [ ] `ReadNotificationIds` Notifier が正しく定義されている
- [ ] `markAsRead` メソッドで既読 ID を追加している
- [ ] 既に既読の場合は重複追加しない
- [ ] `resetForDebug` メソッドで既読リストをクリアできる
- [ ] 状態更新時に `state` を更新している

---

## 5. 通知プレゼンテーション層の実装

**目的**: 未読通知数を計算するプロバイダーを実装する

**実装内容**:

- `client/lib/ui/feature/notification/notification_presenter.dart` を作成
- `@riverpod` を使用して `unreadNotificationCount` プロバイダーを定義
- 通知リストと既読 ID リストを比較して未読数を計算

**成果物**:

- `client/lib/ui/feature/notification/notification_presenter.dart`
- `client/lib/ui/feature/notification/notification_presenter.g.dart` (生成)

**依存関係**: タスク 3, タスク 4

**作業時間見積もり**: 30 分

**確認項目**:

- [ ] `unreadNotificationCount` プロバイダーが正しく定義されている
- [ ] 通知リストと既読 ID リストを監視している
- [ ] 未読通知数を正しく計算している

---

## 6. 通知詳細ダイアログの実装

**目的**: 通知の詳細を表示するダイアログを実装する

**実装内容**:

- `client/lib/ui/feature/notification/notification_detail_dialog.dart` を作成
- タイトル、本文、詳細 URL を表示
- 詳細 URL がある場合は「詳しく見る」ボタンを表示
- 「閉じる」ボタンを表示
- 外部 URL 起動のエラーハンドリング

**成果物**:

- `client/lib/ui/feature/notification/notification_detail_dialog.dart`

**依存関係**: タスク 1

**作業時間見積もり**: 45 分

**確認項目**:

- [ ] ダイアログが正しく表示される
- [ ] タイトルと本文が表示される
- [ ] 詳細 URL がある場合のみ「詳しく見る」ボタンが表示される
- [ ] 「詳しく見る」ボタンで外部ブラウザが起動する
- [ ] URL 起動失敗時に SnackBar でエラーメッセージを表示する
- [ ] 「閉じる」ボタンでダイアログが閉じる

---

## 7. 通知一覧画面の実装

**目的**: 通知一覧を表示する画面を実装する

**実装内容**:

- `client/lib/ui/feature/notification/notification_list_screen.dart` を作成
- 通知リストを公開日時の降順で表示
- 未読通知を視覚的に区別(背景色や太字)
- タップで詳細ダイアログを表示し、既読としてマーク
- 通知がない場合は「お知らせはありません」と表示
- ローディング状態とエラー状態の処理

**成果物**:

- `client/lib/ui/feature/notification/notification_list_screen.dart`

**依存関係**: タスク 3, タスク 4, タスク 5, タスク 6

**作業時間見積もり**: 1 時間 30 分

**確認項目**:

- [ ] 通知リストが正しく表示される
- [ ] 未読通知が視覚的に区別される
- [ ] タップで詳細ダイアログが開く
- [ ] 詳細ダイアログ表示時に既読としてマークされる
- [ ] 通知がない場合の空状態が表示される
- [ ] ローディング中は `CircularProgressIndicator` を表示
- [ ] エラー時はエラーメッセージを表示
- [ ] `MaterialPageRoute` の静的メソッドが定義されている

---

## 8. AppDrawer に「お知らせ」項目を追加

**目的**: ドロワーメニューに「お知らせ」項目を追加し、未読バッジを表示する

**実装内容**:

- `client/lib/ui/component/app_drawer.dart` を更新
- `isNotificationSelected` と `onSelectNotification` パラメーターを追加
- `_buildNotificationTile` メソッドを実装
- 未読数を取得して `Badge` ウィジェットを表示
- タップで通知一覧画面に遷移

**成果物**:

- `client/lib/ui/component/app_drawer.dart` (更新)

**依存関係**: タスク 5, タスク 7

**作業時間見積もり**: 45 分

**確認項目**:

- [ ] `AppDrawer` に新しいパラメーターが追加されている
- [ ] 「お知らせ」項目が正しい位置に表示される
- [ ] 未読通知がある場合にバッジが表示される
- [ ] バッジに未読数が表示される
- [ ] タップでドロワーが閉じて通知一覧画面に遷移する
- [ ] 選択状態が正しく反映される

---

## 9. HomeScreen のハンバーガーアイコンにバッジを追加

**目的**: ホーム画面のハンバーガーアイコンに未読バッジを表示する

**実装内容**:

- `client/lib/ui/feature/home/home_screen.dart` を更新
- AppBar の `leading` プロパティをカスタマイズ
- 未読通知数を監視し、未読がある場合はバッジ付きハンバーガーアイコンを表示
- AppDrawer に新しいパラメーターを渡す
- 通知一覧画面への遷移処理を追加

**成果物**:

- `client/lib/ui/feature/home/home_screen.dart` (更新)

**依存関係**: タスク 5, タスク 7, タスク 8

**作業時間見積もり**: 45 分

**確認項目**:

- [ ] 未読通知がある場合にハンバーガーアイコンにバッジが表示される
- [ ] バッジに未読数が表示される
- [ ] バッジがない場合はデフォルトのハンバーガーアイコンが表示される
- [ ] AppDrawer に正しいパラメーターが渡されている
- [ ] 通知一覧画面への遷移が機能する

---

## 10. JobMarketScreen のハンバーガーアイコンにバッジを追加

**目的**: 転職市場画面のハンバーガーアイコンに未読バッジを表示する

**実装内容**:

- `client/lib/ui/feature/job_market/job_market_screen.dart` を更新
- HomeScreen と同様に AppBar の `leading` をカスタマイズ
- AppDrawer に新しいパラメーターを渡す
- 通知一覧画面への遷移処理を追加

**成果物**:

- `client/lib/ui/feature/job_market/job_market_screen.dart` (更新)

**依存関係**: タスク 5, タスク 7, タスク 8

**作業時間見積もり**: 45 分

**確認項目**:

- [ ] 未読通知がある場合にハンバーガーアイコンにバッジが表示される
- [ ] バッジに未読数が表示される
- [ ] AppDrawer に正しいパラメーターが渡されている
- [ ] 通知一覧画面への遷移が機能する

---

## 11. デバッグ画面に既読リセット機能を追加

**目的**: デバッグ画面に既読通知をリセットする機能を追加する

**実装内容**:

- `client/lib/ui/feature/settings/debug_screen.dart` を更新
- 既読通知をリセットする ListTile を追加
- `ReadNotificationIds.resetForDebug()` を呼び出す
- 成功時に SnackBar でフィードバックを表示

**成果物**:

- `client/lib/ui/feature/settings/debug_screen.dart` (更新)

**依存関係**: タスク 4

**作業時間見積もり**: 20 分

**確認項目**:

- [ ] デバッグ画面に「既読通知をリセット」項目が追加されている
- [ ] タップで既読リストがクリアされる
- [ ] 成功時に SnackBar が表示される

---

## 12. ユニットテストの実装

**目的**: ドメインモデル、リポジトリ、プロバイダーのユニットテストを作成する

**実装内容**:

- `client/test/data/model/notification_test.dart` を作成
  - `Notification.fromJson()` のテスト
  - 各フィールドが正しく変換されることを確認
- `client/test/data/repository/read_notification_ids_repository_test.dart` を作成
  - `markAsRead()` のテスト
  - `resetForDebug()` のテスト
  - 重複追加のテスト
- `client/test/ui/feature/notification/notification_presenter_test.dart` を作成
  - `unreadNotificationCount` プロバイダーのテスト
  - 未読数計算ロジックのテスト

**成果物**:

- `client/test/data/model/notification_test.dart`
- `client/test/data/repository/read_notification_ids_repository_test.dart`
- `client/test/ui/feature/notification/notification_presenter_test.dart`

**依存関係**: タスク 1, タスク 4, タスク 5

**作業時間見積もり**: 2 時間

**確認項目**:

- [ ] 全てのテストファイルが作成されている
- [ ] `Notification.fromJson()` のテストがパスする
- [ ] リポジトリのテストがパスする
- [ ] プロバイダーのテストがパスする
- [ ] モックを適切に使用している

---

## 13. ウィジェットテストの実装

**目的**: 通知一覧画面と詳細ダイアログのウィジェットテストを作成する

**実装内容**:

- `client/test/ui/feature/notification/notification_list_screen_test.dart` を作成
  - 通知リスト表示のテスト
  - 未読/既読の視覚的区別のテスト
  - 空状態の表示テスト
  - タップ時のダイアログ表示テスト
- `client/test/ui/feature/notification/notification_detail_dialog_test.dart` を作成
  - ダイアログ表示のテスト
  - 詳細 URL ありなしの表示切り替えテスト
  - ボタンタップのテスト

**成果物**:

- `client/test/ui/feature/notification/notification_list_screen_test.dart`
- `client/test/ui/feature/notification/notification_detail_dialog_test.dart`

**依存関係**: タスク 6, タスク 7

**作業時間見積もり**: 2 時間

**確認項目**:

- [ ] 全てのテストファイルが作成されている
- [ ] 通知一覧画面のテストがパスする
- [ ] 詳細ダイアログのテストがパスする
- [ ] プロバイダーのオーバーライドを適切に使用している

---

## 14. コード生成・フォーマット・Lint 修正

**目的**: コード生成を実行し、フォーマットと Lint を適用する

**実施内容**:

1. コード生成を実行

   ```bash
   cd client
   dart run build_runner build --delete-conflicting-outputs
   ```

2. フォーマットを適用

   ```bash
   dart format .
   ```

3. Lint 自動修正を適用

   ```bash
   dart fix --apply
   ```

4. Lint 警告を確認
   ```bash
   flutter analyze
   ```

**依存関係**: タスク 1〜13

**作業時間見積もり**: 30 分

**確認項目**:

- [ ] コード生成が正常に完了している
- [ ] フォーマットが適用されている
- [ ] Lint 警告がゼロである
- [ ] 生成ファイルがすべてコミットされている

---

## 15. テスト実行と検証

**目的**: 全てのテストを実行し、正常に動作することを確認する

**実施内容**:

1. ユニットテストとウィジェットテストを実行

   ```bash
   cd client
   flutter test
   ```

2. 失敗したテストがあれば修正

3. カバレッジを確認(オプション)
   ```bash
   flutter test --coverage
   ```

**依存関係**: タスク 12, タスク 13, タスク 14

**作業時間見積もり**: 30 分

**確認項目**:

- [ ] 全てのテストがパスしている
- [ ] 新規追加したテストがすべて含まれている
- [ ] テストカバレッジが適切である(オプション)

---

## 16. Firebase Remote Config の設定

**目的**: Firebase コンソールで Remote Config に通知データを設定する

**実施内容**:

1. Firebase コンソールにアクセス
2. Remote Config セクションを開く
3. `notifications` キーを追加
4. JSON 配列形式でサンプル通知を設定
5. 変更を公開

**サンプル JSON**:

```json
[
  {
    "id": "notification_001",
    "title": "通知機能リリースのお知らせ",
    "body": "お知らせ機能がリリースされました。ドロワーメニューの「お知らせ」からご確認ください。",
    "publishedAt": "2025-10-14T10:00:00Z",
    "detailUrl": "https://example.com/news/001"
  }
]
```

**依存関係**: タスク 3

**作業時間見積もり**: 15 分

**確認項目**:

- [ ] Remote Config に `notifications` キーが設定されている
- [ ] JSON 形式が正しい
- [ ] 変更が公開されている
- [ ] アプリから取得できることを確認

---

## 17. 動作確認とデバッグ

**目的**: 実機またはシミュレーターで動作を確認し、問題があれば修正する

**確認内容**:

1. **通知一覧画面**

   - [ ] ドロワーメニューから「お知らせ」をタップして画面遷移
   - [ ] 通知リストが正しく表示される
   - [ ] 未読通知が視覚的に区別される
   - [ ] 通知がない場合の空状態が表示される

2. **通知詳細ダイアログ**

   - [ ] 通知をタップして詳細ダイアログが開く
   - [ ] タイトルと本文が表示される
   - [ ] 詳細 URL がある場合のみ「詳しく見る」ボタンが表示される
   - [ ] 「詳しく見る」ボタンで外部ブラウザが起動する
   - [ ] 「閉じる」ボタンでダイアログが閉じる

3. **既読管理**

   - [ ] 詳細ダイアログを開くと既読になる
   - [ ] 既読通知は視覚的に区別される
   - [ ] アプリを再起動しても既読状態が保持される

4. **未読バッジ**

   - [ ] 未読通知がある場合、ハンバーガーアイコンにバッジが表示される
   - [ ] 未読通知がある場合、ドロワーメニューの「お知らせ」にバッジが表示される
   - [ ] バッジに正しい未読数が表示される
   - [ ] 既読にすると即座にバッジが更新される
   - [ ] 全て既読にするとバッジが消える

5. **エラーハンドリング**

   - [ ] ネットワークエラー時に適切なエラーメッセージが表示される
   - [ ] 不正な JSON 形式の場合、アプリがクラッシュしない
   - [ ] URL 起動失敗時にエラーメッセージが表示される

6. **デバッグ機能**
   - [ ] デバッグ画面から既読通知をリセットできる
   - [ ] リセット後、全ての通知が未読になる

**依存関係**: タスク 1〜16

**作業時間見積もり**: 1 時間

---

## 18. ドキュメントの更新

**目的**: 関連ドキュメントを更新し、通知機能の説明を追加する

**実施内容**:

- [ ] `ARCHITECTURE.md` に通知機能のアーキテクチャを追記
- [ ] `README.md` に通知機能の概要を追記(必要に応じて)
- [ ] コード内のコメントを確認し、不足があれば追加

**依存関係**: タスク 1〜17

**作業時間見積もり**: 30 分

**確認項目**:

- [ ] ドキュメントが更新されている
- [ ] 新機能の説明が十分である
- [ ] コード内のコメントが適切である

---

## 19. PR の作成

**目的**: 実装内容をレビュー用の Pull Request にまとめる

**実施内容**:

1. 変更内容をコミット

   ```bash
   git add .
   git commit -m "feat: 通知機能を実装"
   ```

2. ブランチをプッシュ

   ```bash
   git push origin notifications
   ```

3. GitHub で Pull Request を作成

4. PR 説明文を記述
   - 実装内容の概要
   - 主要な変更点
   - テスト結果
   - スクリーンショット(オプション)

**依存関係**: タスク 1〜18

**作業時間見積もり**: 30 分

**確認項目**:

- [ ] 全ての変更がコミットされている
- [ ] PR が作成されている
- [ ] PR 説明文が十分である
- [ ] レビュアーが指定されている(必要に応じて)

---

## 総作業時間見積もり

- タスク 1〜11: 約 8 時間
- タスク 12〜13: 約 4 時間
- タスク 14〜19: 約 3 時間

**合計**: 約 15 時間

---

## 優先順位

### Phase 1: コア機能実装 (タスク 1〜7)

通知の取得、表示、既読管理の基本機能を実装

### Phase 2: UI 統合 (タスク 8〜11)

既存の UI に通知機能を統合し、バッジを表示

### Phase 3: テストとデバッグ (タスク 12〜17)

テストを作成し、動作確認を行う

### Phase 4: リリース準備 (タスク 18〜19)

ドキュメントを整備し、PR を作成

---

## 注意事項

1. **コーディング規約の遵守**

   - [doc/coding-rule/general-coding-rules_ja.md](./coding-rule/general-coding-rules_ja.md) に従う
   - 早期リターンを使用し、ネストを減らす
   - 関数型プログラミングを活用する

2. **既存機能との一貫性**

   - Reward 機能と同様のアーキテクチャを採用
   - 既存のコンポーネントやパターンを参考にする

3. **テストの重要性**

   - 全ての新規コードにテストを追加
   - モックを適切に使用する

4. **エラーハンドリング**

   - ネットワークエラー、JSON パースエラーなどを適切に処理
   - ユーザーにわかりやすいエラーメッセージを表示

5. **アクセシビリティ**

   - Semantics を適切に設定
   - 色だけでなくテキストでも情報を伝える

6. **パフォーマンス**
   - 不要な再ビルドを避ける
   - プロバイダーの依存関係を適切に管理
