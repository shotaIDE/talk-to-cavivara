import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'has_earned_part_timer_reward_repository.g.dart';

@riverpod
class HasEarnedPartTimerRewardRepository
    extends _$HasEarnedPartTimerRewardRepository {
  @override
  Future<bool> build() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    final value = await preferenceService.getBool(
      PreferenceKey.hasEarnedPartTimerReward,
    );
    return value ?? false;
  }

  Future<void> markAsEarned() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setBool(
      PreferenceKey.hasEarnedPartTimerReward,
      value: true,
    );

    state = const AsyncValue.data(true);
  }
}
