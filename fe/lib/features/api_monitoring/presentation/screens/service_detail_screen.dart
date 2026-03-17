import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../providers/service_provider.dart';
import '../widgets/service_detail_body.dart';

/// Service Detail Screen
///
/// Displays detailed information about a specific monitored service/API.
/// This screen is layout-only; all provider consumption happens in child widgets.
///
/// Route: /service/:id
/// Parameters: serviceId (String)
class ServiceDetailScreen extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.services_service_details),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: l10n.services_manual_check_coming_soon,
            onPressed: () {
              // TODO: Trigger manual health check
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.services_manual_check_coming_soon)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.common_edit,
            onPressed: () {
              context.push('/service/$serviceId/edit');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context, ref);
              } else if (value == 'deactivate') {
                // TODO: Deactivate service
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.services_deactivate_coming_soon)),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'deactivate',
                child: Row(
                  children: [
                    const Icon(Icons.pause),
                    const SizedBox(width: 8),
                    Text(l10n.services_deactivate),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.services_delete_service,
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ServiceDetailBody(serviceId: serviceId),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.services_delete_service),
        content: Text(l10n.services_delete_confirmation_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Delete service
    final useCase = ref.read(deleteServiceProvider);
    final result = await useCase.execute(int.parse(serviceId));

    if (!context.mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    if (result.isSuccess) {
      // Invalidate services list
      ref.invalidate(servicesProvider);

      // Navigate back
      Navigator.of(context).pop();

      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.services_service_deleted)),
      );
    } else {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n
              .services_failed_to_delete(result.errorOrNull?.message ?? '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
