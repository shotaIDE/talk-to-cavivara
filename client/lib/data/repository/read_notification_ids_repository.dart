import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'read_notification_ids_repository.g.dart';

@riverpod
class ReadNotificationIds extends _$ReadNotificationIds {
  @override
  Future<List<String>> build() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    final ids = await preferenceService.getStringList(
      PreferenceKey.readNotificationIds,
    );
    return ids ?? [];
  }

  Future<void> markAsRead(String notificationId) async {
    final current = await future;
    if (current.contains(notificationId)) {
      return;
    }

    final updated = [...current, notificationId];
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setStringList(
      PreferenceKey.readNotificationIds,
      value: updated,
    );

    if (!ref.mounted) {
      return;
    }
    state = AsyncValue.data(updated);
  }

  Future<void> resetForDebug() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setStringList(
      PreferenceKey.readNotificationIds,
      value: [],
    );

    if (!ref.mounted) {
      return;
    }
    state = const AsyncValue.data([]);
  }
}
