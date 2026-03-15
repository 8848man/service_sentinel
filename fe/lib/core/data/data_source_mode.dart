/// Data source mode - determines where data is stored and retrieved
/// This is the single source of truth for all repository implementations
enum DataSourceMode {
  /// Local mode - uses local database (Hive)
  /// Used for guest/unauthenticated users
  local,

  /// Server mode - uses remote REST API
  /// Used for authenticated users with valid API key
  server,
}

extension DataSourceModeExtension on DataSourceMode {
  bool get isLocal => this == DataSourceMode.local;
  bool get isServer => this == DataSourceMode.server;

  String get displayName {
    switch (this) {
      case DataSourceMode.local:
        return 'Local Storage';
      case DataSourceMode.server:
        return 'Server Storage';
    }
  }
}
