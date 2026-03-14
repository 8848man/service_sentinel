# Service Sentinel Frontend V2 - Project Structure

Quick reference guide for navigating the codebase.

---

## 📁 Root Directory

```
service_sentinel_fe_v2/
├── lib/                    # Application source code
├── assets/                 # Static assets (images, translations)
├── test/                   # Test files
├── pubspec.yaml            # Dependencies and metadata
├── analysis_options.yaml   # Linter rules
├── .gitignore             # Git ignore rules
├── README_FE.md           # Comprehensive documentation
├── ARCHITECTURE.md        # Architecture diagrams and explanations
└── PROJECT_STRUCTURE.md   # This file
```

---

## 📦 lib/ Directory

### Core Infrastructure (`lib/core/`)

Common utilities and configurations shared across features.

```
core/
├── config/
│   └── app_config.dart              # Environment configuration (API URLs, timeouts)
│
├── constants/
│   └── app_spacing.dart             # Spacing constants (xs, sm, md, lg, xl)
│
├── di/
│   └── providers.dart               # Global Riverpod providers
│
├── error/
│   ├── app_error.dart               # Error type hierarchy
│   └── error_handler.dart           # Error conversion logic
│
├── l10n/
│   ├── app_localizations.dart       # i18n loader and translate()
│   └── locale_provider.dart         # Locale state management
│
├── navigation/
│   └── main_scaffold.dart           # Bottom navigation scaffold
│
├── network/
│   └── dio_client.dart              # HTTP client with interceptors
│
├── router/
│   └── app_router.dart              # GoRouter configuration
│
├── storage/
│   └── secure_storage.dart          # Secure storage wrapper
│
└── theme/
    ├── app_colors.dart              # Color palette (Light/Dark/Blue)
    ├── app_theme.dart               # ThemeData configurations
    ├── app_theme_mode.dart          # Theme mode enum
    └── theme_provider.dart          # Theme state management
```

---

### Features (`lib/features/`)

Feature-first architecture with Clean Architecture inside each feature.

```
features/
├── auth/
│   ├── presentation/
│   │   └── screens/
│   │       ├── splash_screen.dart         # Initial loading screen
│   │       └── login_screen.dart          # Login/signup screen
│   ├── application/                       # [To be implemented]
│   ├── domain/                            # [To be implemented]
│   └── infrastructure/                    # [To be implemented]
│
├── project/
│   ├── presentation/
│   │   └── screens/
│   │       └── project_selection_screen.dart  # Project selection/creation
│   ├── application/                       # [To be implemented]
│   ├── domain/                            # [To be implemented]
│   └── infrastructure/                    # [To be implemented]
│
├── api_monitoring/                        # Service monitoring feature
│   ├── presentation/                      # [To be implemented]
│   ├── application/                       # [To be implemented]
│   ├── domain/                            # [To be implemented]
│   └── infrastructure/                    # [To be implemented]
│
├── incident/                              # Incident management feature
│   ├── presentation/                      # [To be implemented]
│   ├── application/                       # [To be implemented]
│   ├── domain/                            # [To be implemented]
│   └── infrastructure/                    # [To be implemented]
│
└── settings/                              # Settings feature
    └── presentation/                      # [To be implemented]
```

---

### Entry Points (`lib/`)

```
lib/
├── main.dart           # Application entry point
└── app.dart           # Root app widget with theme & localization
```

---

## 🎨 assets/ Directory

```
assets/
├── images/             # Image assets (logos, icons, etc.)
└── translations/
    ├── en.json        # English translations
    └── ko.json        # Korean translations
```

**Translation File Structure:**
```json
{
  "app": { "title": "...", "subtitle": "..." },
  "common": { "ok": "...", "cancel": "..." },
  "auth": { "login": "...", "logout": "..." },
  "navigation": { "dashboard": "..." },
  ...
}
```

---

## 🧪 test/ Directory

```
test/
├── unit/              # Unit tests for domain/application logic
├── widget/            # Widget tests for UI components
└── integration/       # Integration tests for full flows
```

---

## 📊 Feature Structure Template

Each feature follows this structure:

```
features/{feature_name}/
├── presentation/
│   ├── screens/           # Full-page screens
│   ├── widgets/           # Reusable UI components
│   └── providers/         # Riverpod providers for UI state
│
├── application/
│   ├── use_cases/         # Business operations (e.g., CreateProject)
│   └── state/             # State notifiers and logic
│
├── domain/
│   ├── entities/          # Core business models
│   ├── repositories/      # Repository interfaces (abstract)
│   └── value_objects/     # Immutable value objects
│
└── infrastructure/
    ├── api/               # API clients (Retrofit)
    ├── models/            # DTOs (data transfer objects)
    └── repositories/      # Repository implementations (concrete)
```

