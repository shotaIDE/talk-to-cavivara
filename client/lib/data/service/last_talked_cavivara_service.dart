import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';

class LastTalkedCavivaraIdNotifier extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    return preferenceService.getString(PreferenceKey.lastTalkedCavivaraId);
  }

  Future<void> update(String cavivaraId) async {
    final preferenceService = ref.read(preferenceServiceProvider);
    await preferenceService.setString(
      PreferenceKey.lastTalkedCavivaraId,
      value: cavivaraId,
    );
    state = AsyncValue.data(cavivaraId);
  }
}

final lastTalkedCavivaraIdProvider =
    AsyncNotifierProvider<LastTalkedCavivaraIdNotifier, String?>(
  LastTalkedCavivaraIdNotifier.new,
);
