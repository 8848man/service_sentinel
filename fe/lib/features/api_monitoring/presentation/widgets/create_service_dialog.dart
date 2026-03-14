import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/service_provider.dart';
import '../../domain/entities/service.dart';

/// Create service dialog - Form for registering a new service/API
/// Consumes: (will use ServiceRepository via use case when creating)
///
/// Features:
/// - Service name and description
/// - Endpoint URL
/// - HTTP method selection
/// - Service type selection
/// - Basic configuration (timeout, interval, threshold)
/// - Input validation
/// - Loading state within dialog
///
/// Returns: true if service was created successfully
class CreateServiceDialog extends ConsumerStatefulWidget {
  const CreateServiceDialog({super.key});

  @override
  ConsumerState<CreateServiceDialog> createState() =>
      _CreateServiceDialogState();
}

class _CreateServiceDialogState extends ConsumerState<CreateServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _endpointController = TextEditingController();

  HttpMethod _selectedMethod = HttpMethod.get;
  ServiceType _selectedType = ServiceType.httpsApi;
  int _timeoutSeconds = 10;
  int _checkIntervalSeconds = 300;
  int _failureThreshold = 3;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _endpointController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
      httpMethod: _selectedMethod,
      serviceType: _selectedType,
      timeoutSeconds: _timeoutSeconds,
      checkIntervalSeconds: _checkIntervalSeconds,
      failureThreshold: _failureThreshold,
    );

    final useCase = ref.read(createServiceProvider);
    final result = await useCase.execute(createData);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      // Invalidate services list to refresh
      ref.invalidate(servicesProvider);

      // Close dialog and return the created service
      Navigator.of(context).pop(result.dataOrNull);
    } else {
      final l10n = context.l10n;
      setState(() {
        _errorMessage =
            result.errorOrNull?.message ?? l10n.error_failed_to_create_service;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.services_add_service),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Service name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.services_service_name,
                  hintText: l10n.services_service_name_hint,
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

              // Description
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

              // Endpoint URL
              TextFormField(
                controller: _endpointController,
                decoration: InputDecoration(
                  labelText: l10n.services_endpoint_url,
                  hintText: l10n.services_endpoint_url_hint,
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

              const SizedBox(height: 16),

              // HTTP Method
              DropdownButtonFormField<HttpMethod>(
                value: _selectedMethod,
                decoration: InputDecoration(
                  labelText: l10n.services_http_method,
                  prefixIcon: const Icon(Icons.http),
                  border: const OutlineInputBorder(),
                ),
                items: HttpMethod.values
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method.displayName(context)),
                        ))
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedMethod = value);
                        }
                      },
              ),

              const SizedBox(height: 16),

              // Service Type
              DropdownButtonFormField<ServiceType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: l10n.services_service_type,
                  prefixIcon: const Icon(Icons.category),
                  border: const OutlineInputBorder(),
                ),
                items: ServiceType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName(context)),
                        ))
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
              ),

              const SizedBox(height: 16),

              // Advanced settings
              ExpansionTile(
                title: Text(l10n.services_advanced_settings),
                initiallyExpanded: false,
                children: [
                  const SizedBox(height: 8),
                  // Timeout
                  TextFormField(
                    initialValue: _timeoutSeconds.toString(),
                    decoration: InputDecoration(
                      labelText: l10n.services_timeout_seconds,
                      prefixIcon: const Icon(Icons.timer),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return l10n.validation_invalid_number;
                      }
                      final num = int.parse(value);
                      if (num < 1 || num > 300) {
                        return l10n.validation_number_between(1, 300);
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final num = int.tryParse(value);
                      if (num != null) {
                        setState(() => _timeoutSeconds = num);
                      }
                    },
                    enabled: !_isLoading,
                  ),

                  const SizedBox(height: 12),

                  // Check interval
                  TextFormField(
                    initialValue: _checkIntervalSeconds.toString(),
                    decoration: InputDecoration(
                      labelText: l10n.services_check_interval_seconds,
                      prefixIcon: const Icon(Icons.schedule),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return l10n.validation_invalid_number;
                      }
                      final num = int.parse(value);
                      if (num < 30 || num > 3600) {
                        return l10n.validation_number_between(30, 3600);
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final num = int.tryParse(value);
                      if (num != null) {
                        setState(() => _checkIntervalSeconds = num);
                      }
                    },
                    enabled: !_isLoading,
                  ),

                  const SizedBox(height: 12),

                  // Failure threshold
                  TextFormField(
                    initialValue: _failureThreshold.toString(),
                    decoration: InputDecoration(
                      labelText: l10n.services_failure_threshold,
                      prefixIcon: const Icon(Icons.warning),
                      border: const OutlineInputBorder(),
                      helperText: l10n.services_failure_threshold_desc,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return l10n.validation_invalid_number;
                      }
                      final num = int.parse(value);
                      if (num < 1 || num > 10) {
                        return l10n.validation_number_between(1, 10);
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final num = int.tryParse(value);
                      if (num != null) {
                        setState(() => _failureThreshold = num);
                      }
                    },
                    enabled: !_isLoading,
                  ),

                  const SizedBox(height: 8),
                ],
              ),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        // TextButton(
        //   onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        //   child: Text(l10n.common_cancel),
        // ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleCreate,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: Text(_isLoading ? l10n.common_creating : l10n.common_create),
        ),
      ],
    );
  }
}
