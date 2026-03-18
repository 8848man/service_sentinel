import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/features/subscription/presentation/view_models/subscription_view_model.dart';
import '../../di/repository_providers.dart';
import '../../../../core/constants/plan_limits.dart';

class UpgradeScreen extends ConsumerWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subState = ref.watch(subscriptionViewModelProvider);
    final currentPlan = subState.currentPlan;

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current plan badge
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.star, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Plan',
                          style: theme.textTheme.labelMedium,
                        ),
                        Text(
                          currentPlan.toUpperCase(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Available Plans', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),

            // Plan comparison table
            _PlanComparisonTable(currentPlan: currentPlan),
            const SizedBox(height: 24),

            // Pro plan card
            _PlanCard(
              plan: 'pro',
              title: 'Pro',
              color: Colors.blue,
              limits: getLimitsForPlan('pro'),
              isCurrentPlan: currentPlan == 'pro',
            ),
            const SizedBox(height: 12),

            // Max plan card
            _PlanCard(
              plan: 'max',
              title: 'Max',
              color: Colors.purple,
              limits: getLimitsForPlan('max'),
              isCurrentPlan: currentPlan == 'max',
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanComparisonTable extends StatelessWidget {
  final String currentPlan;

  const _PlanComparisonTable({required this.currentPlan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
              ),
              children: [
                _tableHeader('Feature'),
                _tableHeader('Free'),
                _tableHeader('Pro'),
                _tableHeader('Max'),
              ],
            ),
            TableRow(children: [
              _tableCell('Projects', isLabel: true),
              _tableCell('${planLimits['free']!['maxProjects']}'),
              _tableCell('${planLimits['pro']!['maxProjects']}'),
              _tableCell('${planLimits['max']!['maxProjects']}'),
            ]),
            TableRow(children: [
              _tableCell('Services', isLabel: true),
              _tableCell('${planLimits['free']!['maxServices']}'),
              _tableCell('${planLimits['pro']!['maxServices']}'),
              _tableCell('${planLimits['max']!['maxServices']}'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );

  Widget _tableCell(String text, {bool isLabel = false}) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          textAlign: isLabel ? TextAlign.start : TextAlign.center,
        ),
      );
}

class _PlanCard extends StatelessWidget {
  final String plan;
  final String title;
  final Color color;
  final Map<String, int> limits;
  final bool isCurrentPlan;

  const _PlanCard({
    required this.plan,
    required this.title,
    required this.color,
    required this.limits,
    required this.isCurrentPlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentPlan
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(color: color),
                ),
                if (isCurrentPlan) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text('Current'),
                    backgroundColor: color.withOpacity(0.1),
                    labelStyle: TextStyle(color: color),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text('Up to ${limits['maxProjects']} projects'),
            Text('Up to ${limits['maxServices']} services per project'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: null, // Coming soon
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: color.withOpacity(0.4),
              ),
              child: const Text('Coming soon'),
            ),
          ],
        ),
      ),
    );
  }
}
