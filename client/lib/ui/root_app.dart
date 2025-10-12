import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/definition/app_feature.dart';
import 'package:house_worker/data/definition/flavor.dart';
import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/repository/received_chat_string_count_repository.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:house_worker/data/service/remote_config_service.dart';
import 'package:house_worker/ui/app_initial_route.dart';
import 'package:house_worker/ui/component/app_theme.dart';
import 'package:house_worker/ui/component/heads_up_notification_overlay.dart';
import 'package:house_worker/ui/component/heads_up_notification_presenter.dart';
import 'package:house_worker/ui/feature/auth/login_screen.dart';
import 'package:house_worker/ui/feature/home/home_screen.dart';
import 'package:house_worker/ui/feature/job_market/job_market_screen.dart';
import 'package:house_worker/ui/feature/stats/cavivara_title.dart';
import 'package:house_worker/ui/feature/stats/user_statistics_screen.dart';
import 'package:house_worker/ui/feature/update/update_app_screen.dart';
import 'package:house_worker/ui/root_presenter.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class RootApp extends ConsumerStatefulWidget {
  const RootApp({super.key});

  @override
  ConsumerState<RootApp> createState() => _RootAppState();
}

class _RootAppState extends ConsumerState<RootApp> {
  ProviderSubscription<AsyncValue<int>>? _receivedChatCountSubscription;
  bool _isTitleNotificationInitialized = false;
  int _maxNotifiedTitleThreshold = 0;
  int? _pendingReceivedCount;
  int? _pendingPreviousCount;

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

    _receivedChatCountSubscription = ref.listenManual(
      receivedChatStringCountRepositoryProvider,
      (previous, next) {
        final previousValue = previous?.whenOrNull(data: (value) => value);
        final currentValue = next.whenOrNull(data: (value) => value);
        _handleReceivedChatCountUpdate(previousValue, currentValue);
      },
    );

    Future(() async {
      await _initializeTitleNotificationThreshold();
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
      navigatorKey: rootNavigatorKey,
      routes: {'/': (_) => const JobMarketScreen()},
      // `initialRoute` and `routes` are ineffective settings
      // that are set to avoid assertion errors.
      initialRoute: '/',
      onGenerateInitialRoutes: (_) => initialRoutes,
      navigatorObservers: navigatorObservers,
      title: 'カヴィヴァラチャット',
      builder: (_, child) {
        final wrappedChild = HeadsUpNotificationOverlay(child: child);
        return _wrapByAppBanner(wrappedChild);
      },
      darkTheme: getDarkTheme(),
      themeMode: ThemeMode.dark,
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
    final content = child ?? const SizedBox.shrink();
    if (!showCustomAppBanner) {
      return content;
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
      child: content,
    );
  }

  Future<void> _initializeTitleNotificationThreshold() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    final stored =
        await preferenceService.getInt(
          PreferenceKey.maxReceivedChatTitleThresholdNotified,
        ) ??
        0;
    _maxNotifiedTitleThreshold = stored;
    _isTitleNotificationInitialized = true;

    if (_pendingReceivedCount != null) {
      _maybeNotifyTitleUnlocked(
        _pendingPreviousCount,
        _pendingReceivedCount!,
      );
      _pendingReceivedCount = null;
      _pendingPreviousCount = null;
    }
  }

  void _handleReceivedChatCountUpdate(int? previous, int? current) {
    if (current == null) {
      return;
    }

    if (!_isTitleNotificationInitialized) {
      _pendingReceivedCount = current;
      _pendingPreviousCount = previous;
      return;
    }

    _maybeNotifyTitleUnlocked(previous, current);
  }

  void _maybeNotifyTitleUnlocked(int? previous, int current) {
    final newlyAchieved = CavivaraTitle.highestAchieved(current);
    if (newlyAchieved == null) {
      return;
    }

    final newThreshold = newlyAchieved.threshold;
    if (newThreshold <= _maxNotifiedTitleThreshold) {
      return;
    }

    if (previous == null || previous >= newThreshold) {
      _updateNotifiedThreshold(newThreshold);
      return;
    }

    _updateNotifiedThreshold(newThreshold);
    ref
        .read(headsUpNotificationProvider.notifier)
        .show(
          HeadsUpNotificationData(
            title: '称号を獲得しました',
            message: '${newlyAchieved.displayName} を獲得しました',
            onTap: () {
              final navigator = rootNavigatorKey.currentState;
              navigator?.push(
                UserStatisticsScreen.route(
                  highlightedTitle: newlyAchieved,
                ),
              );
            },
          ),
        );
  }

  void _updateNotifiedThreshold(int threshold) {
    _maxNotifiedTitleThreshold = threshold;
    final preferenceService = ref.read(preferenceServiceProvider);
    unawaited(
      preferenceService.setInt(
        PreferenceKey.maxReceivedChatTitleThresholdNotified,
        value: threshold,
      ),
    );
  }

  @override
  void dispose() {
    _receivedChatCountSubscription?.close();
    super.dispose();
  }
}
