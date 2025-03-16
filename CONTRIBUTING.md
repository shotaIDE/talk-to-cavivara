# 開発手順

## コミットされている Firebase のプロジェクト情報を更新

事前準備として、以下のドキュメントに従って Firebase CLI をインストールし、ログインしておきます。

https://firebase.google.com/docs/flutter/setup?hl=ja&platform=ios#install-cli-tools

以下コマンドを実行します。 途中の選択肢は、"Build configutaion"と、"Debug-emulator"または"Debug-dev"を選択します。

```shell
PROJECT_ID_BASE="colomney-house-worker"
APPLICATION_ID_BASE="ide.shota.colomney.HouseWorker"
```

Emulator 環境用。

```shell
PROJECT_ID_SUFFIX="-emulator"
APPLICATION_ID_SUFFIX=".emulator"
DIRECTORY_NAME_FOR_IOS="Emulator"
DIRECTORY_NAME_FOR_ANDROID="emulator"
PROJECT_ID="${PROJECT_ID_BASE}${PROJECT_ID_SUFFIX}"
APPLICATION_ID="${APPLICATION_ID_BASE}${APPLICATION_ID_SUFFIX}"
```

```shell
flutterfire config \
  --project="${PROJECT_ID}" \
  --out=lib/firebase_options_emulator.dart \
  --ios-bundle-id="${APPLICATION_ID}" \
  --ios-out="ios/Runner/Firebase/${DIRECTORY_NAME_FOR_IOS}/GoogleService-Info.plist" \
  --android-package-name="${APPLICATION_ID}" \
  --android-out="android/app/src/${DIRECTORY_NAME_FOR_ANDROID}/google-services.json"
```

Dev 環境用。

```shell
PROJECT_ID_SUFFIX="-dev"
APPLICATION_ID_SUFFIX=".dev"
DIRECTORY_NAME_FOR_IOS="Dev"
DIRECTORY_NAME_FOR_ANDROID="dev"
PROJECT_ID="${PROJECT_ID_BASE}${PROJECT_ID_SUFFIX}"
APPLICATION_ID="${APPLICATION_ID_BASE}${APPLICATION_ID_SUFFIX}"
```

Prod 環境用。

```shell
PROJECT_ID_SUFFIX=""
APPLICATION_ID_SUFFIX=""
DIRECTORY_NAME_FOR_IOS="Prod"
DIRECTORY_NAME_FOR_ANDROID="prod"
```
