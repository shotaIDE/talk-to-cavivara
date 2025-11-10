# タスク完了時のチェックリスト

コードを修正した後は、必ず以下の手順を実行してください。

## コード修正前の準備

1. **関連するコーディング規約を確認**
   - [doc/coding-rule/](/doc/coding-rule/) にあるコーディング規約を確認する

2. **既存の類似コードを参照**
   - 約 5 つの類似した既存コードスニペットを確認する
   - 実装パターンやスタイルを統一する

## コード修正後の必須作業

### 1. フォーマッターの適用

```bash
dart format path/to/your/file.dart
```

- 修正したすべての Dart ファイルにフォーマッターを適用する

### 2. Linter 自動修正の適用

```bash
dart fix --apply
```

- Linter による自動修正を適用する

### 3. Linter と Compiler の警告確認

```bash
flutter analyze
# または
dart analyze
```

- すべての警告を解決する
- 警告が残っている状態でタスクを完了しない

### 4. ユニットテストの実行

```bash
flutter test
```

- すべてのテストが成功することを確認する
- 新しい機能を追加した場合は、対応するテストも追加する
- テストが失敗する場合は修正する

### 5. ドキュメントの更新（必要に応じて）

以下のドキュメントが影響を受ける場合は更新する:

- [doc/requirement/](/doc/requirement/): 要件定義ドキュメント
- [doc/design/](/doc/design/): 技術設計ドキュメント

### 6. コミット

適切なコミットメッセージを考えてコミットする

```bash
git add .
git commit -m "適切なコミットメッセージ"
```

#### コミットメッセージの指針
- 変更の性質を明確に示す（新機能、バグ修正、リファクタリング、テスト、ドキュメントなど）
- 簡潔に（1-2 文程度）
- 変更の目的や理由を含める

## 補足事項

### コード生成が必要な場合

Riverpod や Freezed などを使用している場合は、コード生成を実行する:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Swift Package Manager (SPM) 使用時の注意

- iOS では SPM がベータ機能として有効になっている
- ビルド時に問題が発生した場合は、Flutter の公式 issue を調査する
- 未知の問題の可能性も考慮する

### Firebase Emulator でのテスト

開発中は Firebase Emulator を使用してローカルでテストする:

```bash
cd infra
firebase emulators:start --import=emulator-data --export-on-exit=emulator-data
```

### 永続化について

- このアプリでは Firestore を使用して情報を永続化している
- ローカルで独自の DB ライブラリを使用した保存は行っていない

## チェックリストの要約

- [ ] コーディング規約を確認した
- [ ] 既存の類似コードを確認した（約 5 つ）
- [ ] `dart format` を実行した
- [ ] `dart fix --apply` を実行した
- [ ] `flutter analyze` で警告がないことを確認した
- [ ] `flutter test` ですべてのテストが成功することを確認した
- [ ] 必要に応じてドキュメントを更新した
- [ ] 適切なコミットメッセージでコミットした