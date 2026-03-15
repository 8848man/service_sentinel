#!/usr/bin/env bash
# Automates all barrel import refactoring steps described in fe_barrel_refactor.md.
# Each step edits exactly one source file, then stages and commits it.
#
# Usage: bash refactor/fe_barrel_steps.sh
#        (run from repo root, or any directory — script resolves root via git)

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# ---------------------------------------------------------------------------
# Group 1 — core/auth
# ---------------------------------------------------------------------------

# ── Step 1.1 ────────────────────────────────────────────────────────────────
# fe/lib/core/auth/application/providers/auth_provider.dart
# Replace 3 package imports and 1 relative import with 3 barrel imports.
FILE="fe/lib/core/auth/application/providers/auth_provider.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/core/auth/data/repositories/device_token_repository.dart';|import 'package:service_sentinel_fe_v2/core/auth/data/public.dart';|" "$FILE"
sed -i "s|import 'package:service_sentinel_fe_v2/core/auth/di/repository_providers.dart';|import 'package:service_sentinel_fe_v2/core/auth/di/public.dart';|" "$FILE"
sed -i "s|import 'package:service_sentinel_fe_v2/core/auth/domain/usecases/register_device_token.dart';|import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';|" "$FILE"
# relative import already covered by the domain barrel above — delete it
sed -i "\|import '../../domain/entities/auth_state.dart';|d" "$FILE"
git add "$FILE"
git commit -m "refactor(core/auth): replace deep imports with barrel files in auth_provider"

# ── Step 1.2 ────────────────────────────────────────────────────────────────
# fe/lib/core/auth/data/repositories/auth_repository.dart
# Replace individual domain entity import with domain barrel.
FILE="fe/lib/core/auth/data/repositories/auth_repository.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/core/auth/domain/entities/user.dart';|import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(core/auth): replace deep imports with barrel files in auth_repository"

# ── Step 1.3 ────────────────────────────────────────────────────────────────
# fe/lib/core/auth/data/repositories/device_token_repository.dart
# Replace individual domain repository import with domain barrel.
FILE="fe/lib/core/auth/data/repositories/device_token_repository.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/core/auth/domain/repositories/device_token_repository.dart';|import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(core/auth): replace deep imports with barrel files in device_token_repository"

# ── Step 1.4 ────────────────────────────────────────────────────────────────
# fe/lib/core/auth/di/repository_providers.dart
# Replace 1 package import (data impl) and 1 relative import (domain interface)
# with their respective barrel files.
FILE="fe/lib/core/auth/di/repository_providers.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/core/auth/data/repositories/auth_repository.dart';|import 'package:service_sentinel_fe_v2/core/auth/data/public.dart';|" "$FILE"
sed -i "s|import '../domain/repositories/auth_repository.dart';|import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(core/auth): replace deep imports with barrel files in repository_providers"

# ---------------------------------------------------------------------------
# Group 2 — features/auth
# ---------------------------------------------------------------------------

# ── Step 2.1 ────────────────────────────────────────────────────────────────
# fe/lib/features/auth/presentation/screens/login_screen.dart
FILE="fe/lib/features/auth/presentation/screens/login_screen.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/core/auth/application/providers/auth_provider.dart';|import 'package:service_sentinel_fe_v2/core/auth/application/public.dart';|" "$FILE"
sed -i "s|import 'package:service_sentinel_fe_v2/core/auth/domain/entities/auth_state.dart';|import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(features/auth): replace deep imports with barrel files in login_screen"

# ── Step 2.2 ────────────────────────────────────────────────────────────────
# fe/lib/features/auth/presentation/widgets/login_form_section.dart
FILE="fe/lib/features/auth/presentation/widgets/login_form_section.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/core/auth/domain/entities/auth_state.dart';|import 'package:service_sentinel_fe_v2/core/auth/domain/public.dart';|" "$FILE"
sed -i "s|import '../../../../core/auth/application/providers/auth_provider.dart';|import 'package:service_sentinel_fe_v2/core/auth/application/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(features/auth): replace deep imports with barrel files in login_form_section"

# ---------------------------------------------------------------------------
# Group 3 — features/api_monitoring
# ---------------------------------------------------------------------------

# ── Step 3.1 ────────────────────────────────────────────────────────────────
# fe/lib/features/api_monitoring/presentation/widgets/create_service_set_form.dart
FILE="fe/lib/features/api_monitoring/presentation/widgets/create_service_set_form.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/features/api_monitoring/domain/entities/service.dart';|import 'package:service_sentinel_fe_v2/features/api_monitoring/domain/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(features/api_monitoring): replace deep imports with barrel files in create_service_set_form"

# ---------------------------------------------------------------------------
# Group 4 — features/dashboard
# ---------------------------------------------------------------------------

# ── Step 4.1 ────────────────────────────────────────────────────────────────
# fe/lib/features/dashboard/data/data_sources/global_dashboard_data_source.dart
# Collapse 3 domain entity imports into 1 domain barrel.
FILE="fe/lib/features/dashboard/data/data_sources/global_dashboard_data_source.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';|import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';|" "$FILE"
sed -i "\|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';|d" "$FILE"
sed -i "\|import '../../domain/entities/global_dashboard_metrics.dart';|d" "$FILE"
git add "$FILE"
git commit -m "refactor(features/dashboard): replace deep imports with barrel files in global_dashboard_data_source"

