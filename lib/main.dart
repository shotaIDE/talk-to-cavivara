import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/common/theme/app_theme.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:house_worker/models/task.dart';
import 'package:house_worker/models/user.dart';
import 'package:house_worker/models/household.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform, // firebase_options.dart が生成されたらコメントを外す
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Firebase が初期化できなくても、アプリを続行する
  }

  // Initialize Isar and store instance for later use
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    TaskSchema,
    UserSchema,
    HouseholdSchema,
  ], directory: dir.path);

  runApp(ProviderScope(child: HouseWorkerApp(isar: isar)));
}

class HouseWorkerApp extends StatelessWidget {
  final Isar isar;

  const HouseWorkerApp({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Worker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement auth state listener
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
