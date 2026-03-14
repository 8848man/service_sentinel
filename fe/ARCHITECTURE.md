# Service Sentinel Frontend - Architecture Document

## Architecture Overview

This document provides a comprehensive overview of the Service Sentinel Frontend V2 architecture.

---

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  ┌─────────┐  ┌─────────┐  ┌──────────┐  ┌──────────┐     │
│  │ Screens │  │ Widgets │  │ ViewModels│ │ Providers │     │
│  └─────────┘  └─────────┘  └──────────┘  └──────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│  ┌──────────┐  ┌────────────┐  ┌────────────────┐          │
│  │ Use Cases│  │ State Logic│  │ Business Rules │          │
│  └──────────┘  └────────────┘  └────────────────┘          │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌──────────┐  ┌────────────────┐  ┌──────────────┐        │
│  │ Entities │  │ Repository Iface│  │ Value Objects│        │
│  └──────────┘  └────────────────┘  └──────────────┘        │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                  INFRASTRUCTURE LAYER                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │API Client│  │Local DB  │  │Remote DB │  │Storage   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Feature-First Structure

Each feature is self-contained with its own Clean Architecture layers:

```
features/{feature_name}/
├── presentation/        # UI components
│   ├── screens/         # Full-page screens
│   ├── widgets/         # Reusable UI components
│   └── providers/       # Riverpod state providers
├── application/         # Application logic
│   ├── use_cases/       # Business operations
│   └── state/           # State management
├── domain/             # Business logic
│   ├── entities/        # Core models
│   ├── repositories/    # Abstract contracts
│   └── value_objects/   # Immutable values
└── infrastructure/     # External dependencies
    ├── api/             # API clients
    ├── repositories/    # Repository implementations
    └── models/          # Data transfer objects
```

---

## 3. Dependency Flow

```
Presentation → Application → Domain ← Infrastructure
```

**Rules:**
- Presentation depends on Application and Domain
- Application depends on Domain
- Infrastructure depends on Domain
- Domain has NO dependencies (pure business logic)

---

## 4. State Management Architecture

### Riverpod Provider Types

```
┌─────────────────────────────────────────────────────────┐
│ Provider Types by Use Case                               │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Simple State          → StateNotifierProvider          │
│  (theme, locale)                                         │
│                                                          │
│  Async State           → AsyncNotifierProvider           │
│  (API calls)                                             │
│                                                          │
│  One-time Fetch        → FutureProvider                  │
│  (initial data)                                          │
│                                                          │
│  Real-time Updates     → StreamProvider                  │
│  (health checks)                                         │
│                                                          │
│  Dependency Injection  → Provider                        │
│  (repositories, clients)                                 │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### State Flow Example

```
User Action (Tap Button)
    ↓
Widget calls Provider method
    ↓
Provider → Use Case → Repository → API Client
    ↓
State updated (loading → success/error)
    ↓
Widget rebuilds with new state
```

---

## 5. Data Flow Architecture

### Authenticated Mode (Server DB)

```
┌──────────┐    ┌──────────────┐    ┌──────────┐    ┌──────────┐
│  Widget  │ →  │ Use Case     │ →  │ Remote   │ →  │ Backend  │
│          │    │              │    │Repository│    │   API    │
└──────────┘    └──────────────┘    └──────────┘    └──────────┘
     ↑                                                      ↓
     └──────────────────────────────────────────────────────┘
                      Data flow back
```

### Guest Mode (Local DB)

```
┌──────────┐    ┌──────────────┐    ┌──────────┐    ┌──────────┐
│  Widget  │ →  │ Use Case     │ →  │  Local   │ →  │  Hive    │
│          │    │              │    │Repository│    │   DB     │
└──────────┘    └──────────────┘    └──────────┘    └──────────┘
     ↑                                                      ↓
     └──────────────────────────────────────────────────────┘
                      Data flow back
```

### Repository Switching

```dart
@riverpod
ServiceRepository serviceRepository(ServiceRepositoryRef ref) {
  final isAuthenticated = ref.watch(authStateProvider).isAuthenticated;

  if (isAuthenticated) {
    return RemoteServiceRepository(
      apiClient: ref.read(apiClientProvider),
    );
  } else {
    return LocalServiceRepository(
      db: ref.read(hiveBoxProvider),
    );
  }
}
```

---

## 6. Navigation Architecture

### Router Structure

```
Splash Screen (/)
    ↓
  [Check Auth & Project]
    ↓
    ├─→ Login Screen (/login)
    │       ↓
    │   [Authenticate]
    │       ↓
    └─→ Project Selection (/project-selection)
            ↓
        [Select/Create Project]
            ↓
        Main App (/main)
            ├─→ Dashboard (/main/dashboard)
            ├─→ Services (/main/services)
            ├─→ Incidents (/main/incidents)
            └─→ Settings (/main/settings)
```

### Navigation Implementation

- **Router**: GoRouter for declarative routing
- **Shell Route**: MainScaffold wraps main app screens
- **Deep Linking**: Supports query parameters for filtering
- **State-based Navigation**: Routes change based on auth state

---

## 7. Theme Architecture

### Theme Structure

```
┌───────────────────────────────────────────────────────┐
│                  AppThemeMode (Enum)                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │  Light   │  │  Dark    │  │  Blue    │           │
│  └──────────┘  └──────────┘  └──────────┘           │
└────────────────────┬──────────────────────────────────┘
                     │
