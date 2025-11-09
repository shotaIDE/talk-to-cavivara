# プロジェクト概要

## プロジェクト名
カヴィヴァラトーク (Talk to Cavivara)

## プロジェクトの目的
iOS と Android 向けのモバイルアプリケーションで、ユーザーがカヴィヴァラ（キャラクター）とチャットできるアプリケーション。AI を活用したチャット機能や、ユーザー統計、プロフィール管理などの機能を提供する。

## 主な機能
- AI チャット機能（Firebase AI を利用）
- カヴィヴァラとの対話履歴管理
- ユーザー統計とリワードシステム
- Google サインイン認証
- 職務経歴書（Resume）の閲覧機能
- 求人市場（Job Market）情報
- Pro 版へのアップグレード機能
- チャットバブルデザインのカスタマイズ

## テクノロジースタック

### フロントエンド（クライアントアプリ）
- **フレームワーク**: Flutter（Dart SDK 3.9.2）
- **プラットフォーム**: iOS, Android
- **状態管理**: Riverpod 3.0.3（コード生成を使用）
- **データモデル**: Freezed（不変データクラス）
- **UI**: Material Design, Custom theming

### バックエンド・インフラ
- **BaaS**: Firebase
  - Firestore（データベース）
  - Firebase Authentication（Google サインイン）
  - Firebase Functions（サーバーレス関数）
  - Firebase AI（AI チャット機能）
  - Firebase Analytics
  - Firebase Crashlytics（エラーレポート）
  - Firebase Remote Config
- **IaC**: Terraform（インフラ管理）

### 開発ツール・ライブラリ
- **コード生成**: build_runner, riverpod_generator, freezed, json_serializable
- **リント**: pedantic_mono, riverpod_lint, custom_lint
- **テスト**: flutter_test, mocktail
- **その他の主要ライブラリ**: 
  - cloud_firestore, cloud_functions
  - google_sign_in
  - shared_preferences（ローカル設定保存）
  - url_launcher, share_plus
  - package_info_plus, in_app_review

## プロジェクト構成

### ディレクトリ構造
```
/
├── client/          # Flutter クライアントアプリ
│   ├── lib/         # アプリケーションコード
│   ├── test/        # テストコード
│   ├── ios/         # iOS 固有コード
│   └── android/     # Android 固有コード
├── infra/           # インフラとバックエンド
│   ├── functions/   # Firebase Functions
│   ├── module/      # Terraform モジュール
│   └── environment/ # 環境別設定（dev/prod）
├── doc/             # ドキュメント
│   ├── coding-rule/ # コーディング規約
│   ├── requirement/ # 要件定義
│   └── design/      # 技術設計
├── .github/         # GitHub Actions CI/CD
└── dictionary/      # プロジェクト用語辞書

```

## 環境
- Emulator: Firebase Emulator を使用したローカル開発環境
- Dev: 開発環境（テスト用 Firebase プロジェクト）
- Prod: 本番環境

## 開発プラットフォーム
- macOS (Darwin 24.4.0)
- iOS: Swift Package Manager (SPM) と CocoaPods の併用
- Android: Gradle ビルドシステム