import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/core/constants/enums.dart';
import 'package:service_sentinel_fe_v2/core/extensions/context_extensions.dart';
import 'package:service_sentinel_fe_v2/features/api_monitoring/application/providers/service_provider.dart';
import 'package:service_sentinel_fe_v2/features/api_monitoring/domain/entities/service.dart';

class CreateServiceForm extends ConsumerStatefulWidget {
  const CreateServiceForm({
    required this.title,
    required this.defaultName,
    required this.tabController,
    super.key,
  });

  final String title;
  final String defaultName;
  final TabController tabController;

  @override
  ConsumerState<CreateServiceForm> createState() => _CreateServiceFormState();
}

class _CreateServiceFormState extends ConsumerState<CreateServiceForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _endpointController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.defaultName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _endpointController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final createData = ServiceCreate(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      endpointUrl: _endpointController.text.trim(),
      httpMethod: HttpMethod.get,
      serviceType: ServiceType.httpsApi,
      timeoutSeconds: 10,
      checkIntervalSeconds: 300,
      failureThreshold: 3,
    );

    final useCase = ref.read(createServiceProvider);
    final result = await useCase.execute(createData);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      ref.invalidate(servicesProvider);
      // Navigator.of(context).pop(result.dataOrNull);
      _goNext();
    } else {
      final l10n = context.l10n;
      setState(() {
        _errorMessage =
            result.errorOrNull?.message ?? l10n.error_failed_to_create_service;
      });
    }
  }

  void _goNext() {
    if (widget.tabController.index == widget.tabController.length - 1) {
      ref.invalidate(servicesProvider);
      Navigator.of(context).pop();
      return;
    }
    if (widget.tabController.index < widget.tabController.length - 1) {
      widget.tabController.animateTo(widget.tabController.index + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          key: ValueKey(widget.title),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.services_service_name,
                prefixIcon: const Icon(Icons.label),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validation_required;
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.services_description_optional,
                prefixIcon: const Icon(Icons.description),
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _endpointController,
              decoration: InputDecoration(
                labelText: l10n.services_endpoint_url,
                prefixIcon: const Icon(Icons.link),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validation_required;
                }
                if (!value.startsWith('http://') &&
                    !value.startsWith('https://')) {
                  return l10n.validation_url_protocol;
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleCreate,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label:
                  Text(_isLoading ? l10n.common_creating : l10n.common_create),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceVariant,
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: _isLoading ? null : _goNext,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text('skip'),
            ),
          ],
        ),
      ),
    );
  }
}
