import 'package:flutter_test/flutter_test.dart';
import 'package:service_sentinel_fe_v2/features/incident/data/models/ai_analysis_dto.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Shared test fixtures
  // ---------------------------------------------------------------------------

  const validJson = <String, dynamic>{
    'id': 5,
    'incident_id': 42,
    'model_used': 'gemini-pro',
    'prompt_tokens': 512,
    'completion_tokens': 256,
    'total_cost_usd': 0.0012,
    'root_cause_hypothesis': 'Database connection pool exhausted',
    'confidence_score': 0.87,
    'debug_checklist': ['Check DB pool size', 'Review slow query logs'],
    'suggested_actions': [
      {'action': 'Increase pool size', 'priority': 'high'},
      {'action': 'Add query timeout', 'priority': 'medium'},
    ],
    'related_error_patterns': ['ConnectionPoolTimeoutError'],
    'raw_response': '{"result": "ok"}',
    'analyzed_at': '2026-03-25T12:00:00Z',
    'analysis_duration_ms': 4200,
  };

  const minimalJson = <String, dynamic>{
    'id': 1,
    'incident_id': 10,
    'model_used': 'gemini-pro',
    'root_cause_hypothesis': 'Unknown cause',
    'debug_checklist': <dynamic>[],
    'suggested_actions': <dynamic>[],
    'analyzed_at': '2026-03-25T12:00:00Z',
    'analysis_duration_ms': 100,
  };

  // ---------------------------------------------------------------------------
  // AiAnalysisDto.fromJson
  // ---------------------------------------------------------------------------

  group('AiAnalysisDto.fromJson', () {
    test('parses all scalar fields with snake_case key mapping', () {
      final dto = AiAnalysisDto.fromJson(validJson);

      expect(dto.id, 5);
      expect(dto.incidentId, 42);
      expect(dto.modelUsed, 'gemini-pro');
      expect(dto.promptTokens, 512);
      expect(dto.completionTokens, 256);
      expect(dto.totalCostUsd, closeTo(0.0012, 1e-9));
      expect(dto.rootCauseHypothesis, 'Database connection pool exhausted');
      expect(dto.confidenceScore, closeTo(0.87, 1e-9));
      expect(dto.relatedErrorPatterns, ['ConnectionPoolTimeoutError']);
      expect(dto.rawResponse, '{"result": "ok"}');
      expect(dto.analyzedAt, '2026-03-25T12:00:00Z');
      expect(dto.analysisDurationMs, 4200);
    });

    test('nullable fields are null when absent (minimal JSON)', () {
      final dto = AiAnalysisDto.fromJson(minimalJson);

      expect(dto.promptTokens, isNull);
      expect(dto.completionTokens, isNull);
      expect(dto.totalCostUsd, isNull);
      expect(dto.confidenceScore, isNull);
      expect(dto.relatedErrorPatterns, isNull);
      expect(dto.rawResponse, isNull);
    });

    test('debug_checklist parses as List<String>', () {
      final dto = AiAnalysisDto.fromJson(validJson);

      expect(dto.debugChecklist, isA<List<String>>());
      expect(dto.debugChecklist.length, 2);
      expect(dto.debugChecklist[0], 'Check DB pool size');
      expect(dto.debugChecklist[1], 'Review slow query logs');
    });

    test('suggested_actions parses as List<Map<String, dynamic>> (type check)',
        () {
      final dto = AiAnalysisDto.fromJson(validJson);

      expect(dto.suggestedActions, isA<List<Map<String, dynamic>>>());
    });

    test(
        'suggested_actions list elements are Maps, NOT Strings '
        '(regression test for known type-mismatch bug)', () {
      final dto = AiAnalysisDto.fromJson(validJson);

      for (final item in dto.suggestedActions) {
        expect(item, isA<Map<String, dynamic>>(),
            reason: 'Each suggested action must be a Map, not a String');
        expect(item, isNot(isA<String>()));
      }
    });

    test("suggested_actions[0]['action'] == 'Increase pool size'", () {
      final dto = AiAnalysisDto.fromJson(validJson);

      expect(dto.suggestedActions[0]['action'], 'Increase pool size');
    });

    test("suggested_actions[0]['priority'] == 'high'", () {
      final dto = AiAnalysisDto.fromJson(validJson);

      expect(dto.suggestedActions[0]['priority'], 'high');
    });

    test('empty suggested_actions parses to empty list', () {
      final dto = AiAnalysisDto.fromJson(minimalJson);

      expect(dto.suggestedActions, isA<List<Map<String, dynamic>>>());
      expect(dto.suggestedActions, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // AiAnalysisDto.toDomain()
  // ---------------------------------------------------------------------------

  group('AiAnalysisDto.toDomain()', () {
    test('id, incidentId, modelUsed map correctly', () {
      final entity = AiAnalysisDto.fromJson(validJson).toDomain();

      expect(entity.id, 5);
      expect(entity.incidentId, 42);
      expect(entity.modelUsed, 'gemini-pro');
    });

    test('analyzedAt string parses to DateTime', () {
      final entity = AiAnalysisDto.fromJson(validJson).toDomain();

      expect(entity.analyzedAt, isA<DateTime>());
      expect(entity.analyzedAt, DateTime.parse('2026-03-25T12:00:00Z'));
    });

    test('suggestedActions preserved as List<Map<String, dynamic>>', () {
      final entity = AiAnalysisDto.fromJson(validJson).toDomain();

      expect(entity.suggestedActions, isA<List<Map<String, dynamic>>>());
      expect(entity.suggestedActions.length, 2);
    });

    test('suggestedActions map contents preserved', () {
      final entity = AiAnalysisDto.fromJson(validJson).toDomain();

      expect(entity.suggestedActions[0]['action'], 'Increase pool size');
      expect(entity.suggestedActions[0]['priority'], 'high');
      expect(entity.suggestedActions[1]['action'], 'Add query timeout');
      expect(entity.suggestedActions[1]['priority'], 'medium');
    });
  });
}