# ── Step 4.2 ────────────────────────────────────────────────────────────────
# fe/lib/features/dashboard/data/data_sources/remote_global_dashboard_data_source_impl.dart
# Collapse 3 domain imports (2 package + 1 relative) into 1 domain barrel.
FILE="fe/lib/features/dashboard/data/data_sources/remote_global_dashboard_data_source_impl.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';|import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';|" "$FILE"
sed -i "\|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';|d" "$FILE"
sed -i "\|import '../../domain/entities/global_dashboard_metrics.dart';|d" "$FILE"
git add "$FILE"
git commit -m "refactor(features/dashboard): replace deep imports with barrel files in remote_global_dashboard_data_source_impl"

# ── Step 4.3 ────────────────────────────────────────────────────────────────
# fe/lib/features/dashboard/data/models/dashboard_metrics_dto.dart
FILE="fe/lib/features/dashboard/data/models/dashboard_metrics_dto.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';|import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(features/dashboard): replace deep imports with barrel files in dashboard_metrics_dto"

# ── Step 4.4 ────────────────────────────────────────────────────────────────
# fe/lib/features/dashboard/data/models/dashboard_overview_dto.dart
FILE="fe/lib/features/dashboard/data/models/dashboard_overview_dto.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';|import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(features/dashboard): replace deep imports with barrel files in dashboard_overview_dto"

# ── Step 4.5 ────────────────────────────────────────────────────────────────
# fe/lib/features/dashboard/data/models/service_health_summary_dto.dart
FILE="fe/lib/features/dashboard/data/models/service_health_summary_dto.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/service_health_summary.dart';|import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(features/dashboard): replace deep imports with barrel files in service_health_summary_dto"

# ── Step 4.6 ────────────────────────────────────────────────────────────────
# fe/lib/features/dashboard/data/repositories/dashboard_repository_impl.dart
# Collapse 4 domain imports (2 package + 2 relative) into 1 domain barrel.
FILE="fe/lib/features/dashboard/data/repositories/dashboard_repository_impl.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';|import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';|" "$FILE"
sed -i "\|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';|d" "$FILE"
sed -i "\|import '../../domain/entities/global_dashboard_metrics.dart';|d" "$FILE"
sed -i "\|import '../../domain/repositories/dashboard_repository.dart';|d" "$FILE"
git add "$FILE"
git commit -m "refactor(features/dashboard): replace deep imports with barrel files in dashboard_repository_impl"

# ── Step 4.7 ────────────────────────────────────────────────────────────────
# fe/lib/features/dashboard/presentation/providers/dashboard_provider.dart
# Collapse 7 domain/di imports into 2 barrel imports.
FILE="fe/lib/features/dashboard/presentation/providers/dashboard_provider.dart"
# Replace the first domain import with the domain barrel; delete the rest.
sed -i "s|import 'package:service_sentinel_fe_v2/features/dashboard/domain/usecases/get_dashboard_matrix.dart';|import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';|" "$FILE"
sed -i "\|import 'package:service_sentinel_fe_v2/features/dashboard/domain/usecases/get_dashboard_overview.dart';|d" "$FILE"
sed -i "\|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';|d" "$FILE"
sed -i "\|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';|d" "$FILE"
sed -i "\|import '../../domain/usecases/get_global_dashboard.dart';|d" "$FILE"
sed -i "\|import '../../domain/entities/global_dashboard_metrics.dart';|d" "$FILE"
# Replace the relative di import with the di barrel.
sed -i "s|import '../../di/repository_providers.dart';|import 'package:service_sentinel_fe_v2/features/dashboard/di/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(features/dashboard): replace deep imports with barrel files in dashboard_provider"

# ── Step 4.8 ────────────────────────────────────────────────────────────────
# fe/lib/features/dashboard/presentation/screens/dashboard_screen.dart
FILE="fe/lib/features/dashboard/presentation/screens/dashboard_screen.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';|import 'package:service_sentinel_fe_v2/features/dashboard/domain/public.dart';|" "$FILE"
sed -i "s|import '../../../../core/auth/application/providers/auth_provider.dart';|import 'package:service_sentinel_fe_v2/core/auth/application/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(features/dashboard): replace deep imports with barrel files in dashboard_screen"

# ---------------------------------------------------------------------------
# Group 5 — features/project
# ---------------------------------------------------------------------------

# ── Step 5.1 ────────────────────────────────────────────────────────────────
# fe/lib/features/project/data/repositories/project_repository_impl.dart
FILE="fe/lib/features/project/data/repositories/project_repository_impl.dart"
sed -i "s|import 'package:service_sentinel_fe_v2/features/project/domain/entities/project_health.dart';|import 'package:service_sentinel_fe_v2/features/project/domain/public.dart';|" "$FILE"
git add "$FILE"
git commit -m "refactor(features/project): replace deep imports with barrel files in project_repository_impl"

# ---------------------------------------------------------------------------
# Final verification (informational — not committed)
# ---------------------------------------------------------------------------
echo ""
echo "All refactoring steps complete. Run the following to verify:"
echo "  cd fe"
echo "  flutter analyze"
echo "  flutter pub run build_runner build --delete-conflicting-outputs"
echo "  flutter test"
echo "  grep -r \"import 'package:service_sentinel_fe_v2/.*/(entities|repositories|usecases|data_sources|models|providers|screens|widgets|view_models|states)/\" lib/ | grep -v public.dart | grep -v '.g.dart' | grep -v '.freezed.'"
