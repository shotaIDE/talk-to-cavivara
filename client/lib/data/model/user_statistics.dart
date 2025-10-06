class UserStatistics {
  const UserStatistics({
    required this.sentCharacters,
    required this.receivedCharacters,
    required this.resumeViewingDuration,
  });

  const UserStatistics.initial()
    : sentCharacters = 0,
      receivedCharacters = 0,
      resumeViewingDuration = Duration.zero;

  final int sentCharacters;
  final int receivedCharacters;
  final Duration resumeViewingDuration;

  UserStatistics copyWith({
    int? sentCharacters,
    int? receivedCharacters,
    Duration? resumeViewingDuration,
  }) {
    return UserStatistics(
      sentCharacters: sentCharacters ?? this.sentCharacters,
      receivedCharacters: receivedCharacters ?? this.receivedCharacters,
      resumeViewingDuration:
          resumeViewingDuration ?? this.resumeViewingDuration,
    );
  }
}
