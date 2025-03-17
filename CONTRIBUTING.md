# 開発貢献ガイド

このドキュメントでは、House Worker プロジェクトの開発に貢献するための手順を説明します。

## 目次

- [開発環境のセットアップ](#開発環境のセットアップ)
- [Flavor の設定](#flavorの設定)
- [Firebase プロジェクト情報の更新](#firebaseプロジェクト情報の更新)
- [Emulator の設定](#emulatorの設定)

## 開発環境のセットアップ

### 必要条件

- Flutter SDK
- Firebase CLI
- Android Studio / Xcode（モバイル開発用）

## Flavor の設定

Flavor を追加する場合は、公式ドキュメントに従ってセットアップしてください。

詳細は[Flutter 公式ドキュメント](https://docs.flutter.dev/deployment/flavors-ios)を参照してください。

## Firebase プロジェクト情報の更新

### 事前準備

Firebase CLI をインストールし、ログインしておく必要があります。

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

#### Emulator 環境の設定

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

#### Dev 環境の設定

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

#### Prod 環境の設定

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

## Emulator の設定

プロジェクトでは Emulator のホスト IP を`dart-define-from-file`から読み込む方法を採用しています。

### 設定ファイル

プロジェクトには`client/emulator-config.sample.json`というサンプルファイルが含まれています。このファイルをコピーして`client/emulator-config.json`を作成してください。

```shell
# サンプルファイルから設定ファイルを作成
cp client/emulator-config.sample.json client/emulator-config.json
```

作成した`client/emulator-config.json`ファイルには以下の形式で設定が記述されています：

```json
{
  "EMULATOR_HOST": "127.0.0.1"
}
```

必要に応じて`EMULATOR_HOST`の値を変更してください。デフォルト値は`127.0.0.1`です。

> **注意**: `emulator-config.json`は gitignore に設定されており、リポジトリにはコミットされません。各開発者が自分の環境に合わせて設定する必要があります。

### 実行方法

VSCode の起動設定を利用してください。プロジェクトには適切な起動構成が含まれており、自動的に `--dart-define-from-file=client/emulator-config.json` 引数を使用して設定ファイルを読み込みます。

VSCode の「実行とデバッグ」パネルから適切な構成を選択して実行することをお勧めします。
