import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:house_worker/data/model/resume_section.dart';

part 'cavivara_profile.freezed.dart';

/// カヴィヴァラのプロフィール
///
/// カヴィヴァラキャラクターの基本情報、履歴書セクション、AI用プロンプトを保持する
@freezed
abstract class CavivaraProfile with _$CavivaraProfile {
  const factory CavivaraProfile({
    /// ユニークID
    required String id,

    /// 表示名
    required String displayName,

    /// 役職・肩書き
    required String title,

    /// 自己紹介・説明文
    required String description,

    /// アイコン画像のパス
    required String iconPath,

    /// AI用プロンプト
    required String aiPrompt,

    /// タグ一覧
    required List<String> tags,

    /// 履歴書セクション一覧
    required List<ResumeSection> resumeSections,
  }) = _CavivaraProfile;

  const CavivaraProfile._();
}
