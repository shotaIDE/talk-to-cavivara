import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sent_chat_string_count_repository.g.dart';

@riverpod
class SentChatStringCountRepository extends _$SentChatStringCountRepository {
  @override
  Future<int> build() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    return await preferenceService.getInt(
          PreferenceKey.totalSentChatStringCount,
        ) ??
        0;
  }

  Future<void> add(int stringCount) async {
    if (stringCount <= 0) {
      return;
    }

    final current = await future;
    if (!ref.mounted) {
      return;
    }

    final updated = current + stringCount;
    await _save(updated);
    if (!ref.mounted) {
      return;
    }

    state = AsyncValue.data(updated);
  }

  Future<void> _save(int count) async {
    if (!ref.mounted) {
      return;
    }
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setInt(
      PreferenceKey.totalSentChatStringCount,
      value: count,
    );
  }
}
