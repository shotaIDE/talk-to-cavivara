# タスクリスト

## ✅ 1. カヴィヴァラのドメインモデル定義（完了）

- ✅ `client/lib/data/model/` にカヴィヴァラ固有情報を保持する `CavivaraProfile`（ID、表示名、肩書き、紹介文、アイコンパス、AI 用プロンプト、タグ、履歴書セクションなど）と履歴書セクション用のデータクラスを追加する。
- ✅ 既存の履歴書画面の内容を 1 人目のカヴィヴァラのデータとして移植し、2 人目のカヴィヴァラのプロフィールと履歴書・プロンプトの文面を設計する。
- ✅ 今後の拡張に備えて不変データとして扱えるよう `freezed` で実装し、生成ファイルを含めて管理する。
- 依存関係: なし
- **完了日**: 2025-09-19
- **実装ファイル**: `cavivara_profile.dart`, `resume_section.dart`, `cavivara_profiles_data.dart`

## ✅ 2. カヴィヴァラアイコンコンポーネントの拡張（完了）

- ✅ `client/lib/ui/component/cavivara_avatar.dart` を改修し、呼び出し側からアセットパスや背景色を指定できるようにする（後方互換のためデフォルト値は既存の `cavivara.png` を使用）。
- ✅ 今後複数キャラクターの表示に対応できるよう、Hero タグや Semantics 情報を ID ベースで付与できる仕組みが必要であれば追加検討する。
- 依存関係: タスク 1
- **完了日**: 2025-09-19
- **実装内容**: assetPath, backgroundColor, cavivaraId, semanticsLabel パラメーターを追加。Hero タグによるアニメーション対応、ID ベースの Semantics 対応を実装。

## ✅ 3. カヴィヴァラ一覧プロバイダーの実装（完了）

- ✅ タスク 1 で作成したプロフィール定義を返す `Provider`/`@riverpod`（例: `cavivaraDirectoryProvider`）を `client/lib/data/service/` 配下に追加し、アプリ全体で参照できるようにする。
- ✅ ID からプロフィールを取得するヘルパー（`cavivaraByIdProvider` など）を用意し、例外時の扱いを決める。
- ✅ プロバイダーのユニットテストを `client/test/` に追加し、2 名分のデータが期待通り取得できることを確認する。
- 依存関係: タスク 1
- **完了日**: 2025-09-19
- **実装ファイル**: `cavivara_directory_service.dart`, `cavivara_directory_service_test.dart`

## ✅ 4. 雇用状態管理ロジックの追加（完了）

- ✅ カヴィヴァラごとの雇用状態を保持する `StateNotifier`（または `@riverpod` の `Notifier`）を `client/lib/data/service/` に実装し、`hire`/`fire`/`isEmployed` を提供する。
- ✅ 初期状態（全員未雇用 or 特定メンバー雇用済み）を定義し、永続化が不要であることを明示するコメントを追加する。
- ✅ 雇用状態変更のテストを作成し、通知が正しく行われることを検証する。
- 依存関係: タスク 3
- **完了日**: 2025-09-19
- **実装ファイル**: `employment_state_service.dart`, `employment_state_service_test.dart`

## ✅ 5. AI チャットサービスのプロンプト対応改修（完了）

- ✅ `client/lib/data/service/ai_chat_service.dart` の `sendMessage`/`sendMessageStream` を拡張し、カヴィヴァラごとの `systemPrompt` と（必要なら）会話履歴を受け取れるようにする。
- ✅ 既存の呼び出し側をすべて更新し、新しいシグネチャでもストリーミング挙動とエラーハンドリングが維持されることを確認する。
- 依存関係: タスク 1
- **完了日**: 2025-09-19
- **実装内容**: sendMessageStreamメソッドにsystemPromptとconversationHistoryの任意パラメーターを追加。チャットセッションをsystemPromptごとにキャッシュする仕組みを実装。既存のAPIとの後方互換性を維持。

## ✅ 6. チャットメッセージプロバイダーの多キャラクター対応（完了）

