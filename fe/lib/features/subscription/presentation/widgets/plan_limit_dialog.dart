import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

class PlanLimitDialog extends StatelessWidget {
  final String plan;
  final int limit;
  final String resource; // "projects" or "services"

  const PlanLimitDialog({
    super.key,
    required this.plan,
    required this.limit,
    required this.resource,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Plan limit reached'),
      content: Text(
        "You've reached the $plan plan limit of $limit $resource. "
        "Upgrade your plan to add more.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Maybe later'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.upgrade);
          },
          child: const Text('Upgrade Plan'),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String plan,
    required int limit,
    required String resource,
  }) {
    return showDialog(
      context: context,
      builder: (_) => PlanLimitDialog(plan: plan, limit: limit, resource: resource),
    );
  }
}