---

## 🔑 Key Files

### Configuration
- `lib/core/config/app_config.dart` - Change API URL here

### Theming
- `lib/core/theme/app_theme.dart` - Add/modify themes
- `lib/core/theme/app_colors.dart` - Update color palette

### Localization
- `assets/translations/*.json` - Add/modify translations
- `lib/core/l10n/app_localizations.dart` - Change supported locales

### Navigation
- `lib/core/router/app_router.dart` - Add/modify routes

### Dependencies
- `pubspec.yaml` - Add/remove packages

### Linting
- `analysis_options.yaml` - Configure linter rules

---

## 🚀 Common Tasks

### Add a new screen
1. Create screen file in `features/{feature}/presentation/screens/`
2. Add route in `lib/core/router/app_router.dart`
3. Add translations in `assets/translations/*.json`

### Add a new feature
1. Create feature folder in `lib/features/{feature_name}/`
2. Create layer folders: `presentation/`, `application/`, `domain/`, `infrastructure/`
3. Follow the feature structure template above

### Add a new theme
1. Update `AppThemeMode` enum in `app_theme_mode.dart`
2. Add colors in `app_colors.dart`
3. Create theme in `app_theme.dart`

### Add a new language
1. Create `assets/translations/{locale}.json`
2. Add locale to `AppLocalizations.supportedLocales`
3. Update `AppLocale` enum in `app_localizations.dart`

### Add a new API endpoint
1. Define entity in `domain/entities/`
2. Define repository interface in `domain/repositories/`
3. Create Retrofit client in `infrastructure/api/`
4. Implement repository in `infrastructure/repositories/`
5. Create use case in `application/use_cases/`
6. Create provider in `presentation/providers/`

---

## 📝 Naming Conventions

### Files
- **Screens**: `{name}_screen.dart` (e.g., `login_screen.dart`)
- **Widgets**: `{name}_widget.dart` or just `{name}.dart`
- **Providers**: `{name}_provider.dart`
- **Use Cases**: `{action}_{entity}.dart` (e.g., `create_project.dart`)
- **Entities**: `{name}.dart` (e.g., `project.dart`)
- **Repositories**: `{name}_repository.dart`

### Classes
- **Screens**: `{Name}Screen` (e.g., `LoginScreen`)
- **Widgets**: `{Name}Widget` or `{Name}`
- **Providers**: `{name}Provider` (e.g., `authStateProvider`)
- **Use Cases**: `{Action}{Entity}` (e.g., `CreateProject`)
- **Entities**: `{Name}` (e.g., `Project`)
- **Repositories**: `{Name}Repository` interface, `{Source}{Name}Repository` implementation

---

## 🔗 Dependencies

### Core Dependencies
- **State Management**: `flutter_riverpod`, `riverpod_annotation`
- **Routing**: `go_router`
- **Networking**: `dio`, `retrofit`
- **Local Storage**: `hive`, `shared_preferences`, `flutter_secure_storage`
- **Serialization**: `json_annotation`, `freezed`
- **Firebase**: `firebase_auth`, `firebase_core`
- **UI**: `google_fonts`, `flutter_svg`

### Dev Dependencies
- **Code Generation**: `build_runner`, `riverpod_generator`, `json_serializable`, `freezed`, `retrofit_generator`
- **Linting**: `flutter_lints`

---

## 📖 Documentation

- **README_FE.md** - Comprehensive guide (architecture, setup, integration)
- **ARCHITECTURE.md** - Detailed architecture diagrams and explanations
- **PROJECT_STRUCTURE.md** - This file (quick navigation reference)

---

## 🎯 Next Implementation Phases

### Phase 1: Foundation ✅
- Project structure
- Theme system
- i18n
- Navigation
- Core abstractions

### Phase 2: Authentication & Projects
- Firebase Authentication
- Project CRUD
- API key management
- Local/Remote data source switching

### Phase 3: Service Monitoring
- Service list/detail screens
- Service CRUD operations
- Health check display
- Manual health check trigger

### Phase 4: Incident Management
- Incident list/detail screens
- AI analysis display
- Incident status management
- Filtering and sorting

### Phase 5: Dashboard & Settings
- Dashboard overview
- Service health metrics
- Settings screen
- Theme/language toggles

### Phase 6: Local Database & Migration
- Hive setup
- Guest mode
- Data migration
- Conflict resolution

---

**Happy Coding! 🚀**