┌────────────────────▼──────────────────────────────────┐
│                 AppColors (Palette)                    │
│  ┌─────────────────────────────────────────────────┐ │
│  │ Light Colors  │ Dark Colors  │ Blue Colors     │ │
│  └─────────────────────────────────────────────────┘ │
└────────────────────┬──────────────────────────────────┘
                     │
┌────────────────────▼──────────────────────────────────┐
│                AppTheme (ThemeData)                    │
│  Generates ThemeData for each AppThemeMode            │
└────────────────────┬──────────────────────────────────┘
                     │
┌────────────────────▼──────────────────────────────────┐
│             ThemeProvider (Riverpod)                   │
│  Manages theme state & persistence                    │
└───────────────────────────────────────────────────────┘
```

### Theme Switching Flow

```
User selects theme in Settings
    ↓
ThemeProvider.setThemeMode(mode)
    ↓
Save to SharedPreferences
    ↓
Update state
    ↓
MaterialApp rebuilds with new theme
```

---

## 8. Internationalization Architecture

### i18n Structure

```
┌───────────────────────────────────────────────────────┐
│           Translation Files (JSON)                     │
│  ┌──────────────┐         ┌──────────────┐           │
│  │   en.json    │         │   ko.json    │           │
│  │  (English)   │         │  (Korean)    │           │
│  └──────────────┘         └──────────────┘           │
└────────────────────┬──────────────────────────────────┘
                     │
┌────────────────────▼──────────────────────────────────┐
│             AppLocalizations (Loader)                  │
│  Loads JSON and provides translate() method          │
└────────────────────┬──────────────────────────────────┘
                     │
┌────────────────────▼──────────────────────────────────┐
│            LocaleProvider (Riverpod)                   │
│  Manages locale state & persistence                   │
└────────────────────┬──────────────────────────────────┘
                     │
┌────────────────────▼──────────────────────────────────┐
│              MaterialApp.locale                        │
│  Applies selected locale to entire app               │
└───────────────────────────────────────────────────────┘
```

---

## 9. Error Handling Architecture

### Error Hierarchy

```
Exception
    ↓
AppError (abstract)
    ├─→ NetworkError
    ├─→ AuthError
    ├─→ ValidationError
    ├─→ ServerError
    ├─→ NotFoundError
    ├─→ UnauthorizedError
    └─→ StorageError
```

### Error Flow

```
API Call
    ↓
Dio throws DioException
    ↓
ErrorHandler.handleError()
    ↓
Convert to AppError
    ↓
AsyncValue.error(AppError)
    ↓
Widget displays error
```

---

## 10. Security Architecture

### API Key Management

```
┌─────────────────────────────────────────────────────┐
│ 1. User creates API key via backend                 │
│    POST /api/v2/projects/{id}/api-keys             │
└────────────────────┬────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│ 2. Backend returns key_value (ONLY ONCE)            │
│    Response: { "key_value": "ss_abc123..." }       │
└────────────────────┬────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│ 3. Frontend stores in FlutterSecureStorage          │
│    await SecureStorage.saveApiKey(keyValue);        │
└────────────────────┬────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│ 4. DioClient injects key into all requests          │
│    headers: { "X-API-Key": "ss_abc123..." }        │
└─────────────────────────────────────────────────────┘
```

### Authentication States

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Guest     │ →   │ Logged In   │ →   │ Logged Out  │
│             │     │ + Project   │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
      ↓                    ↓                    ↓
  Local DB          Server DB + API Key    Clear Storage
```

---

## 11. Testing Architecture

### Test Pyramid

```
       ┌────────┐
      /  E2E     \          ← Integration Tests (Few)
     /   Tests    \
    ├──────────────┤
   /  Widget Tests  \       ← Widget Tests (Some)
  /                  \
 ├────────────────────┤
/   Unit Tests         \    ← Unit Tests (Many)
──────────────────────────
```

### Testing Strategy

| Layer | Test Type | Coverage Target |
|-------|-----------|----------------|
| Domain | Unit Tests | 90%+ |
| Application | Unit Tests | 80%+ |
| Infrastructure | Integration Tests | 70%+ |
| Presentation | Widget Tests | 60%+ |

---

## 12. Build & Deployment Architecture

### Build Process

```
1. Code Generation
   flutter pub run build_runner build
       ↓
2. Analysis
   flutter analyze
       ↓
3. Testing
   flutter test
       ↓
4. Build
   flutter build [platform]
       ↓
5. Deploy
   [Platform-specific deployment]
```

---

## 13. Performance Considerations

### Optimization Strategies

1. **State Management**
   - Use `.autoDispose` for temporary providers
   - Minimize widget rebuilds with `select()`
   - Cache frequently accessed data

2. **Network**
   - Debounce API calls
   - Implement pagination for lists
   - Cache responses when appropriate

3. **UI**
   - Use `const` constructors where possible
   - Implement lazy loading for lists
   - Optimize image loading

4. **Storage**
   - Use Hive for local DB (fast binary storage)
   - Encrypt sensitive data
   - Clean up old data periodically

---

## Summary

This architecture provides:

✅ **Separation of Concerns**: Clear layer boundaries
✅ **Testability**: Easy to mock and test each layer
✅ **Scalability**: Add features without breaking existing code
✅ **Maintainability**: Clear structure and conventions
✅ **Flexibility**: Swap implementations (Local ↔ Remote)
✅ **Type Safety**: Leverage Dart's strong typing
✅ **Performance**: Optimized state management and data access

---

**Next Steps**: Implement business logic features following this architecture.
