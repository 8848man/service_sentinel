import 'package:flutter/material.dart';

/// A stateful checklist that lets the user track resolution steps.
///
/// Accepts a list of step strings (typically from [AiAnalysis.debugChecklist]).
/// Each step can be checked off independently. A [LinearProgressIndicator]
/// shows overall completion progress.
class ResolutionChecklist extends StatefulWidget {
  /// The checklist steps to display.
  final List<String> steps;

  const ResolutionChecklist({super.key, required this.steps});

  @override
  State<ResolutionChecklist> createState() => _ResolutionChecklistState();
}

class _ResolutionChecklistState extends State<ResolutionChecklist> {
  late List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List<bool>.filled(widget.steps.length, false);
  }

  @override
  void didUpdateWidget(ResolutionChecklist old) {
    super.didUpdateWidget(old);
    if (old.steps.length != widget.steps.length) {
      _checked = List<bool>.filled(widget.steps.length, false);
    }
  }

  double get _progress {
    if (widget.steps.isEmpty) return 0.0;
    final done = _checked.where((c) => c).length;
    return done / widget.steps.length;
  }

  int get _doneCount => _checked.where((c) => c).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.checklist_rtl, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                // TODO: localize this string once an l10n key is added
                'Resolution Checklist',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '$_doneCount / ${widget.steps.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              backgroundColor:
                  theme.colorScheme.onSurface.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                _progress >= 1.0
                    ? Colors.green
                    : theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Checklist items
          ...widget.steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _checked[i],
              onChanged: (val) =>
                  setState(() => _checked[i] = val ?? false),
              title: Text(
                step,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration:
                      _checked[i] ? TextDecoration.lineThrough : null,
                  color: _checked[i]
                      ? theme.colorScheme.onSurface.withOpacity(0.4)
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
