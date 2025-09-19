import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/model/cavivara_profile.dart';
import 'package:house_worker/data/model/cavivara_profiles_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cavivara_directory_service.g.dart';

/// カヴィヴァラが見つからない場合の例外
class CavivaraNotFoundException implements Exception {
  const CavivaraNotFoundException(this.id);

  final String id;

  @override
  String toString() =>
      'CavivaraNotFoundException: Cavivara with id "$id" not found';
}

/// 全てのカヴィヴァラプロフィールを提供するプロバイダー
@riverpod
List<CavivaraProfile> cavivaraDirectory(Ref ref) {
  return CavivaraProfilesData.allProfiles;
}

/// 指定されたIDのカヴィヴァラプロフィールを取得するプロバイダー
@riverpod
CavivaraProfile cavivaraById(Ref ref, String id) {
  final profiles = ref.watch(cavivaraDirectoryProvider);

  for (final profile in profiles) {
    if (profile.id == id) {
      return profile;
    }
  }

  throw CavivaraNotFoundException(id);
}
