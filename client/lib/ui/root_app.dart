import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/definition/app_feature.dart';
import 'package:house_worker/data/definition/flavor.dart';
import 'package:house_worker/data/service/remote_config_service.dart';
import 'package:house_worker/ui/app_initial_route.dart';
import 'package:house_worker/ui/component/app_theme.dart';
import 'package:house_worker/ui/feature/auth/login_screen.dart';
import 'package:house_worker/ui/feature/home/home_screen.dart';
import 'package:house_worker/ui/feature/job_market/job_market_screen.dart';
import 'package:house_worker/ui/feature/update/update_app_screen.dart';
import 'package:house_worker/ui/root_presenter.dart';

class RootApp extends ConsumerStatefulWidget {
  const RootApp({super.key});

  @override
  ConsumerState<RootApp> createState() => _RootAppState();
}

class _RootAppState extends ConsumerState<RootApp> {
  @override
  void initState() {
    super.initState();

    ref.listenManual(updatedRemoteConfigKeysProvider, (_, next) {
      next.maybeWhen(
        data: (keys) {
          // Remote Config の変更を監視し、次回 `RootApp` が生成された際に有効になるようにする。
          // リスナー側が何も行わなくても、ライブラリは変更された値を保持する。
          // https://firebase.google.com/docs/remote-config/loading#strategy_3_load_new_values_for_next_startup
          debugPrint('Updated remote config keys: $keys');
        },
        orElse: () {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final appInitialRouteAsync = ref.watch(appInitialRouteProvider);
    final appInitialRoute = appInitialRouteAsync.whenOrNull(
      data: (appInitialRoute) => appInitialRoute,
    );
    if (appInitialRoute == null) {
      return Container();
    }

    final List<MaterialPageRoute<Widget>> initialRoutes;

    switch (appInitialRoute) {
      case AppInitialRouteUpdateApp():
        initialRoutes = [UpdateAppScreen.route()];
      case AppInitialRouteLogin():
        initialRoutes = [LoginScreen.route()];
      case AppInitialRouteHome(:final cavivaraId):
        initialRoutes = [HomeScreen.route(cavivaraId)];
      case AppInitialRouteJobMarket():
        initialRoutes = [JobMarketScreen.route()];
    }

    final navigatorObservers = <NavigatorObserver>[
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ];

    return MaterialApp(
      routes: {'/': (_) => const JobMarketScreen()},
      // `initialRoute` and `routes` are ineffective settings
      // that are set to avoid assertion errors.
      initialRoute: '/',
      onGenerateInitialRoutes: (_) => initialRoutes,
      navigatorObservers: navigatorObservers,
      title: 'カヴィヴァラチャット',
      builder: (_, child) => _wrapByAppBanner(child),
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      // `_wrapByAppBanner` でオリジナルのバナーを表示するため、
      // デフォルトのデバッグバナーは無効化する
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _wrapByAppBanner(Widget? child) {
    if (!showCustomAppBanner) {
      return child!;
    }

    final message = flavor.name.toUpperCase();

    final Color color;
    switch (flavor) {
      case Flavor.emulator:
        color = Colors.green;
      case Flavor.dev:
        color = Colors.blue;
      case Flavor.prod:
        color = Colors.red;
    }

    return Banner(
      message: message,
      location: BannerLocation.topEnd,
      color: color,
      child: child,
    );
  }
}
