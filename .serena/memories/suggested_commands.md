# 推奨コマンド一覧

このファイルには、プロジェクト開発で使用する主要なコマンドをまとめています。

## Flutter クライアント開発

### コード整形・リント

```bash
# Dart ファイルのフォーマット
dart format path/to/your/file.dart

# Linter の自動修正を適用
dart fix --apply

# 静的解析実行
flutter analyze
# または
dart analyze
```

### テスト実行

```bash
# すべてのテストを実行
flutter test

# 特定のテストファイルを実行
flutter test test/path/to/test_file.dart
```

### ビルドとコード生成

```bash
# コード生成（Riverpod, Freezed など）
dart run build_runner build

# コード生成（既存ファイルを削除して再生成）
dart run build_runner build --delete-conflicting-outputs

# ウォッチモード（ファイル変更時に自動再生成）
dart run build_runner watch
```

### 依存関係管理

```bash
# 依存関係のインストール
flutter pub get

# 依存関係の更新
flutter pub upgrade

# 依存関係の確認
flutter pub outdated
```

### アプリ実行

```bash
# Emulator 環境で実行（Debug）
# VSCode の「実行とデバッグ」パネルから "Emulator-Debug" を選択

# Dev 環境で実行
# VSCode の「実行とデバッグ」パネルから "Debug-dev" を選択

# Prod 環境で実行
# VSCode の「実行とデバッグ」パネルから "Debug-prod" を選択
```

## Firebase エミュレータ

```bash
# Firebase Emulator の起動（データの保持・エクスポート付き）
cd infra
firebase emulators:start --import=emulator-data --export-on-exit=emulator-data
```

## Git 操作

```bash
# ステータス確認
git status

# 差分確認
git diff

# ステージング
git add .

# コミット
git commit -m "commit message"

# プッシュ
git push

# ログ確認
git log
```

## システムコマンド（macOS/Darwin）

```bash
# ディレクトリ内容の表示
ls -la

# ファイル検索
find . -name "*.dart"

# テキスト検索
grep -r "pattern" path/

# ディレクトリ移動
cd path/to/directory

# ファイル内容表示
cat filename
```

## Terraform（インフラ管理）

```bash
# 開発環境
cd infra/environment/dev
terraform init
terraform plan
terraform apply

# 本番環境
cd infra/environment/prod
terraform init
terraform plan
terraform apply
```

## Firebase Functions

```bash
# 開発環境へデプロイ
cd infra
firebase use default
firebase deploy --only functions

# 本番環境へデプロイ
firebase use prod
firebase deploy --only functions
```

## iOS 固有（fastlane など）

```bash
# iOS ビルド・デプロイ（Dev 環境）
cd client/ios
bundle exec fastlane dev

# Provisioning Profiles のダウンロード
# Xcode で「Download Manual Profiles」を実行
```

## Android 固有（fastlane など）

```bash
# Android ビルド・デプロイ（Dev 環境）
cd client/android
bundle exec fastlane dev
```

## Swift Package Manager（SPM）

```bash
# SPM を有効化（Flutter 全体で設定）
flutter config --enable-swift-package-manager

# 注意: SPM はベータ機能のため、ビルド時に問題が発生する可能性がある
```

## その他のユーティリティコマンド

```bash
# アプリアイコンの生成
dart run flutter_launcher_icons

# パッケージ情報の確認
flutter doctor

# Flutter のバージョン確認
flutter --version
```