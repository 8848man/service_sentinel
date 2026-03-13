import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ai_analysis.dart';

part 'ai_analysis_dto.freezed.dart';
part 'ai_analysis_dto.g.dart';

/// AI Analysis Data Transfer Object
@freezed
class AiAnalysisDto with _$AiAnalysisDto {
  const factory AiAnalysisDto({
    required String id,
    @JsonKey(name: 'incident_id') required String incidentId,
    @JsonKey(name: 'model_used') required String modelUsed,
    @JsonKey(name: 'prompt_tokens') required int promptTokens,
    @JsonKey(name: 'completion_tokens') required int completionTokens,
    @JsonKey(name: 'total_cost_usd') required double totalCostUsd,
    @JsonKey(name: 'root_cause_hypothesis') required String rootCauseHypothesis,
    @JsonKey(name: 'confidence_score') required double confidenceScore,
    @JsonKey(name: 'debug_checklist') required List<String> debugChecklist,
    @JsonKey(name: 'suggested_actions') required List<String> suggestedActions,
    @JsonKey(name: 'related_error_patterns') required List<String> relatedErrorPatterns,
    @JsonKey(name: 'raw_response') String? rawResponse,
    @JsonKey(name: 'analyzed_at') required String analyzedAt,
    @JsonKey(name: 'analysis_duration_ms') required int analysisDurationMs,
  }) = _AiAnalysisDto;

  const AiAnalysisDto._();

  factory AiAnalysisDto.fromJson(Map<String, dynamic> json) =>
      _$AiAnalysisDtoFromJson(json);

  /// Convert DTO to domain entity
  AiAnalysis toDomain() {
    return AiAnalysis(
      id: id,
      incidentId: incidentId,
      modelUsed: modelUsed,
      promptTokens: promptTokens,
      completionTokens: completionTokens,
      totalCostUsd: totalCostUsd,
      rootCauseHypothesis: rootCauseHypothesis,
      confidenceScore: confidenceScore,
      debugChecklist: debugChecklist,
      suggestedActions: suggestedActions,
      relatedErrorPatterns: relatedErrorPatterns,
      rawResponse: rawResponse,
      analyzedAt: DateTime.parse(analyzedAt),
      analysisDurationMs: analysisDurationMs,
    );
  }
}
