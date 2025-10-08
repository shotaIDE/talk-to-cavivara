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
    final sentStringCount =
        await preferenceService.getInt(
          PreferenceKey.totalSentChatStringCount,
        ) ??
        0;
    final receivedStringCount =
        await preferenceService.getInt(
          PreferenceKey.totalReceivedChatStringCount,
        ) ??
        0;
    final resumeViewingMilliseconds =
        await preferenceService.getInt(
          PreferenceKey.resumeViewingMilliseconds,
        ) ??
        0;

    return UserStatistics(
      sentStringCount: sentStringCount,
      receivedStringCount: receivedStringCount,
      resumeViewingDuration: Duration(milliseconds: resumeViewingMilliseconds),
    );
  }

  Future<void> addSentCharacters(int stringCount) async {
    if (stringCount <= 0) {
      return;
    }

    final current = await future;
    final updated = current.copyWith(
      sentStringCount: current.sentStringCount + stringCount,
    );
    await _save(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> addReceivedCharacters(int stringCount) async {
    if (stringCount <= 0) {
      return;
    }

    final current = await future;
    final updated = current.copyWith(
      receivedStringCount: current.receivedStringCount + stringCount,
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
      PreferenceKey.totalSentChatStringCount,
      value: statistics.sentStringCount,
    );
    await preferenceService.setInt(
      PreferenceKey.totalReceivedChatStringCount,
      value: statistics.receivedStringCount,
    );
    await preferenceService.setInt(
      PreferenceKey.resumeViewingMilliseconds,
      value: statistics.resumeViewingDuration.inMilliseconds,
    );
  }
}
