import 'package:flutter_test/flutter_test.dart';
import 'package:service_sentinel_fe_v2/features/incident/domain/entities/ai_analysis.dart';

// ---------------------------------------------------------------------------
// Shared fixture factory
// ---------------------------------------------------------------------------

AiAnalysis _makeAnalysis({
  int? promptTokens = 512,
  int? completionTokens = 256,
  double? totalCostUsd = 0.0012,
  double? confidenceScore = 0.87,
  List<Map<String, dynamic>>? suggestedActions,
  List<String>? debugChecklist,
}) {
  return AiAnalysis(
    id: 5,
    incidentId: 42,
    modelUsed: 'gemini-pro',
    promptTokens: promptTokens,
    completionTokens: completionTokens,
    totalCostUsd: totalCostUsd,
    rootCauseHypothesis: 'Database connection pool exhausted',
    confidenceScore: confidenceScore,
    debugChecklist: debugChecklist ?? ['Check DB pool size', 'Review slow query logs'],
    suggestedActions: suggestedActions ??
        [
          {'action': 'Increase pool size', 'priority': 'high'},
          {'action': 'Add query timeout', 'priority': 'medium'},
        ],
    relatedErrorPatterns: ['ConnectionPoolTimeoutError'],
    rawResponse: '{"result": "ok"}',
    analyzedAt: DateTime(2026, 3, 25, 12, 0, 0),
    analysisDurationMs: 4200,
  );
}

void main() {
  // ---------------------------------------------------------------------------
  // Field storage
  // ---------------------------------------------------------------------------

  group('AiAnalysis field storage', () {
    test('stores all required fields', () {
      final analysis = _makeAnalysis();

      expect(analysis.id, 5);
      expect(analysis.incidentId, 42);
      expect(analysis.modelUsed, 'gemini-pro');
      expect(analysis.promptTokens, 512);
      expect(analysis.completionTokens, 256);
      expect(analysis.totalCostUsd, closeTo(0.0012, 1e-9));
      expect(analysis.rootCauseHypothesis,
          'Database connection pool exhausted');
      expect(analysis.confidenceScore, closeTo(0.87, 1e-9));
      expect(analysis.analysisDurationMs, 4200);
      expect(analysis.analyzedAt, DateTime(2026, 3, 25, 12, 0, 0));
    });

    test('suggestedActions is typed List<Map<String, dynamic>> '
        '(regression test for type-mismatch bug)', () {
      final analysis = _makeAnalysis();
      expect(analysis.suggestedActions, isA<List<Map<String, dynamic>>>());
    });

    test('suggestedActions elements are Maps, NOT Strings', () {
      final analysis = _makeAnalysis();
      for (final item in analysis.suggestedActions) {
        expect(item, isA<Map<String, dynamic>>());
        expect(item, isNot(isA<String>()));
      }
    });

    test("suggestedActions map values accessible by key: "
        "['action'] == 'Increase pool size'", () {
      final analysis = _makeAnalysis();
      expect(analysis.suggestedActions[0]['action'], 'Increase pool size');
    });

    test('debugChecklist is List<String>', () {
      final analysis = _makeAnalysis();
      expect(analysis.debugChecklist, isA<List<String>>());
      expect(analysis.debugChecklist[0], 'Check DB pool size');
    });
  });

  // ---------------------------------------------------------------------------
  // totalTokens
  // ---------------------------------------------------------------------------

  group('AiAnalysis.totalTokens', () {
    test('sums promptTokens + completionTokens (512 + 256 = 768)', () {
      final analysis = _makeAnalysis(promptTokens: 512, completionTokens: 256);
      expect(analysis.totalTokens, 768);
    });

    test('treats null promptTokens as 0', () {
      final analysis =
          _makeAnalysis(promptTokens: null, completionTokens: 300);
      expect(analysis.totalTokens, 300);
    });

    test('treats null completionTokens as 0', () {
      final analysis =
          _makeAnalysis(promptTokens: 400, completionTokens: null);
      expect(analysis.totalTokens, 400);
    });

    test('returns 0 when both promptTokens and completionTokens are null', () {
      final analysis =
          _makeAnalysis(promptTokens: null, completionTokens: null);
      expect(analysis.totalTokens, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // formattedCost
  // ---------------------------------------------------------------------------

  group('AiAnalysis.formattedCost', () {
    test(r'returns $0.0012 when totalCostUsd is set', () {
      final analysis = _makeAnalysis(totalCostUsd: 0.0012);
      expect(analysis.formattedCost, r'$0.0012');
    });

    test("returns 'N/A' when totalCostUsd is null", () {
      final analysis = _makeAnalysis(totalCostUsd: null);
      expect(analysis.formattedCost, 'N/A');
    });
  });

  // ---------------------------------------------------------------------------
  // formattedConfidence
  // ---------------------------------------------------------------------------

  group('AiAnalysis.formattedConfidence', () {
    test("returns '87.0%' when confidenceScore is 0.87", () {
      final analysis = _makeAnalysis(confidenceScore: 0.87);
      expect(analysis.formattedConfidence, '87.0%');
    });

    test("returns 'N/A' when confidenceScore is null", () {
      final analysis = _makeAnalysis(confidenceScore: null);
      expect(analysis.formattedConfidence, 'N/A');
    });

    test("returns '100.0%' when confidenceScore is 1.0", () {
      final analysis = _makeAnalysis(confidenceScore: 1.0);
      expect(analysis.formattedConfidence, '100.0%');
    });

    test("returns '0.0%' when confidenceScore is 0.0", () {
      final analysis = _makeAnalysis(confidenceScore: 0.0);
      expect(analysis.formattedConfidence, '0.0%');
    });
  });

  // ---------------------------------------------------------------------------
  // Freezed equality and copyWith
  // ---------------------------------------------------------------------------

  group('Freezed equality and copyWith', () {
    test('two identical AiAnalysis instances are equal', () {
      final a = _makeAnalysis();
      final b = _makeAnalysis();
      expect(a, equals(b));
    });

    test('copyWith preserves unchanged fields', () {
      final original = _makeAnalysis();
      final updated = original.copyWith(modelUsed: 'gemini-1.5-pro');

      expect(updated.modelUsed, 'gemini-1.5-pro');
      expect(updated.id, original.id);
      expect(updated.incidentId, original.incidentId);
      expect(updated.rootCauseHypothesis, original.rootCauseHypothesis);
      expect(updated.analysisDurationMs, original.analysisDurationMs);
      expect(updated.suggestedActions, original.suggestedActions);
    });
  });
}
