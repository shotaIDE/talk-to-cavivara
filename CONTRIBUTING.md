# 開発貢献ガイド

このドキュメントでは、House Workerプロジェクトの開発に貢献するための手順を説明します。

## 目次

- [開発環境のセットアップ](#開発環境のセットアップ)
- [Flavorの設定](#flavorの設定)
- [Firebaseプロジェクト情報の更新](#firebaseプロジェクト情報の更新)
- [Emulatorの設定](#emulatorの設定)

## 開発環境のセットアップ

### 必要条件

- Flutter SDK
- Firebase CLI
- Android Studio / Xcode（モバイル開発用）

## Flavorの設定

Flavorを追加する場合は、公式ドキュメントに従ってセットアップしてください。

詳細は[Flutter公式ドキュメント](https://docs.flutter.dev/deployment/flavors-ios)を参照してください。

## Firebaseプロジェクト情報の更新

### 事前準備

Firebase CLIをインストールし、ログインしておく必要があります。

```shell
# Firebase CLIのインストール
npm install -g firebase-tools

# Firebaseにログイン
firebase login
```

詳細は[Firebase Flutter セットアップガイド](https://firebase.google.com/docs/flutter/setup?hl=ja&platform=ios#install-cli-tools)を参照してください。

### 環境別の設定更新手順

以下の共通変数を設定します：

```shell
PROJECT_ID_BASE="colomney-house-worker"
APPLICATION_ID_BASE="ide.shota.colomney.HouseWorker"
```

#### Emulator環境の設定

```shell
# 環境固有の変数設定
PROJECT_ID_SUFFIX="-emulator"
APPLICATION_ID_SUFFIX=".emulator"
DART_FILE_NAME_SUFFIX="_emulator"
DIRECTORY_NAME_FOR_IOS="Emulator"
DIRECTORY_NAME_FOR_ANDROID="emulator"
PROJECT_ID="${PROJECT_ID_BASE}${PROJECT_ID_SUFFIX}"
APPLICATION_ID="${APPLICATION_ID_BASE}${APPLICATION_ID_SUFFIX}"

# Firebaseの設定ファイル生成
cd client/
flutterfire config \
  --project="${PROJECT_ID}" \
  --out="lib/firebase_options${DART_FILE_NAME_SUFFIX}.dart" \
  --ios-bundle-id="${APPLICATION_ID}" \
  --ios-out="ios/Runner/Firebase/${DIRECTORY_NAME_FOR_IOS}/GoogleService-Info.plist" \
  --android-package-name="${APPLICATION_ID}" \
  --android-out="android/app/src/${DIRECTORY_NAME_FOR_ANDROID}/google-services.json"
```

実行時、プロンプトの選択肢では以下を選んでください：
- "Build configuration"
- "Debug-emulator"

#### Dev環境の設定

```shell
# 環境固有の変数設定
PROJECT_ID_SUFFIX="-dev"
APPLICATION_ID_SUFFIX=".dev"
DART_FILE_NAME_SUFFIX="_dev"
DIRECTORY_NAME_FOR_IOS="Dev"
DIRECTORY_NAME_FOR_ANDROID="dev"
PROJECT_ID="${PROJECT_ID_BASE}${PROJECT_ID_SUFFIX}"
APPLICATION_ID="${APPLICATION_ID_BASE}${APPLICATION_ID_SUFFIX}"

# Firebaseの設定ファイル生成
cd client/
flutterfire config \
  --project="${PROJECT_ID}" \
  --out="lib/firebase_options${DART_FILE_NAME_SUFFIX}.dart" \
  --ios-bundle-id="${APPLICATION_ID}" \
  --ios-out="ios/Runner/Firebase/${DIRECTORY_NAME_FOR_IOS}/GoogleService-Info.plist" \
  --android-package-name="${APPLICATION_ID}" \
  --android-out="android/app/src/${DIRECTORY_NAME_FOR_ANDROID}/google-services.json"
```

実行時、プロンプトの選択肢では以下を選んでください：
- "Build configuration"
- "Debug-dev"

#### Prod環境の設定

```shell
# 環境固有の変数設定
PROJECT_ID_SUFFIX=""
APPLICATION_ID_SUFFIX=""
DART_FILE_NAME_SUFFIX="_prod"
DIRECTORY_NAME_FOR_IOS="Prod"
DIRECTORY_NAME_FOR_ANDROID="prod"
PROJECT_ID="${PROJECT_ID_BASE}${PROJECT_ID_SUFFIX}"
APPLICATION_ID="${APPLICATION_ID_BASE}${APPLICATION_ID_SUFFIX}"

# Firebaseの設定ファイル生成
cd client/
flutterfire config \
  --project="${PROJECT_ID}" \
  --out="lib/firebase_options${DART_FILE_NAME_SUFFIX}.dart" \
  --ios-bundle-id="${APPLICATION_ID}" \
  --ios-out="ios/Runner/Firebase/${DIRECTORY_NAME_FOR_IOS}/GoogleService-Info.plist" \
  --android-package-name="${APPLICATION_ID}" \
  --android-out="android/app/src/${DIRECTORY_NAME_FOR_ANDROID}/google-services.json"
```

## Emulatorの設定

プロジェクトではEmulatorのホストIPを`dart-define-from-file`から読み込む方法を採用しています。

### 設定ファイル

`client/emulator-config.json`ファイルに以下の形式で設定を記述します：

```json
{
  "EMULATOR_HOST": "127.0.0.1"
}
```

### 実行方法

VSCodeの起動設定では`--dart-define-from-file=client/emulator-config.json`引数を使用して設定ファイルを読み込みます。

コマンドラインから実行する場合は以下のように指定します：

```shell
flutter run --dart-define-from-file=client/emulator-config.json
