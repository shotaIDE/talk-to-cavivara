import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'employment_state_service.g.dart';

/// カヴィヴァラの雇用状態を管理するサービス
///
/// 雇用状態は以下の特徴を持つ：
/// - アプリ起動時はすべてのカヴィヴァラが未雇用状態で開始
/// - 永続化は行わない（アプリ再起動で状態がリセットされる）
/// - 複数のカヴィヴァラを同時に雇用可能
@riverpod
class EmploymentState extends _$EmploymentState {
  @override
  Set<String> build() {
    // 初期状態：全員未雇用
    // 永続化は不要（アプリ再起動時にリセットされる設計）
    return const <String>{};
  }

  /// 指定されたカヴィヴァラを雇用する
  void hire(String cavivaraId) {
    state = {...state, cavivaraId};
  }

  /// 指定されたカヴィヴァラを解雇する
  void fire(String cavivaraId) {
    state = state.where((id) => id != cavivaraId).toSet();
  }

  /// 指定されたカヴィヴァラが雇用されているかどうか
  bool isEmployed(String cavivaraId) {
    return state.contains(cavivaraId);
  }

  /// 雇用中のカヴィヴァラIDリストを取得
  List<String> get employedCavivaraIds => state.toList();

  /// 全員を解雇する
  void fireAll() {
    state = const <String>{};
  }
}

/// 特定のカヴィヴァラの雇用状態を取得するプロバイダー
@riverpod
bool isEmployed(Ref ref, String cavivaraId) {
  final employmentState = ref.watch(employmentStateProvider);
  return employmentState.contains(cavivaraId);
}

/// 雇用中のカヴィヴァラIDリストを取得するプロバイダー
@riverpod
List<String> employedCavivaraIds(Ref ref) {
  final employmentState = ref.watch(employmentStateProvider);
  return employmentState.toList();
}
