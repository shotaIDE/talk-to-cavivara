enum CavivaraTitle {
  partTimer(
    threshold: 1000,
    displayName: 'プレクトラム結社アルバイト',
    conditionDescription: 'カヴィヴァラさんたちから受信したチャットの文字数が1000文字を超えた',
  ),
  leader(
    threshold: 10000,
    displayName: 'プレクトラム結社バイトリーダー',
    conditionDescription: 'カヴィヴァラさんたちから受信したチャットの文字数が10000文字を超えた',
  );

  const CavivaraTitle({
    required this.threshold,
    required this.displayName,
    required this.conditionDescription,
  });

  final int threshold;
  final String displayName;
  final String conditionDescription;

  bool isAchieved(int receivedStringCount) =>
      receivedStringCount >= threshold;

  static CavivaraTitle? highestAchieved(int receivedStringCount) {
    for (final title in values.reversed) {
      if (title.isAchieved(receivedStringCount)) {
        return title;
      }
    }
    return null;
  }
}
