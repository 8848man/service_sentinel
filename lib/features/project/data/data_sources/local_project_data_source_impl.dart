import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/project.dart';
import 'project_data_source.dart';

/// Local project data source implementation using Hive
/// Stores projects locally for guest/unauthenticated users
///
/// Storage format: JSON in Hive box
/// Box name: 'projects'
/// Key: project.id
/// Value: Map<String, dynamic> (JSON)
class LocalProjectDataSourceImpl implements LocalProjectDataSource {
  static const String _boxName = 'projects';
  final _uuid = const Uuid();

  Future<Box<Map>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Map>(_boxName);
    }
    return Hive.box<Map>(_boxName);
  }

  @override
  Future<List<Project>> getAll() async {
    try {
      final box = await _getBox();
      final projects = <Project>[];

      for (var key in box.keys) {
        final json = Map<String, dynamic>.from(box.get(key) as Map);
        // Add isLocalOnly flag for local projects
        json['isLocalOnly'] = true;
        final project = _jsonToDomain(json);
        projects.add(project);
      }

      // Sort by createdAt descending (newest first)
      projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return projects;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Project> getById(String id) async {
    final box = await _getBox();
    final json = box.get(id);

    if (json == null) {
      throw Exception('Project not found: $id');
    }

    final projectJson = Map<String, dynamic>.from(json as Map);
    projectJson['isLocalOnly'] = true;
    return _jsonToDomain(projectJson);
  }

  @override
  Future<Project> create(ProjectCreate data) async {
    // final box = await _getBox();
    // final now = DateTime.now();

    // final project = Project(
    //   id: _uuid.v4(),
    //   name: data.name,
    //   description: data.description,
    //   isActive: true,
    //   createdAt: now,
    //   updatedAt: now,
    //   isLocalOnly: true,
    // );

    // final json = _domainToJson(project);
    // await box.put(project.id, json);

    // return project;
    throw UnimplementedError();
  }

  Future<Project> createByProject(Project data) async {
    final box = await _getBox();

    final project = Project(
      id: data.id,
      name: data.name,
      description: data.description,
      isActive: true,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isLocalOnly: true,
    );

    final json = _domainToJson(project);
    await box.put(project.id, json);

    return project;
  }

  @override
  Future<Project> update(String id, ProjectUpdate data) async {
    final box = await _getBox();
    final existing = await getById(id);

    final updated = Project(
      id: existing.id,
      name: data.name ?? existing.name,
      description: data.description ?? existing.description,
      isActive: data.isActive ?? existing.isActive,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      isLocalOnly: true,
    );

    final json = _domainToJson(updated);
    await box.put(id, json);

    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<bool> existsByName(String name) async {
    final projects = await getAll();
    return projects.any((p) => p.name.toLowerCase() == name.toLowerCase());
  }

  @override
  Future<void> markAllAsLocalOnly() async {
    // Already handled in getAll() and other methods by setting isLocalOnly = true
    // This is a no-op for local storage
  }

  @override
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }

  /// Convert domain Project to JSON for storage
  Map<String, dynamic> _domainToJson(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'description': project.description,
      'is_active': project.isActive,
      'created_at': project.createdAt.toIso8601String(),
      'updated_at': project.updatedAt.toIso8601String(),
      'is_local_only': project.isLocalOnly,
    };
  }

  /// Convert JSON to domain Project
  Project _jsonToDomain(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isLocalOnly: json['is_local_only'] as bool? ??
          json['isLocalOnly'] as bool? ??
          true,
    );
  }
}
