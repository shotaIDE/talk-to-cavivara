import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'has_earned_leader_reward_repository.g.dart';

@riverpod
class HasEarnedLeaderRewardRepository
    extends _$HasEarnedLeaderRewardRepository {
  @override
  Future<bool> build() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    final value = await preferenceService.getBool(
      PreferenceKey.hasEarnedLeaderReward,
    );
    return value ?? false;
  }

  Future<void> markAsEarned() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setBool(
      PreferenceKey.hasEarnedLeaderReward,
      value: true,
    );

    state = const AsyncValue.data(true);
  }
}
