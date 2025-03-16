import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:house_worker/flavor_config.dart';
import 'main.dart' as app;

void main() async {
  // エミュレーター環境の設定
  FlavorConfig(
    flavor: Flavor.emulator,
    name: 'EMULATOR',
    color: Colors.purple,
    useFirebaseEmulator: true,
  );
  
  // メインアプリの起動
  app.main();
}
