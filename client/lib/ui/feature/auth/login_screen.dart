import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/ui/feature/auth/login_presenter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const name = 'LoginScreen';

  static MaterialPageRoute<LoginScreen> route() =>
      MaterialPageRoute<LoginScreen>(
        builder: (_) => const LoginScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final continueWithoutAccountButton = TextButton(
      onPressed: _startWithoutAccount,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      ),
      child: const Text('はじめる'),
    );

    final children = <Widget>[
      const Text(
        'カヴィヴァラチャット',
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      const Text(
        'カヴィヴァラさんと\n楽しくおしゃべりしよう',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 60),
      continueWithoutAccountButton,
    ];

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Future<void> _startWithoutAccount() async {
    await ref.read(startResultProvider.notifier).startWithoutAccount();

    // ホーム画面への遷移は RootApp で自動で行われる
  }
}
