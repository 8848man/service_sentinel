import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/auth/application/providers/auth_provider.dart';
import '../../application/providers/bootstrap_provider.dart';
import '../../application/providers/project_provider.dart';
import '../../domain/entities/bootstrap.dart';
import '../../domain/entities/project.dart';

/// Project Create Dialog
///
/// Modal dialog for creating a new project.
/// Handles both authenticated and guest users:
/// - Authenticated: Calls standard CreateProject use case
/// - Guest (first time): Calls Bootstrap endpoint, then stores Guest API Key
/// - Guest (subsequent): Calls standard CreateProject use case
class ProjectCreateDialog extends ConsumerStatefulWidget {
  const ProjectCreateDialog({super.key});

  @override
  ConsumerState<ProjectCreateDialog> createState() =>
      _ProjectCreateDialogState();
}

class _ProjectCreateDialogState extends ConsumerState<ProjectCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Check authentication state
    final authState = ref.read(authStateNotifierProvider).value;

    if (authState == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.error_auth_unavailable;
      });
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    Project? createdProject;

    if (authState.isAuthenticated) {
      // Authenticated user: Use standard create project flow
      createdProject = await _createProjectAuthenticated(name, description);
    } else {
      // Guest user: Check if bootstrap is needed
      final guestApiKeyService = ref.watch(guestApiKeyServiceProvider);
      final hasGuestKey = guestApiKeyService.hasGuestKey();

      if (!hasGuestKey) {
        // First time creating project: Bootstrap
        createdProject = await _bootstrapGuestUser(name, description);
      } else {
        // // Subsequent project creation: Use standard flow
        // createdProject = await _createProjectAuthenticated(name, description);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.error_guest_limit),
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (createdProject != null) {
      // Invalidate projects list to refresh
      ref.invalidate(projectsProvider);

      // Close dialog and return the created project
      Navigator.of(context).pop(createdProject);
    }
    // Error message already set by helper methods
  }

  /// Create project for authenticated users
  Future<Project?> _createProjectAuthenticated(
      String name, String? description) async {
    final createData = ProjectCreate(
      name: name,
      description: description,
    );

    final useCase = ref.read(createProjectProvider);
    final result = await useCase.execute(createData);

    if (result.isSuccess) {
      return result.dataOrNull;
    } else {
      final error = result.errorOrNull;

      // Check if it's a guest limit error
      if (error is GuestProjectLimitError) {
        if (!mounted) return null;
        await _showGuestLimitDialog();
        return null;
      }

      final l10n = context.l10n;
      setState(() {
        _errorMessage = error?.message ?? l10n.error_failed_to_create_project;
      });
      return null;
    }
  }

  /// Bootstrap guest user (first project creation)
  Future<Project?> _bootstrapGuestUser(String name, String? description) async {
    final bootstrapRequest = BootstrapRequest(
      name: name,
      description: description,
    );

    final useCase = ref.read(bootstrapGuestUserProvider);
    final result = await useCase.execute(bootstrapRequest);

    if (result.isSuccess) {
      // Bootstrap successful - Guest API Key is automatically stored by use case
      final response = result.dataOrNull!;
      return response.project;
    } else {
      final l10n = context.l10n;
      setState(() {
        _errorMessage =
            result.errorOrNull?.message ?? l10n.error_failed_to_bootstrap_guest;
      });
      return null;
    }
  }

  /// Show guest limit dialog
  /// Informs user that guest accounts are limited to 1 project
  /// Provides option to sign in for unlimited projects
  Future<void> _showGuestLimitDialog() async {
    final l10n = context.l10n;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.projects_guest_limit_reached),
        content: Text(l10n.projects_guest_limit_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Navigate back to login screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(l10n.projects_sign_in),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.projects_create_new_project),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Project Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.projects_project_name_required,
                  hintText: l10n.projects_project_name_hint,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validation_project_name_required;
                  }
                  if (value.length > 100) {
                    return l10n.validation_project_name_max_length;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Project Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.projects_description_optional,
                  hintText: l10n.projects_description_hint,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),

        // Create Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCreate,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.common_create),
        ),
      ],
    );
  }
}
