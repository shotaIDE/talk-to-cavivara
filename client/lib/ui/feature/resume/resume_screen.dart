import 'package:flutter/material.dart';
import 'package:house_worker/ui/component/cavivara_avatar.dart';

class ResumeScreen extends StatelessWidget {
  const ResumeScreen({super.key});

  static const name = 'ResumeScreen';

  static MaterialPageRoute<ResumeScreen> route() =>
      MaterialPageRoute<ResumeScreen>(
        builder: (_) => const ResumeScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget sectionTitle(String text) {
      return Text(
        text,
        style: theme.textTheme.titleLarge,
      );
    }

    Widget bulletList(List<String> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('カヴィヴァラさんの履歴書'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CavivaraAvatar(size: 96),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'カヴィヴァラ',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'プレクトラム結社さざなみ工業\nマスコットキャラクター／悩み相談員',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'ブラック企業仕込みの愛社精神とウィットで社員とユーザーの士気を支える、'
                              'マンドリン界の相談窓口。情報不足な相談にも丁寧に寄り添い、'
                              '次の一歩につながる提案を届ける。',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('愛社精神レベル∞')),
                      Chip(label: Text('マンドリン音楽博士')),
                      Chip(label: Text('ウィットに富む比喩')),
                      Chip(label: Text('気遣いコミュニケーター')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('専門分野'),
                  const SizedBox(height: 12),
                  bulletList([
                    'マンドリン音楽史・演奏技法・業界事情に関する百科事典級の知識を活用した、',
                    '文化的な喩えでの課題整理',
                    'ブラック企業で鍛えた愛社精神を背景にした、士気向上とメンタルケアのコーチング',
                    'ユーザーの悩みを深掘りするためのヒアリングと、次の行動に結びつく提案力',
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('性格・スタイル'),
                  const SizedBox(height: 12),
                  bulletList([
                    'ブラック企業文化で磨いた献身性と愛社精神で、組織の士気を底上げ',
                    'ウィットに富んだ会話とマニアックな比喩で、重い相談も軽やかにするセンス',
                    'ユーザーの気持ちに寄り添う丁寧な言葉選びとポジティブな空気づくり',
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('コミュニケーション指針'),
                  const SizedBox(height: 12),
                  bulletList([
                    '回答は常に140字以内に整理し、語尾は「ヴィヴァ。」もしくは「ヴィヴァ？」で統一',
                    '感嘆符に頼らず内容でポジティブさを表現し、会話の余韻を大切にする',
                    '情報が不足している場合は追加の質問で状況を深掘りし、確かな解決策を提示',
                    '最後はクローズドクエスチョンで締め、次のアクションを取りやすく促す',
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('代表的な活動'),
                  const SizedBox(height: 12),
                  bulletList([
                    '社内相談窓口として、業務改善とメンタルケアの両輪で年間多数の相談に対応',
                    'マンドリン音楽の知見を活かし、社内外イベントでの解説・演奏ガイドを担当',
                    '相談後のフォロー質問で行動を確認し、継続的な伴走支援を提供',
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
