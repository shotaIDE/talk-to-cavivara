# 開発手順

## コミットされている Firebase のプロジェクト情報を更新

事前準備として、以下のドキュメントに従って Firebase CLI をインストールし、ログインしておきます。

https://firebase.google.com/docs/flutter/setup?hl=ja&platform=ios#install-cli-tools

以下コマンドを実行します。 途中の選択肢は、"Build configutaion"と、"Debug-emulator"または"Debug-dev"を選択します。

```shell
PROJECT_ID_BASE="colomney-house-worker"
PROJECT_ID_SUFFIX="-dev"
PROJECT_ID="${PROJECT_ID_BASE}${PROJECT_ID_SUFFIX}"
APPLICATION_ID_BASE="ide.shota.colomney.HouseWorker"
APPLICATION_ID_SUFFIX=".dev"
APPLICATION_ID="${APPLICATION_ID_BASE}${APPLICATION_ID_SUFFIX}"
flutterfire config \
  --project="${PROJECT_ID}" \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id="${APPLICATION_ID}" \
  --ios-out=ios/Runner/Firebase/Dev/GoogleService-Info.plist \
  --android-package-name="${APPLICATION_ID}" \
  --android-out=android/app/src/dev/google-services.json
```
