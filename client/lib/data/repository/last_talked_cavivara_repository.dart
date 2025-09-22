import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_talked_cavivara_repository.g.dart';

@riverpod
LastTalkedCavivaraRepository lastTalkedCavivaraRepository(Ref ref) {
  return LastTalkedCavivaraRepository(
    preferenceService: ref.read(preferenceServiceProvider),
  );
}

/// 最後に会話したカヴィヴァラIDの永続化を管理するリポジトリ
class LastTalkedCavivaraRepository {
  const LastTalkedCavivaraRepository({
    required this.preferenceService,
  });

  final PreferenceService preferenceService;

  /// 最後に会話したカヴィヴァラIDを取得する
  Future<String?> get() {
    return preferenceService.getString(PreferenceKey.lastTalkedCavivaraId);
  }

  /// 最後に会話したカヴィヴァラIDを保存する
  Future<void> save(String cavivaraId) async {
    await preferenceService.setString(
      PreferenceKey.lastTalkedCavivaraId,
      value: cavivaraId,
    );
  }
}
