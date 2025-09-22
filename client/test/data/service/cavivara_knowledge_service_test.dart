import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/data/service/cavivara_knowledge_service.dart';

void main() {
  group('CavivaraKnowledgeBase', () {
    late CavivaraKnowledgeBase knowledgeBase;

    setUp(() {
      knowledgeBase = CavivaraKnowledgeBase();
    });

    test('exposes function declaration for plectrum society knowledge', () {
      final tools = knowledgeBase.tools;
      expect(tools, isNotEmpty);

      final functionDeclarations = tools.first.functionDeclarations;
      expect(functionDeclarations, isNotNull);
      expect(functionDeclarations!.length, greaterThanOrEqualTo(1));
      expect(functionDeclarations.first.name, 'getPlectrumSocietyKnowledge');
    });

    test('returns salary policy knowledge when topic is specified', () async {
      final result = await knowledgeBase.execute(
        functionName: 'getPlectrumSocietyKnowledge',
        arguments: const {'topic': 'salary_policy'},
      );

      expect(result['found'], isTrue);
      expect(result['topic'], 'salary_policy');
      final facts = result['facts'] as List<dynamic>;
      expect(
        facts,
        contains('結社の給料は0円です。'),
      );
    });

    test('infers regular concert knowledge from query text', () async {
      final result = await knowledgeBase.execute(
        functionName: 'getPlectrumSocietyKnowledge',
        arguments: const {'query': '定期演奏会はいつ開催されるの？'},
      );

      expect(result['found'], isTrue);
      expect(result['topic'], 'regular_concert_11');
      final facts = result['facts'] as List<dynamic>;
      expect(
        facts,
        contains('開催日: 2026年9月12日(土)。'),
      );
    });

    test('returns fallback payload for unknown query', () async {
      final result = await knowledgeBase.execute(
        functionName: 'getPlectrumSocietyKnowledge',
        arguments: const {'query': '未知の話題'},
      );

      expect(result['found'], isFalse);
      expect(result['availableTopics'], contains('salary_policy'));
    });
  });
}
