# コードベース構造

## プロジェクトルート構成

```
talk-to-cavivara/
├── client/              # Flutter クライアントアプリケーション
├── infra/               # インフラストラクチャとバックエンド
├── doc/                 # ドキュメント
├── .github/             # GitHub Actions ワークフロー
├── dictionary/          # プロジェクト用語辞書
├── .claude/             # Claude Code 設定
├── .serena/             # Serena MCP サーバーデータ
├── .vscode/             # VSCode 設定
├── ARCHITECTURE.md      # アーキテクチャドキュメント
├── CLAUDE.md            # Claude 向けプロジェクト指示
├── CONTRIBUTING.md      # 開発貢献ガイド
├── GEMINI.md            # Gemini 向けプロジェクト指示
├── .mcp.json            # MCP サーバー設定
├── cspell.json          # スペルチェック設定
└── renovate.json        # Renovate 設定
```

## client/ ディレクトリ構造

```
client/
├── lib/                        # アプリケーションコード
│   ├── data/                   # データ層
│   │   ├── definition/         # 共通定義（Flavor, AppDefinition など）
│   │   ├── model/              # ドメインモデル
│   │   │   ├── *.dart          # モデルクラス（Freezed 使用）
│   │   │   └── *.freezed.dart  # 生成されたコード
│   │   ├── repository/         # リポジトリ
│   │   │   ├── *.dart          # リポジトリ実装
│   │   │   └── *.g.dart        # 生成されたコード
│   │   └── service/            # サービス（OS・Firebase 接続）
│   │       ├── dao/            # Data Access Objects
│   │       ├── *_service.dart  # サービス実装
│   │       └── *.g.dart        # 生成されたコード
│   ├── ui/                     # UI 層
│   │   ├── component/          # 共通 UI コンポーネント
│   │   │   ├── app_theme.dart
│   │   │   ├── app_drawer.dart
│   │   │   ├── cavivara_avatar.dart
│   │   │   └── ...
│   │   ├── feature/            # 画面と画面ロジック
│   │   │   ├── auth/           # 認証画面
│   │   │   ├── home/           # ホーム画面
│   │   │   ├── settings/       # 設定画面
│   │   │   ├── stats/          # 統計画面
│   │   │   ├── resume/         # 職務経歴書画面
│   │   │   ├── job_market/     # 求人市場画面
│   │   │   ├── pro/            # Pro アップグレード画面
│   │   │   └── update/         # アプリ更新画面
│   │   ├── root_app.dart       # ルートアプリ
│   │   └── root_presenter.dart # ルートプレゼンター
│   ├── main.dart               # エントリーポイント
│   ├── firebase_options_emulator.dart  # Firebase 設定（Emulator）
│   ├── firebase_options_dev.dart       # Firebase 設定（Dev）
│   └── firebase_options_prod.dart      # Firebase 設定（Prod）
├── test/                       # テストコード
│   ├── ui/                     # UI テスト
│   └── data/                   # データ層テスト
├── android/                    # Android 固有コード
│   ├── app/
│   │   └── src/
│   │       ├── emulator/       # Emulator 環境設定
│   │       ├── dev/            # Dev 環境設定
│   │       └── prod/           # Prod 環境設定
│   ├── fastlane/               # fastlane 設定
│   └── build.gradle            # Gradle 設定
├── ios/                        # iOS 固有コード
│   ├── Runner/
│   │   └── Firebase/
│   │       ├── Emulator/       # Emulator 環境設定
│   │       ├── Dev/            # Dev 環境設定
│   │       └── Prod/           # Prod 環境設定
│   ├── fastlane/               # fastlane 設定
│   └── Runner.xcworkspace/     # Xcode ワークスペース
├── assets/                     # アセット
│   ├── image/                  # 画像ファイル
│   └── launcher-icon/          # アプリアイコン元画像
├── pubspec.yaml                # 依存関係定義
├── analysis_options.yaml       # 静的解析設定
├── firebase.json               # Firebase 設定
├── emulator-config.json        # Emulator 接続設定（gitignore）
├── emulator-config.sample.json # Emulator 接続設定サンプル
└── flutter_launcher_icons-*.yaml  # アイコン生成設定
```

## infra/ ディレクトリ構造

