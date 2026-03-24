import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_analysis.freezed.dart';

/// AI Analysis domain entity
/// Contains AI-generated root cause analysis for an incident
@freezed
class AiAnalysis with _$AiAnalysis {
  const factory AiAnalysis({
    required int id,
    required int incidentId,
    required String modelUsed,
    int? promptTokens,
    int? completionTokens,
    double? totalCostUsd,
    required String rootCauseHypothesis,
    double? confidenceScore,
    required List<String> debugChecklist,
    required List<Map<String, dynamic>> suggestedActions,
    List<String>? relatedErrorPatterns,
    String? rawResponse,
    required DateTime analyzedAt,
    required int analysisDurationMs,
  }) = _AiAnalysis;

  const AiAnalysis._();

  /// Total tokens used
  int get totalTokens => (promptTokens ?? 0) + (completionTokens ?? 0);

  /// Formatted cost
  String get formattedCost => totalCostUsd != null ? '\$${totalCostUsd!.toStringAsFixed(4)}' : 'N/A';

  /// Formatted confidence
  String get formattedConfidence => confidenceScore != null ? '${(confidenceScore! * 100).toStringAsFixed(1)}%' : 'N/A';
}