- ✅ `client/lib/ui/feature/home/home_presenter.dart` の `ChatMessages` を Provider family 化し、`chatMessagesProvider(cavivaraId)` の形で個別の履歴を保持するよう変更する。
- ✅ タスク 5 で拡張した AI サービスを利用してメッセージを送信し、ストリーミング更新やエラー処理のロジックを ID ごとに動作させる。
- ✅ チャット履歴クリア処理を ID 単位で行えるようにし、必要なら全消去のユーティリティも用意する。
- 依存関係: タスク 3, タスク 5
- **完了日**: 2025-09-19
- **実装内容**: ChatMessages を Provider family に変更、cavivaraId をパラメーターとして受け取るように実装。各キャラクター固有の AI プロンプトと会話履歴を使用してメッセージを送信。ID 単位でのクリア機能と全体クリア機能を追加。

## 7. チャット画面のカヴィヴァラ切り替え対応

- 既存の `HomeScreen` を、特定のカヴィヴァラ ID を受け取って表示するチャット画面に改修する（必要であれば `ChatScreen` へのリネームを含む）。
- AppBar 表示、アバタータップ時の履歴書遷移、メッセージ送受信・クリア処理などを `chatMessagesProvider(cavivaraId)` と雇用状態に連動させる。
- 画面間遷移で利用する `route` メソッドの引数を更新し、既存の呼び出し箇所をすべて追従させる。
- 依存関係: タスク 2, タスク 3, タスク 6

## 8. 履歴書画面の動的化と雇用アクション

- `client/lib/ui/feature/resume/resume_screen.dart` を `ConsumerWidget` 化し、タスク 1 で定義したプロフィールデータを元に内容を描画するようリファクタリングする。
- 雇用状態に応じて「雇用する」/「解雇する」ボタンを出し分け、`hire` 実行時は対象カヴィヴァラのチャット画面へ遷移、`fire` 実行時は転職市場一覧へ戻るフローを実装する。
- ボタンタップ時にスナックバー等のフィードバックが必要か検討し、不要なら戻り値で十分であることをコメントする。
- 依存関係: タスク 2, タスク 3, タスク 4, タスク 7

## 9. 転職市場一覧画面の新規実装

- `client/lib/ui/feature/` 配下に転職市場画面（例: `job_market/job_market_screen.dart`）を追加し、2 名のカヴィヴァラをアイコン・名称・肩書き付きで一覧表示する。
- 各リストアイテムのタップで履歴書画面を開くようにし、雇用中メンバーには「相談する」ボタンを表示してチャット画面へ遷移できるようにする。
- 雇用状態の変化に応じて UI が即時反映されることを確認するため、`ConsumerWidget` もしくは `ConsumerStatefulWidget` で実装する。
- 依存関係: タスク 2, タスク 3, タスク 4, タスク 8, タスク 7

## 10. ナビゲーションとルート初期化の調整

- `client/lib/ui/root_app.dart` や関連ルート設定を更新し、サインイン済みユーザーの初期画面が転職市場一覧になるよう変更する。
- MaterialApp の `routes` / `onGenerateInitialRoutes` / `Navigator` 操作を見直し、新規画面間の戻る遷移が自然になるようスタック構成を整理する。
- 必要に応じて `AppInitialRoute` の enum や関連テストを更新する。
- 依存関係: タスク 7, タスク 8, タスク 9

## 11. プロバイダー・画面ロジックのテスト追加

- 雇用状態管理、カヴィヴァラ取得、チャットメッセージ保持のユニットテストを作成し、主要なメソッドの挙動を検証する（AI サービス利用箇所はモック化）。
- 転職市場画面と履歴書画面について、雇用状態に応じたボタン表示・遷移を確認するウィジェットテストを追加する。
- 依存関係: タスク 4, タスク 6, タスク 8, タスク 9, タスク 10

## 12. コード生成・フォーマット・テスト実行

- `dart run build_runner build --delete-conflicting-outputs` を実行し、`freezed` や `riverpod` の生成コードを更新する。
- `dart format .`、`dart fix --apply`、`flutter test` を実行し、フォーマットと Lint、テストを全てパスさせる。
- 依存関係: タスク 1〜11

## 13. ドキュメントと変更点の整理

- 新しい画面やカヴィヴァラ管理の仕様を `README` や必要なドキュメント（例: `ARCHITECTURE.md`）に追記し、開発者が構成を理解できるようにする。
- PR 用の概要文を用意し、主要変更点とテスト結果をまとめる。
- 依存関係: タスク 1〜12
