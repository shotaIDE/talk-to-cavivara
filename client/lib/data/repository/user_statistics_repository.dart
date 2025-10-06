import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/model/user_statistics.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_statistics_repository.g.dart';

@riverpod
class UserStatisticsRepository extends _$UserStatisticsRepository {
  @override
  Future<UserStatistics> build() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    final sentCharacters =
        await preferenceService.getInt(PreferenceKey.totalSentChatCharacters) ??
        0;
    final receivedCharacters =
        await preferenceService.getInt(
          PreferenceKey.totalReceivedChatCharacters,
        ) ??
        0;
    final resumeViewingMilliseconds =
        await preferenceService.getInt(
          PreferenceKey.resumeViewingMilliseconds,
        ) ??
        0;

    return UserStatistics(
      sentCharacters: sentCharacters,
      receivedCharacters: receivedCharacters,
      resumeViewingDuration: Duration(milliseconds: resumeViewingMilliseconds),
    );
  }

  Future<void> addSentCharacters(int characters) async {
    if (characters <= 0) {
      return;
    }

    final current = await future;
    final updated = current.copyWith(
      sentCharacters: current.sentCharacters + characters,
    );
    await _save(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> addReceivedCharacters(int characters) async {
    if (characters <= 0) {
      return;
    }

    final current = await future;
    final updated = current.copyWith(
      receivedCharacters: current.receivedCharacters + characters,
    );
    await _save(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> addResumeViewingDuration(Duration duration) async {
    if (duration <= Duration.zero) {
      return;
    }

    final current = await future;
    final updated = current.copyWith(
      resumeViewingDuration: current.resumeViewingDuration + duration,
    );
    await _save(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> _save(UserStatistics statistics) async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setInt(
      PreferenceKey.totalSentChatCharacters,
      value: statistics.sentCharacters,
    );
    await preferenceService.setInt(
      PreferenceKey.totalReceivedChatCharacters,
      value: statistics.receivedCharacters,
    );
    await preferenceService.setInt(
      PreferenceKey.resumeViewingMilliseconds,
      value: statistics.resumeViewingDuration.inMilliseconds,
    );
  }
}
