# Reward 機能仕様書

## 概要

受信チャット文字数に応じて称号を獲得できる機能。現在 2 つの称号（1000 文字でアルバイト、10000 文字でリーダー）が存在。

## 主要コンポーネント

### CavivaraReward (cavivara_reward.dart)

称号の定義を管理する列挙型。`isAchieved()` で達成判定、`highestAchieved()` で最高位称号を取得。

### HasEarnedXxxRewardRepository

各称号の獲得状態を SharedPreferences で永続化。`markAsEarned()` で獲得をマーク。

### RewardNotificationManager (home_presenter.dart:238)

称号獲得通知のロジックを管理。受信文字数の変更を監視し、新規獲得時に通知。重複通知防止のため、閾値ベース（`maxReceivedChatRewardThresholdNotified`）とフラグベース（`hasEarnedXxxReward`）の 2 段階で管理。

### UserStatisticsScreen

業績画面。統計情報と称号一覧を表示。新規獲得時は `highlightedReward` で該当称号をハイライト表示。

## データフロー

### チャット受信時

1. AI レスポンス受信 → ReceivedChatStringCountRepository が加算
2. HomeScreen の listenManual が検知 → RewardNotificationManager 呼び出し
3. 称号解禁判定 → 新規獲得なら状態保存 & 通知表示

### 業績画面表示時

ReceivedChatStringCountRepository から総受信文字数を取得し、各称号の達成状態を判定して表示。

## 永続化

SharedPreferences に保存:

- `hasEarnedPartTimerReward`, `hasEarnedLeaderReward`: 各称号の獲得状態
- `maxReceivedChatRewardThresholdNotified`: 通知済み最高閾値（重複防止）
- `totalReceivedChatStringCount`: 総受信文字数

## 新規称号追加方法

1. CavivaraReward に enum 値追加
2. PreferenceKey に新キー追加
3. HasEarnedXxxRewardRepository 作成
4. RewardNotificationManager の `_checkIfRewardEarned()` / `_markRewardAsEarned()` を更新
5. UserStatisticsScreen は自動対応（`CavivaraReward.values` 使用）

## 設計ポイント

- **重複通知防止**: 閾値 + フラグの 2 段階管理でアプリ再起動後やオフライン復帰時の重複を防止
- **非同期初期化**: 初期化中の更新は `_pendingReceivedCount` にバッファリング
- **文字数カウント**: `characters` パッケージで Unicode 文字を正確にカウント

## 関連ファイル

- `client/lib/ui/feature/stats/cavivara_reward.dart`
- `client/lib/data/repository/has_earned_*_reward_repository.dart`
- `client/lib/ui/feature/home/home_presenter.dart`
- `client/lib/ui/feature/stats/user_statistics_screen.dart`
