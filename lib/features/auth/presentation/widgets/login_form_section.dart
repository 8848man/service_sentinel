import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/entities/auth_state.dart';

import '../../../../core/auth/application/providers/auth_provider.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/migration/migration_provider.dart';
import 'migration_dialog.dart';

class LoginFormSection extends ConsumerStatefulWidget {
  const LoginFormSection({super.key});

  @override
  ConsumerState<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends ConsumerState<LoginFormSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authStateNotifierProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _handleGoogleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authStateNotifierProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthState>>(
      authStateNotifierProvider,
      (previous, next) async {
        // 성공적으로 인증된 경우만 반응
        if (next.hasValue && next.value!.isAuthenticated == true) {
          // 1. 마이그레이션 체크
          await ref
              .read(migrationStateNotifierProvider.notifier)
              .checkMigrationNeeded();

          final migrationState = ref.read(migrationStateNotifierProvider);

          if (migrationState.isRequired) {
            final shouldMigrate = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) => const MigrationDialog(),
            );

            if (shouldMigrate == true) {
              await ref
                  .read(migrationStateNotifierProvider.notifier)
                  .executeMigration();
            } else {
              ref.read(migrationStateNotifierProvider.notifier).skipMigration();
            }
          }

          // // 2. 최종 라우팅
          // if (context.mounted) {
          //   context.go(AppRoutes.projectSelection);
          // }
        }
      },
    );
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final authState = ref.watch(authStateNotifierProvider);

    final isLoading = authState.isLoading;
    final error = authState.error;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.login,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.auth_sign_in_google,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.auth_sign_in_desc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // // Email
              // TextFormField(
              //   controller: _emailController,
              //   enabled: !isLoading,
              //   keyboardType: TextInputType.emailAddress,
              //   decoration: InputDecoration(
              //     labelText: l10n.auth_email,
              //     prefixIcon: const Icon(Icons.email_outlined),
              //     border: const OutlineInputBorder(),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return l10n.validation_required;
              //     }
              //     if (!value.contains('@')) {
              //       return l10n.validation_email_invalid;
              //     }
              //     return null;
              //   },
              // ),

              // const SizedBox(height: 16),

              // // Password
              // TextFormField(
              //   controller: _passwordController,
              //   enabled: !isLoading,
              //   obscureText: true,
              //   decoration: InputDecoration(
              //     labelText: l10n.auth_password,
              //     prefixIcon: const Icon(Icons.lock_outline),
              //     border: const OutlineInputBorder(),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return l10n.validation_required;
              //     }
              //     if (value.length < 6) {
              //       return l10n.validation_password_min_length(6);
              //     }
              //     return null;
              //   },
              // ),

              // const SizedBox(height: 8),

              // Error message
              // if (error != null)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 8),
              //     child: Text(
              //       error is AppError ? error.message : l10n.auth_login_failed,
              //       style: theme.textTheme.bodySmall?.copyWith(
              //         color: theme.colorScheme.error,
              //       ),
              //       textAlign: TextAlign.center,
              //     ),
              //   ),

              const SizedBox(height: 24),

              // Login button
              ElevatedButton.icon(
                onPressed: isLoading ? null : _handleGoogleLogin,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward),
                label: Text(isLoading ? l10n.auth_signing_in : l10n.auth_login),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 12),

              // TextButton(
              //   onPressed: isLoading
              //       ? null
              //       : () {
              //           showDialog<bool>(
              //             context: context,
              //             barrierDismissible: false,
              //             builder: (context) => const SignUpDialog(),
              //           );
              //         },
              //   child: Text(l10n.auth_dont_have_account),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
