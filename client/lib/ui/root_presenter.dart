import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/model/app_session.dart';
import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/model/root_app_not_initialized.dart';
import 'package:house_worker/data/repository/last_talked_cavivara_id_repository.dart';
import 'package:house_worker/data/service/app_info_service.dart';
import 'package:house_worker/data/service/auth_service.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:house_worker/data/service/remote_config_service.dart';
import 'package:house_worker/ui/app_initial_route.dart';
import 'package:house_worker/ui/feature/home/home_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'root_presenter.g.dart';

@riverpod
Future<AppInitialRoute> appInitialRoute(Ref ref) async {
  final minimumBuildNumber = ref.watch(minimumBuildNumberProvider);
  final appSessionFuture = ref.watch(currentAppSessionProvider.future);

  // Remote Config ですでにフェッチされた値を有効化する
  await ref
      .read(updatedRemoteConfigKeysProvider.notifier)
      .ensureActivateFetchedRemoteConfigs();

  if (minimumBuildNumber != null) {
    final currentAppVersion = await ref.watch(currentAppVersionProvider.future);
    final currentBuildNumber = currentAppVersion.buildNumber;
    if (currentBuildNumber < minimumBuildNumber) {
      return const AppInitialRoute.updateApp();
    }
  }

  final appSession = await appSessionFuture;
  switch (appSession) {
    case AppSessionSignedIn():
      final cavivaraId = await _resolveInitialCavivaraId(ref);
      return AppInitialRoute.home(cavivaraId: cavivaraId);
    case AppSessionNotSignedIn():
      await ref
          .read(currentAppSessionProvider.notifier)
          .ensureSignedInAnonymously();
      final cavivaraId = await _resolveInitialCavivaraId(ref);
      return AppInitialRoute.home(cavivaraId: cavivaraId);
  }
}

Future<String> _resolveInitialCavivaraId(Ref ref) async {
  final lastTalkedCavivaraId = await ref.read(
    lastTalkedCavivaraIdProvider.future,
  );
  return lastTalkedCavivaraId ?? HomeScreen.defaultCavivaraId;
}

@riverpod
class CurrentAppSession extends _$CurrentAppSession {
  @override
  Future<AppSession> build() async {
    final isSignedIn = await ref.watch(isSignedInProvider.future);
    if (!isSignedIn) {
      return AppSession.notSignedIn();
    }

    return _createSignedInSession();
  }

  Future<void> signIn({required String userId, required String houseId}) async {
    // TODO(ide): RevenueCatから取得する開発用。本番リリース時には削除する
    const isPro = false;

    state = AsyncValue.data(
      AppSession.signedIn(counterId: houseId, isPro: isPro),
    );
  }

  Future<void> signOut() async {
    state = AsyncValue.data(AppSession.notSignedIn());
  }

  Future<void> upgradeToPro() async {
    final currentAppSession = state.valueOrNull;

    if (currentAppSession case AppSessionSignedIn()) {
      final newState = currentAppSession.copyWith(isPro: true);
      state = AsyncValue.data(newState);
    }
  }

  Future<AppSessionSignedIn> ensureSignedInAnonymously() async {
    final currentAppSession = state.valueOrNull ?? await future;
    if (currentAppSession case AppSessionSignedIn()) {
      return currentAppSession;
    }

    final authService = ref.read(authServiceProvider);
    await authService.signInAnonymously();

    final newSession = await _createSignedInSession();
    if (newSession case AppSessionSignedIn()) {
      state = AsyncValue.data(newSession);
      return newSession;
    }

    throw StateError('Failed to sign in anonymously.');
  }

  Future<AppSession> _createSignedInSession() async {
    final preferenceService = ref.read(preferenceServiceProvider);

    final houseId =
        await preferenceService.getString(PreferenceKey.currentHouseId) ??
        // TODO(ide): 開発用。本番リリース時には削除する
        'default-house-id';

    // TODO(ide): RevenueCatから取得する開発用。本番リリース時には削除する
    const isPro = false;

    return AppSession.signedIn(counterId: houseId, isPro: isPro);
  }
}

@riverpod
AppSession unwrappedCurrentAppSession(Ref ref) {
  final appSessionAsync = ref.watch(currentAppSessionProvider);
  final appSession = appSessionAsync.whenOrNull(
    data: (appSession) => appSession,
  );
  if (appSession == null) {
    throw RootAppNotInitializedError();
  }

  return appSession;
}
