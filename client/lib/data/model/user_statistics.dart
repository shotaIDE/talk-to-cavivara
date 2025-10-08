import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_statistics.freezed.dart';

@freezed
sealed class UserStatistics with _$UserStatistics {
  const factory UserStatistics({
    required int sentStringCount,
    required int receivedStringCount,
    required Duration resumeViewingDuration,
  }) = _UserStatistics;

  factory UserStatistics.initial() => const UserStatistics(
    sentStringCount: 0,
    receivedStringCount: 0,
    resumeViewingDuration: Duration.zero,
  );
}
