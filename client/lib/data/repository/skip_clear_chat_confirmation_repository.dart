import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'skip_clear_chat_confirmation_repository.g.dart';

@riverpod
class SkipClearChatConfirmation extends _$SkipClearChatConfirmation {
  @override
  Future<bool> build() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    final value = await preferenceService.getBool(
      PreferenceKey.skipClearChatConfirmation,
    );
    return value ?? false;
  }

  Future<void> updateSkip({required bool shouldSkip}) async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setBool(
      PreferenceKey.skipClearChatConfirmation,
      value: shouldSkip,
    );

    state = AsyncValue.data(shouldSkip);
  }
}
