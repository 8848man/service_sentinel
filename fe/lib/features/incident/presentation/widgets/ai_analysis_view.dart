import 'package:flutter/material.dart';
import '../../domain/entities/ai_analysis.dart';
import '../../../../core/extensions/context_extensions.dart';

/// AI Analysis view widget - Display AI-generated root cause analysis
/// Read-only rendering of analysis data
///
/// Features:
/// - Root cause hypothesis
/// - Confidence score visualization
/// - Debug checklist
/// - Suggested actions
/// - Related error patterns
/// - Analysis metadata (model, tokens, cost, duration)
///
/// States:
/// - Analysis available: Show full analysis
/// - Analysis not available: Show empty state with helpful message
class AiAnalysisView extends StatelessWidget {
  final AiAnalysis? analysis;

  const AiAnalysisView({
    super.key,
    this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    if (analysis == null) {
      return _buildNotAvailableState(context, theme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with AI icon
          Row(
            children: [
              Icon(
                Icons.psychology,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.incidents_ai_root_cause,
                      style: theme.textTheme.headlineSmall,
                    ),
                    Text(
                      l10n.incidents_generated_by(analysis!.modelUsed),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Confidence score
          _buildConfidenceScore(context, theme),

          const SizedBox(height: 24),

          // Root cause hypothesis
          _buildSection(
            context,
            theme,
            l10n.incidents_root_cause_hypothesis,
            Icons.lightbulb_outline,
            analysis!.rootCauseHypothesis,
          ),

          const SizedBox(height: 24),

          // Debug checklist
          _buildListSection(
            context,
            theme,
            l10n.incidents_debug_checklist,
            Icons.checklist,
            analysis!.debugChecklist,
          ),

          const SizedBox(height: 24),

          // Suggested actions
          _buildListSection(
            context,
            theme,
            l10n.incidents_suggested_actions,
            Icons.task_alt,
            analysis!.suggestedActions,
          ),

          const SizedBox(height: 24),

          // Related error patterns
          if (analysis!.relatedErrorPatterns.isNotEmpty) ...[
            _buildListSection(
              context,
              theme,
              l10n.incidents_related_error_patterns,
              Icons.pattern,
              analysis!.relatedErrorPatterns,
            ),
            const SizedBox(height: 24),
          ],

          // Metadata
          _buildMetadataSection(context, theme),
        ],
      ),
    );
  }

  Widget _buildNotAvailableState(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.incidents_no_analysis_available,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.incidents_no_analysis_message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: null, // Disabled in this view
              icon: const Icon(Icons.psychology),
              label: Text(l10n.incidents_analysis_not_available),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceScore(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;
    final confidencePercent = analysis!.confidenceScore * 100;
    final color = confidencePercent >= 80
        ? Colors.green
        : confidencePercent >= 60
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${confidencePercent.toStringAsFixed(0)}%',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.incidents_confidence_score,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getConfidenceLabel(context, confidencePercent),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getConfidenceLabel(BuildContext context, double percent) {
    final l10n = context.l10n;
    if (percent >= 80) {
      return l10n.incidents_confidence_high;
    } else if (percent >= 60) {
      return l10n.incidents_confidence_moderate;
    } else {
      return l10n.incidents_confidence_low;
    }
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme,
    String title,
    IconData icon,
    String content,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    BuildContext context,
    ThemeData theme,
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < items.length - 1 ? 8 : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.incidents_analysis_metadata,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetadataItem(
              theme, l10n.incidents_metadata_model, analysis!.modelUsed),
          _buildMetadataItem(
            theme,
            l10n.incidents_metadata_tokens,
            l10n.incidents_metadata_tokens_detail(
              analysis!.totalTokens,
              analysis!.promptTokens,
              analysis!.completionTokens,
            ),
          ),
          _buildMetadataItem(
              theme, l10n.incidents_metadata_cost, analysis!.formattedCost),
          _buildMetadataItem(
            theme,
            l10n.incidents_metadata_duration,
            l10n.incidents_metadata_duration_value(
                analysis!.analysisDurationMs),
          ),
          _buildMetadataItem(
            theme,
            l10n.incidents_metadata_analyzed_at,
            _formatDateTime(analysis!.analyzedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