```
infra/
├── functions/              # Firebase Functions コード
├── module/                 # Terraform モジュール
│   ├── firebase/           # Firebase プロジェクト設定
│   ├── firestore/          # Firestore 設定
│   ├── auth/               # 認証設定
│   └── app/                # アプリ設定
├── environment/            # 環境別設定
│   ├── dev/                # 開発環境
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   └── prod/               # 本番環境
│       ├── main.tf
│       └── terraform.tfvars
├── emulator-data/          # Emulator データ（gitignore）
├── firestore.rules         # Firestore セキュリティルール
├── firestore.indexes.json  # Firestore インデックス
├── firebase.json           # Firebase 設定
└── .firebaserc             # Firebase プロジェクト参照
```

## doc/ ディレクトリ構造

```
doc/
├── coding-rule/            # コーディング規約
│   ├── general-coding-rules.md
│   └── general-coding-rules_ja.md
├── requirement/            # 要件定義ドキュメント
└── design/                 # 技術設計ドキュメント
```

## 主要なモデルとサービス

### データモデル（client/lib/data/model/）
- `app_session.dart`: アプリセッション
- `app_version.dart`: アプリバージョン
- `cavivara_profile.dart`: カヴィヴァラプロフィール
- `chat_message.dart`: チャットメッセージ
- `chat_bubble_design.dart`: チャットバブルデザイン
- `user_profile.dart`: ユーザープロフィール
- `resume_section.dart`: 職務経歴書セクション
- `count.dart`: カウンター
- 各種例外クラス（`*_exception.dart`, `*_error.dart`）

### リポジトリ（client/lib/data/repository/）
- `chat_bubble_design_repository.dart`: チャットバブルデザイン保存
- `last_talked_cavivara_id_repository.dart`: 最後に話したカヴィヴァラ ID
- `sent_chat_string_count_repository.dart`: 送信チャット文字数カウント
- `received_chat_string_count_repository.dart`: 受信チャット文字数カウント
- `resume_viewing_duration_repository.dart`: 職務経歴書閲覧時間
- リワード関連リポジトリ（`has_earned_*_repository.dart`）
- `skip_clear_chat_confirmation_repository.dart`: チャットクリア確認スキップ設定

### サービス（client/lib/data/service/）
- `ai_chat_service.dart`: AI チャット機能
- `auth_service.dart`: 認証サービス
- `database_service.dart`: データベースサービス
- `functions_service.dart`: Cloud Functions 接続
- `cavivara_knowledge_service.dart`: カヴィヴァラ知識サービス
- `cavivara_directory_service.dart`: カヴィヴァラディレクトリサービス
- `employment_state_service.dart`: 雇用状態サービス
- `remote_config_service.dart`: Remote Config
- `preference_service.dart`: ローカル設定
- `app_info_service.dart`: アプリ情報
- `error_report_service.dart`: エラーレポート

### UI フィーチャー（client/lib/ui/feature/）
- **auth/**: ログイン画面
- **home/**: ホーム画面（チャット機能）
- **settings/**: 設定画面
- **stats/**: ユーザー統計画面
- **resume/**: 職務経歴書画面
- **job_market/**: 求人市場画面
- **pro/**: Pro アップグレード画面
- **update/**: アプリ更新画面

## 環境管理（Flavor）

### 3 つの環境
1. **Emulator**: Firebase Emulator を使用（ローカル開発）
2. **Dev**: 開発用 Firebase プロジェクト
3. **Prod**: 本番用 Firebase プロジェクト

### 環境別の設定ファイル
- Firebase 設定: `firebase_options_*.dart`
- iOS: `ios/Runner/Firebase/*/GoogleService-Info.plist`
- Android: `android/app/src/*/google-services.json`
- アプリアイコン: `flutter_launcher_icons-*.yaml`

## 生成されるファイル

以下のファイルは自動生成されるため、直接編集しない:

- `*.freezed.dart`: Freezed によるデータクラス生成
- `*.g.dart`: Riverpod, json_serializable などによるコード生成
- `firebase_options*.dart`: FlutterFire CLI による生成（環境設定時）

## Git 管理外のファイル（.gitignore）

- `client/emulator-config.json`: 個人の開発環境設定
- `infra/emulator-data/`: Firebase Emulator データ
- `client/ios/fastlane/.env`: fastlane 環境変数
- `client/ios/fastlane/app-store-connect-api-key.p8`: App Store Connect API キー
- `client/android/fastlane/google-play-service-account-key.json`: Google Play サービスアカウントキー
- ビルド生成物、依存関係キャッシュなど