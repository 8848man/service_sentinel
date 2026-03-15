import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Guest entry section - Allows users to continue as guest
///
/// Guest users are automatically assigned a UUID-based identification key
/// for backend tracking. This is NOT authentication - just identification.
///
/// Flow:
/// 1. User clicks "Enter as Guest"
/// 2. GuestIdentificationService auto-generates/retrieves UUID key
/// 3. All API requests automatically include X-API-KEY header
/// 4. User navigates to app with guest access
///
/// Note: No manual API key entry required - completely transparent to user
class GuestEntrySection extends ConsumerWidget {
  const GuestEntrySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.person_outline,
              size: 48,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.auth_guest_mode,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.auth_guest_mode_desc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Guest identification is automatic via interceptor
                // Simply navigate to project selection
                context.go(AppRoutes.projectSelection);
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text(l10n.auth_enter_as_guest),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
