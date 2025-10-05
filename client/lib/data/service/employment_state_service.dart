import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'employment_state_service.g.dart';

/// カヴィヴァラの雇用状態を管理するサービス
///
/// 雇用状態は以下の特徴を持つ：
/// - 永続化された値を読み込んで初期化する
/// - 永続化データが存在しない場合は `cavivara_default` を雇用状態とする
/// - 複数のカヴィヴァラを同時に雇用可能
@riverpod
class EmploymentState extends _$EmploymentState {
  static const _defaultCavivaraId = 'cavivara_default';
  static const _defaultEmployedState = <String>{_defaultCavivaraId};

  Future<void>? _initialization;

  @override
  Set<String> build() {
    _initialization = _restoreState();
    return _defaultEmployedState;
  }

  PreferenceService get _preferenceService =>
      ref.read(preferenceServiceProvider);

  /// 永続化された状態の読み込みが完了するまで待機する
  Future<void> ensureInitialized() async {
    final initialization = _initialization;
    if (initialization != null) {
      await initialization;
    }
  }

  /// 指定されたカヴィヴァラを雇用する
  Future<void> hire(String cavivaraId) async {
    await ensureInitialized();
    state = {...state, cavivaraId};
    await _persistState();
  }

  /// 指定されたカヴィヴァラを解雇する
  Future<void> fire(String cavivaraId) async {
    await ensureInitialized();
    state = state.where((id) => id != cavivaraId).toSet();
    await _persistState();
  }

  /// 指定されたカヴィヴァラが雇用されているかどうか
  bool isEmployed(String cavivaraId) {
    return state.contains(cavivaraId);
  }

  /// 雇用中のカヴィヴァラIDリストを取得
  List<String> get employedCavivaraIds => state.toList();

  /// 全員を解雇する
  Future<void> fireAll() async {
    await ensureInitialized();
    state = const <String>{};
    await _persistState();
  }

  Future<void> _restoreState() async {
    final storedIds = await _preferenceService
        .getStringList(PreferenceKey.employedCavivaraIds);

    if (storedIds == null) {
      state = _defaultEmployedState;
      await _persistState();
      return;
    }

    state = storedIds.toSet();
  }

  Future<void> _persistState() async {
    await _preferenceService.setStringList(
      PreferenceKey.employedCavivaraIds,
      value: state.toList(),
    );
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
