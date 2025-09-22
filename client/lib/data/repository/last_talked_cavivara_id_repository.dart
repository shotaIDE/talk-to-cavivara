import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_talked_cavivara_id_repository.g.dart';

@riverpod
class LastTalkedCavivaraId extends _$LastTalkedCavivaraId {
  @override
  Future<String?> build() {
    final preferenceService = ref.read(preferenceServiceProvider);
    return preferenceService.getString(
      PreferenceKey.lastTalkedCavivaraId,
    );
  }

  Future<void> updateId(String cavivaraId) async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setString(
      PreferenceKey.lastTalkedCavivaraId,
      value: cavivaraId,
    );

    state = AsyncValue.data(cavivaraId);
  }
}
