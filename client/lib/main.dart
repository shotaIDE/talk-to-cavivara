import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/common/theme/app_theme.dart';
import 'package:house_worker/features/auth/login_screen.dart';
import 'package:house_worker/features/home/home_screen.dart';
import 'package:house_worker/flavor_config.dart';
import 'package:house_worker/services/auth_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:house_worker/models/task.dart';
import 'package:house_worker/models/user.dart';
import 'package:house_worker/models/household.dart';
import 'firebase_options_dev.dart' as dev;
import 'firebase_options_prod.dart' as prod;

// Isarインスタンスのプロバイダー
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

// Firebase Emulatorの設定を読み込むためのプロバイダー
final emulatorConfigProvider = Provider<Map<String, dynamic>>(
  (ref) => throw UnimplementedError(),
);

// Firebase Emulatorのホスト情報を取得する関数
Future<String> getEmulatorHost() async {
  try {
    // Dart Definesから設定を読み込む
    final String configJson = await rootBundle.loadString(
      'emulator-config.json',
    );
    final Map<String, dynamic> config = json.decode(configJson);
    return config['emulator_host'] ?? 'localhost';
  } catch (e) {
    print('エミュレーター設定の読み込みに失敗しました: $e');
    // デフォルト値を返す
    return 'localhost';
  }
}

// Firebase Emulatorの設定を行う関数
void setupFirebaseEmulators(String host) {
  FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  // Functionsも使用する場合は以下を追加
  // FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
}

// 環境設定を行う関数
void setupFlavorConfig() {
  // Flutterのビルド設定から自動的にflavorを取得
  // Flutterのビルドシステムで設定されたFLAVOR環境変数を使用
  final flavorName = const String.fromEnvironment(
    'FLUTTER_APP_FLAVOR',
    defaultValue: 'emulator',
  );

  print('検出されたflavor: $flavorName');

  switch (flavorName.toLowerCase()) {
    case 'prod':
      FlavorConfig(
        flavor: Flavor.prod,
        name: 'PROD',
        color: Colors.blue,
        firebaseOptions: prod.DefaultFirebaseOptions.currentPlatform,
        useFirebaseEmulator: false,
      );
      break;
    case 'emulator':
      FlavorConfig(
        flavor: Flavor.emulator,
        name: 'EMULATOR',
        color: Colors.purple,
        useFirebaseEmulator: true,
      );
      break;
    case 'dev':
    default:
      FlavorConfig(
        flavor: Flavor.dev,
        name: 'DEV',
        color: Colors.green,
        firebaseOptions: dev.DefaultFirebaseOptions.currentPlatform,
        useFirebaseEmulator: false,
      );
      break;
  }

  print('アプリケーション環境: ${FlavorConfig.instance.name}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 環境設定の初期化
  setupFlavorConfig();

  try {
    // Firebase初期化
    if (FlavorConfig.instance.firebaseOptions != null) {
      await Firebase.initializeApp(
        options: FlavorConfig.instance.firebaseOptions!,
      );
    } else {
      await Firebase.initializeApp();
    }
    print('Firebase initialized successfully');

    // エミュレーターの設定が有効な場合のみ適用
    if (FlavorConfig.instance.useFirebaseEmulator) {
      // エミュレーターのホスト情報を取得
      final emulatorHost = await getEmulatorHost();
      print('エミュレーターホスト: $emulatorHost');

      // エミュレーターの設定を適用
      setupFirebaseEmulators(emulatorHost);
      print('Firebase Emulator設定を適用しました');
    }
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Firebase が初期化できなくても、アプリを続行する
  }

  // Initialize Isar and store instance for later use
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    UserSchema,
    TaskSchema,
    HouseholdSchema,
  ], directory: dir.path);

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const HouseWorkerApp(),
    ),
  );
}

class HouseWorkerApp extends StatelessWidget {
  const HouseWorkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Worker ${FlavorConfig.instance.name}',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: !FlavorConfig.isProd,
      builder: (context, child) {
        // Flavorに応じたバナーを表示（本番環境以外）
        if (!FlavorConfig.isProd) {
          return Banner(
            message: FlavorConfig.instance.name,
            location: BannerLocation.topEnd,
            color: FlavorConfig.instance.color,
            child: child!,
          );
        }
        return child!;
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stackTrace) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('エラーが発生しました'),
                  const SizedBox(height: 10),
                  Text(error.toString()),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(authStateProvider);
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
