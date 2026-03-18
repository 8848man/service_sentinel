import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/project.dart';
import '../providers/project_provider.dart';

/// Project Edit Screen
///
/// Pre-filled form for updating project name and description.
/// Route: /project/:id/edit
class ProjectEditScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectEditScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends ConsumerState<ProjectEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isActive = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initForm(Project project) {
    if (_isInitialized) return;
    _nameController.text = project.name;
    _descriptionController.text = project.description ?? '';
    _isActive = project.isActive;
    _isInitialized = true;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final updateData = ProjectUpdate(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      isActive: _isActive,
    );

    final useCase = ref.read(updateProjectProvider);
    final result = await useCase.execute(widget.projectId, updateData);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ref.invalidate(projectByIdProvider(widget.projectId));
      ref.invalidate(projectsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project updated successfully')),
        );
        context.pop();
      }
    } else {
      setState(() {
        _errorMessage =
            result.errorOrNull?.message ?? 'Failed to update project';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final projectAsync = ref.watch(projectByIdProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.common_save),
          ),
        ],
      ),
      body: projectAsync.when(
        data: (project) {
          _initForm(project);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.projects_project_name_required,
                      prefixIcon: const Icon(Icons.label),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.validation_project_name_required;
                      }
                      if (value.length > 100) {
                        return l10n.validation_project_name_max_length;
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.projects_description_optional,
                      prefixIcon: const Icon(Icons.description),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: _isLoading
                        ? null
                        : (val) => setState(() => _isActive = val),
                    title: const Text('Monitoring'),
                    secondary: const Icon(Icons.monitor_heart_outlined),
                    contentPadding: EdgeInsets.zero,
                  ),
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.common_save),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading project: $error'),
        ),
      ),
    );
  }
}
