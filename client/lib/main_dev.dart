import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:house_worker/flavor_config.dart';
import 'firebase_options_dev.dart';
import 'main.dart' as app;

void main() async {
  // 開発環境の設定
  FlavorConfig(
    flavor: Flavor.dev,
    name: 'DEV',
    color: Colors.green,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    useFirebaseEmulator: false,
  );
  
  // メインアプリの起動
  app.main();
}
