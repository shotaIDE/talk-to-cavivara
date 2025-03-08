# House Worker Client

## Update Firebase configuration dart files

If you want to update Firebase configuration dart files, execute the following command at first.

https://firebase.google.com/docs/flutter/setup?hl=ja&platform=ios#install-cli-tools

```
firebase use --clear
flutterfire config \
 --project=colomney-house-worker-dev \
 --out=lib/firebase_options_emulator.dart \
 --ios-bundle-id=ide.shota.colomney.HouseWorker.dev \
 --android-app-id=ide.shota.colomney.HouseWorker.dev
```
