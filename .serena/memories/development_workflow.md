# 開発ワークフロー

## 日常的な開発フロー

### 1. 開発環境の起動

#### Firebase Emulator の起動

```bash
cd infra
firebase emulators:start --import=emulator-data --export-on-exit=emulator-data
```

- データは `emulator-data/` に保持される
- リセットしたい場合はフォルダーごと削除

#### クライアントアプリの起動

VSCode の「実行とデバッグ」パネルから適切な構成を選択:
- **Emulator-Debug**: Emulator 環境で実行
- **Debug-dev**: Dev 環境で実行
- **Debug-prod**: Prod 環境で実行

### 2. コード修正

1. 関連するコーディング規約を確認（`doc/coding-rule/`）
2. 既存の類似コード（約 5 つ）を参照してパターンを統一
3. コード修正を実施
4. コード生成が必要な場合は実行:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### 3. 品質チェック

```bash
# フォーマット
dart format path/to/your/file.dart

# Linter 自動修正
dart fix --apply

# 静的解析
flutter analyze

# テスト実行
flutter test
```

### 4. コミット

```bash
git add .
git commit -m "適切なコミットメッセージ"
```

## 新機能開発のワークフロー

### ステップ 1: 要件確認
- `doc/requirement/` で要件を確認
- `doc/design/` で技術設計を確認

### ステップ 2: モデル定義
1. `client/lib/data/model/` にドメインモデルを定義
2. Freezed を使用して不変クラスを作成
3. 必要に応じて例外クラスも定義

```dart
@freezed
class NewModel with _$NewModel {
  const factory NewModel({
    required String id,
    required String name,
  }) = _NewModel;
}
```

### ステップ 3: リポジトリ/サービス実装
1. データの永続化が必要な場合は `client/lib/data/repository/` にリポジトリを作成
2. 外部サービス（Firebase など）との接続が必要な場合は `client/lib/data/service/` にサービスを作成
3. Riverpod の `@riverpod` アノテーションでプロバイダーを定義

### ステップ 4: UI 実装
1. `client/lib/ui/feature/` に適切なカテゴリフォルダを作成または選択
2. 画面ウィジェット（`*_screen.dart`）を実装
3. Presenter（`*_presenter.dart`）で状態管理とロジックを実装
4. 共通コンポーネントが必要な場合は `client/lib/ui/component/` に作成

### ステップ 5: テスト作成
1. `client/test/` に対応するテストファイルを作成
2. mocktail を使用してモックを作成
3. ユニットテスト/ウィジェットテストを実装

### ステップ 6: ドキュメント更新
- 必要に応じて `doc/requirement/` や `doc/design/` を更新

## コード生成のワークフロー

### Riverpod プロバイダーの生成

```dart
// 定義
@riverpod
Future<String> myData(Ref ref) async {
  return 'data';
}

// 生成
dart run build_runner build
```

### Freezed モデルの生成

```dart
// 定義
@freezed
class MyModel with _$MyModel {
  const factory MyModel({required String id}) = _MyModel;
}

// 生成
dart run build_runner build
```

### ウォッチモード（推奨）

```bash
dart run build_runner watch
```

- ファイル変更時に自動的にコード生成
- 開発中は常に起動しておくと便利

## デプロイワークフロー

### iOS（App Store）

#### Dev 環境

```bash
cd client/ios
bundle exec fastlane dev
```

#### Prod 環境

```bash
cd client/ios
bundle exec fastlane prod
```

### Android（Google Play）

#### Dev 環境

```bash
cd client/android
bundle exec fastlane dev
```

#### Prod 環境

```bash
cd client/android
bundle exec fastlane prod
```

### Firebase Functions

#### Dev 環境

```bash
cd infra
firebase use default
firebase deploy --only functions
```

#### Prod 環境

```bash
firebase use prod
firebase deploy --only functions
```

### インフラ（Terraform）

#### Dev 環境

```bash
cd infra/environment/dev
terraform plan
terraform apply
```

#### Prod 環境

```bash
cd infra/environment/prod
terraform plan
terraform apply
```

## トラブルシューティング

### ビルドエラー

1. 依存関係を再インストール:
   ```bash
   flutter clean
   flutter pub get
   ```

2. コード生成をクリーンビルド:
   ```bash
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

3. iOS の場合、Pod を再インストール:
   ```bash
   cd ios
   pod install
   ```

### SPM（Swift Package Manager）関連の問題

- SPM はベータ機能のため、問題が発生する可能性がある
- Flutter の公式 issue を確認
- Xcode でプロジェクトをクリーンビルド

### Firebase Emulator 接続問題

1. `client/emulator-config.json` が存在することを確認
2. `EMULATOR_HOST` が正しい IP アドレスに設定されていることを確認（デフォルト: `127.0.0.1`）
3. Emulator が起動していることを確認

## CI/CD（GitHub Actions）

### ワークフロー
- `.github/workflows/` に CI/CD ワークフローが定義されている
- プルリクエスト時に自動テスト実行
- マージ時に自動デプロイ（設定による）

### Secrets の設定
- GitHub リポジトリの Settings > Secrets で以下を設定:
  - App Store Connect API キー関連
  - Google Play サービスアカウントキー関連
  - その他の機密情報

## 依存関係の更新（Renovate）

- Renovate が自動的にプルリクエストを作成
- `renovate.json` で設定を管理
- `rangeStrategy` は `pin` に設定されている

## アプリアイコンの更新

1. `client/assets/launcher-icon/` にアイコン画像を配置
2. アイコンを生成:
   ```bash
   cd client
   dart run flutter_launcher_icons
   ```
3. iOS の場合、`client/ios/Runner.xcodeproj/project.pbxproj` の差分を元に戻す
   - xcconfig ファイルでアイコン名が既に指定されているため

## バージョン番号の更新

`client/pubspec.yaml` の `version` フィールドを更新:

```yaml
version: 0.0.1+4
# 形式: major.minor.patch+buildNumber
```