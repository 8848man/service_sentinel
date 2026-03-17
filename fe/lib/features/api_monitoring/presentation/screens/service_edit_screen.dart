import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/service.dart';
import '../providers/service_provider.dart';

/// Service Edit Screen
///
/// Pre-filled form for updating a monitored service.
/// Route: /service/:id/edit
class ServiceEditScreen extends ConsumerStatefulWidget {
  final String serviceId;

  const ServiceEditScreen({
    super.key,
    required this.serviceId,
  });

  @override
  ConsumerState<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends ConsumerState<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _endpointController = TextEditingController();

  HttpMethod _selectedMethod = HttpMethod.get;
  int _timeoutSeconds = 10;
  int _checkIntervalSeconds = 60;
  int _failureThreshold = 3;

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _endpointController.dispose();
    super.dispose();
  }

  void _initForm(Service service) {
    if (_isInitialized) return;
    _nameController.text = service.name;
    _descriptionController.text = service.description ?? '';
    _endpointController.text = service.endpointUrl;
    _selectedMethod = service.httpMethod;
    _timeoutSeconds = service.timeoutSeconds;
    _checkIntervalSeconds = service.checkIntervalSeconds;
    _failureThreshold = service.failureThreshold;
    _isInitialized = true;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final updateData = ServiceUpdate(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      endpointUrl: _endpointController.text.trim(),
      httpMethod: _selectedMethod,
      timeoutSeconds: _timeoutSeconds,
      checkIntervalSeconds: _checkIntervalSeconds,
      failureThreshold: _failureThreshold,
    );

    final serviceId = int.parse(widget.serviceId);
    final useCase = ref.read(updateServiceProvider);
    final result = await useCase.execute(serviceId, updateData);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ref.invalidate(serviceByIdProvider(serviceId));
      ref.invalidate(servicesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully')),
        );
        context.pop();
      }
    } else {
      setState(() {
        _errorMessage =
            result.errorOrNull?.message ?? 'Failed to update service';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final serviceId = int.parse(widget.serviceId);
    final serviceAsync = ref.watch(serviceByIdProvider(serviceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Service'),
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
      body: serviceAsync.when(
        data: (service) {
          _initForm(service);
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
                      labelText: l10n.services_service_name,
                      prefixIcon: const Icon(Icons.label),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.validation_required;
                      }
                      if (value.length > 100) {
                        return l10n.validation_max_length(100);
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
                  const SizedBox(height: 16),
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
                  ExpansionTile(
                    title: Text(l10n.services_advanced_settings),
                    initiallyExpanded: false,
                    children: [
                      const SizedBox(height: 8),
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
                          if (num != null) setState(() => _timeoutSeconds = num);
                        },
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 12),
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
                          if (num < 10 || num > 3600) {
                            return l10n.validation_number_between(10, 3600);
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
          child: Text('Error loading service: $error'),
        ),
      ),
    );
  }
}
