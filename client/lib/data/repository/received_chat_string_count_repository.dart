import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'received_chat_string_count_repository.g.dart';

@riverpod
class ReceivedChatStringCountRepository
    extends _$ReceivedChatStringCountRepository {
  @override
  Future<int> build() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    return await preferenceService.getInt(
          PreferenceKey.totalReceivedChatStringCount,
        ) ??
        0;
  }

  Future<void> add(int stringCount) async {
    if (stringCount <= 0) {
      return;
    }

    final current = await future;
    final updated = current + stringCount;
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setInt(
      PreferenceKey.totalReceivedChatStringCount,
      value: updated,
    );

    if (!ref.mounted) {
      return;
    }
    state = AsyncValue.data(updated);
  }

  Future<void> resetForDebug() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setInt(
      PreferenceKey.totalReceivedChatStringCount,
      value: 0,
    );

    if (!ref.mounted) {
      return;
    }
    state = const AsyncValue.data(0);
  }

  Future<void> setForDebug(int value) async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setInt(
      PreferenceKey.totalReceivedChatStringCount,
      value: value,
    );

    if (!ref.mounted) {
      return;
    }
    state = AsyncValue.data(value);
  }
}
