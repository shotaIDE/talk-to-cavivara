import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/data/model/app_session.dart';
import 'package:house_worker/data/model/app_version.dart';
import 'package:house_worker/data/repository/last_talked_cavivara_id_repository.dart';
import 'package:house_worker/data/service/app_info_service.dart';
import 'package:house_worker/data/service/remote_config_service.dart';
import 'package:house_worker/ui/app_initial_route.dart';
import 'package:house_worker/ui/feature/home/home_screen.dart';
import 'package:house_worker/ui/root_presenter.dart';

class _FakeUpdatedRemoteConfigKeys extends UpdatedRemoteConfigKeys {
  @override
  Stream<Set<String>> build() => const Stream.empty();

  @override
  Future<void> ensureActivateFetchedRemoteConfigs() async {}
}

class _FakeCurrentAppSession extends CurrentAppSession {
  _FakeCurrentAppSession({required this.initialSession});

  final AppSession initialSession;
  var ensureCalled = false;

  @override
  Future<AppSession> build() async => initialSession;

  @override
  Future<AppSessionSignedIn> ensureSignedInAnonymously() async {
    ensureCalled = true;
    final session = AppSession.signedIn(
      counterId: 'fake-house-id',
      isPro: false,
    );
    state = AsyncValue.data(session);
    return session as AppSessionSignedIn;
  }
}

class _FakeLastTalkedCavivaraId extends LastTalkedCavivaraId {
  _FakeLastTalkedCavivaraId(this.initialId);

  final String? initialId;

  @override
  Future<String?> build() async => initialId;
}

ProviderContainer _createContainer({
  required _FakeCurrentAppSession currentAppSession,
  required _FakeLastTalkedCavivaraId lastTalked,
}) {
  return ProviderContainer(
    overrides: [
      updatedRemoteConfigKeysProvider.overrideWith(
        () => _FakeUpdatedRemoteConfigKeys(),
      ),
      minimumBuildNumberProvider.overrideWith((ref) => null),
      currentAppVersionProvider.overrideWith(
        (ref) async => AppVersion(version: '1.0.0', buildNumber: 1),
      ),
      currentAppSessionProvider.overrideWith(() => currentAppSession),
      lastTalkedCavivaraIdProvider.overrideWith(() => lastTalked),
    ],
  );
}

void main() {
  group('appInitialRoute', () {
    test('returns home with last talked Cavivara when available', () async {
      const lastTalkedId = 'cavivara_mascot';
      final currentSession = _FakeCurrentAppSession(
        initialSession: AppSession.signedIn(counterId: 'house', isPro: false),
      );
      final lastTalked = _FakeLastTalkedCavivaraId(lastTalkedId);
      final container = _createContainer(
        currentAppSession: currentSession,
        lastTalked: lastTalked,
      );
      addTearDown(container.dispose);

      final route = await container.read(appInitialRouteProvider.future);

      expect(
        route,
        const AppInitialRoute.home(cavivaraId: lastTalkedId),
      );
      expect(currentSession.ensureCalled, isFalse);
    });

    test('returns home with default Cavivara when last talked is absent',
        () async {
      final currentSession = _FakeCurrentAppSession(
        initialSession: AppSession.signedIn(counterId: 'house', isPro: false),
      );
      final lastTalked = _FakeLastTalkedCavivaraId(null);
      final container = _createContainer(
        currentAppSession: currentSession,
        lastTalked: lastTalked,
      );
      addTearDown(container.dispose);

      final route = await container.read(appInitialRouteProvider.future);

      expect(
        route,
        const AppInitialRoute.home(
          cavivaraId: HomeScreen.defaultCavivaraId,
        ),
      );
      expect(currentSession.ensureCalled, isFalse);
    });

    test('signs in anonymously when not signed in and opens default chat',
        () async {
      final currentSession = _FakeCurrentAppSession(
        initialSession: AppSession.notSignedIn(),
      );
      final lastTalked = _FakeLastTalkedCavivaraId(null);
      final container = _createContainer(
        currentAppSession: currentSession,
        lastTalked: lastTalked,
      );
      addTearDown(container.dispose);

      final route = await container.read(appInitialRouteProvider.future);

      expect(
        route,
        const AppInitialRoute.home(
          cavivaraId: HomeScreen.defaultCavivaraId,
        ),
      );
      expect(currentSession.ensureCalled, isTrue);
      final sessionValue = container.read(currentAppSessionProvider).valueOrNull;
      expect(sessionValue, isA<AppSessionSignedIn>());
    });
  });
}
