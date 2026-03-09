import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_sentinel_fe_v2/core/di/repository_providers.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/entities/auth_state.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/entities/user.dart';
import 'package:service_sentinel_fe_v2/features/auth/presentation/dialogs/sign_up_dialog.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/migration/migration_provider.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/auth/application/providers/auth_provider.dart';
import 'migration_dialog.dart';

/// Login form section - Smallest UI unit consuming Riverpod provider
/// Handles email/password authentication via Firebase
///
/// Consumes: authStateNotifierProvider
/// Calls: authStateNotifierProvider.notifier.signIn()
/// Side effects:
/// - Shows migration dialog if local projects exist
/// - Navigates to project selection after login
// class LoginFormSection extends ConsumerStatefulWidget {
//   const LoginFormSection({super.key});

//   @override
//   ConsumerState<LoginFormSection> createState() => _LoginFormSectionState();
// }

// class _LoginFormSectionState extends ConsumerState<LoginFormSection> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // Call authStateNotifierProvider.signIn() use case
//       await ref.read(authStateNotifierProvider.notifier).signIn(
//             _emailController.text.trim(),
//             _passwordController.text,
//           );

//       if (!mounted) return;

//       // Check if migration is needed
//       await ref
//           .read(migrationStateNotifierProvider.notifier)
//           .checkMigrationNeeded();

//       if (!mounted) return;

//       final migrationState = ref.read(migrationStateNotifierProvider);
//       if (migrationState.isRequired) {
//         // Show migration dialog
//         final shouldMigrate = await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => const MigrationDialog(),
//         );

//         if (shouldMigrate == true) {
//           // Execute migration
//           await ref
//               .read(migrationStateNotifierProvider.notifier)
//               .executeMigration();
//         } else {
//           // User skipped migration
//           ref.read(migrationStateNotifierProvider.notifier).skipMigration();
//         }
//       }

//       // Navigate to project selection
//       if (mounted) {
//         final authRepo = ref.read(authRepositoryProvider);
//         if (await authRepo.isAuthenticated()) {
//           context.go(AppRoutes.projectSelection);
//         }
//       }
//     } catch (error) {
//       setState(() {
//         _isLoading = false;
//         if (error is AppError) {
//           _errorMessage = error.message;
//         } else {
//           _errorMessage = 'Login failed. Please try again.';
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Icon(
//                 Icons.login,
//                 size: 48,
//                 color: theme.colorScheme.primary,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Sign in with Email',
//                 style: theme.textTheme.titleMedium,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Access your projects from any device with cloud sync.',
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.7),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),

//               // Email field
//               TextFormField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   prefixIcon: Icon(Icons.email_outlined),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!value.contains('@')) {
//                     return 'Please enter a valid email';
//                   }
//                   return null;
//                 },
//                 enabled: !_isLoading,
//               ),

//               const SizedBox(height: 16),

//               // Password field
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: 'Password',
//                   prefixIcon: Icon(Icons.lock_outline),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//                 enabled: !_isLoading,
//               ),

//               const SizedBox(height: 8),

//               // Error message (rendered within section, not full screen)
//               if (_errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: Text(
//                     _errorMessage!,
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: theme.colorScheme.error,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),

//               const SizedBox(height: 24),

//               // Login button (loading state within section)
//               ElevatedButton.icon(
//                 onPressed: _isLoading ? null : _handleLogin,
//                 icon: _isLoading
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Icon(Icons.arrow_forward),
//                 label: Text(_isLoading ? 'Signing in...' : 'Sign In'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Sign up link
//               TextButton(
//                 onPressed: _isLoading
//                     ? null
//                     : () {
//                         // TODO: Navigate to sign up screen
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Sign up feature coming soon'),
//                           ),
//                         );
//                       },
//                 child: const Text('Don\'t have an account? Sign up'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
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
