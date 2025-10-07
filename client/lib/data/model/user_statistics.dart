import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_statistics.freezed.dart';

@freezed
sealed class UserStatistics with _$UserStatistics {
  const factory UserStatistics({
    required int sentCharacters,
    required int receivedCharacters,
    required Duration resumeViewingDuration,
  }) = _UserStatistics;

  factory UserStatistics.initial() => const UserStatistics(
    sentCharacters: 0,
    receivedCharacters: 0,
    resumeViewingDuration: Duration.zero,
  );
}
