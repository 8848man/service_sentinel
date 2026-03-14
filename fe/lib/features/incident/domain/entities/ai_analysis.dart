import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_analysis.freezed.dart';

/// AI Analysis domain entity
/// Contains AI-generated root cause analysis for an incident
@freezed
class AiAnalysis with _$AiAnalysis {
  const factory AiAnalysis({
    required String id,
    required String incidentId,
    required String modelUsed,
    required int promptTokens,
    required int completionTokens,
    required double totalCostUsd,
    required String rootCauseHypothesis,
    required double confidenceScore,
    required List<String> debugChecklist,
    required List<String> suggestedActions,
    required List<String> relatedErrorPatterns,
    String? rawResponse,
    required DateTime analyzedAt,
    required int analysisDurationMs,
  }) = _AiAnalysis;

  const AiAnalysis._();

  /// Total tokens used
  int get totalTokens => promptTokens + completionTokens;

  /// Formatted cost
  String get formattedCost => '\$${totalCostUsd.toStringAsFixed(4)}';

  /// Formatted confidence
  String get formattedConfidence => '${(confidenceScore * 100).toStringAsFixed(1)}%';
}
