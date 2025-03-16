import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:house_worker/flavor_config.dart';
import 'firebase_options_prod.dart';
import 'main.dart' as app;

void main() async {
  // 本番環境の設定
  FlavorConfig(
    flavor: Flavor.prod,
    name: 'PROD',
    color: Colors.blue,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    useFirebaseEmulator: false,
  );
  
  // メインアプリの起動
  app.main();
}
