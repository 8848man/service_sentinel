import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../di/repository_providers.dart';

/// Subscription plan section for Settings screen
/// Shows current plan, status, expiry and suspend/reactivate controls.
class SubscriptionSettingsSection extends ConsumerWidget {
  const SubscriptionSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subState = ref.watch(subscriptionViewModelProvider);
    final sub = subState.subscription;

    if (subState.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subscription', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            // Current plan row
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('Current Plan'),
              subtitle: Text(subState.currentPlan.toUpperCase()),
              trailing: sub != null
                  ? Chip(
                      label: Text(sub.status),
                      backgroundColor: sub.isActive
                          ? Colors.green.withOpacity(0.15)
                          : Colors.orange.withOpacity(0.15),
                    )
                  : null,
            ),

            // Expiry (shown only if not null)
            if (sub?.expiresAt != null) ...[
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Expires'),
                subtitle: Text(sub!.expiresAt!.toLocal().toString().split(' ').first),
              ),
            ],

            const Divider(),

            // View Plans button
            ListTile(
              leading: const Icon(Icons.upgrade),
              title: const Text('View Plans'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push(AppRoutes.upgrade),
            ),

            // Suspension warning banner (free plan + suspended only)
            if (subState.isSuspended && subState.currentPlan == 'free') ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your monitoring is suspended due to inactivity.',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: subState.isReactivating
                          ? null
                          : () => _reactivate(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: subState.isReactivating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Reactivate'),
                    ),
                  ],
                ),
              ),
            ],

            if (subState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                subState.error!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _reactivate(BuildContext context, WidgetRef ref) async {
    final vm = ref.read(subscriptionViewModelProvider.notifier);
    final success = await vm.reactivateMonitoring();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Monitoring reactivated successfully.'
                : 'Failed to reactivate. Please try again.',
          ),
        ),
      );
    }
  }
}
