import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resume_viewing_duration_repository.g.dart';

@riverpod
class ResumeViewingDurationRepository
    extends _$ResumeViewingDurationRepository {
  @override
  Future<Duration> build() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    final milliseconds =
        await preferenceService.getInt(
          PreferenceKey.resumeViewingMilliseconds,
        ) ??
        0;
    return Duration(milliseconds: milliseconds);
  }

  Future<void> add(Duration duration) async {
    if (duration <= Duration.zero) {
      return;
    }

    final current = await future;
    final updated = current + duration;
    await _save(updated);

    if (!ref.mounted) {
      return;
    }
    state = AsyncValue.data(updated);
  }

  Future<void> _save(Duration duration) async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setInt(
      PreferenceKey.resumeViewingMilliseconds,
      value: duration.inMilliseconds,
    );
  }
}
