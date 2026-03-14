#!/usr/bin/env bash
# Frontend Refactoring — Git Commit Script
# Run AFTER completing each step described in fe_refactor.md.
# Each section stages the affected files and commits with a conventional message.
# DO NOT run this script top-to-bottom automatically — execute one block at a time.

set -e

# ---------------------------------------------------------------------------
# Step 1: Rename api_monitoring infrastructure/ → data/
# ---------------------------------------------------------------------------
step1_commit() {
  git add fe/lib/features/api_monitoring/data/
  git rm -r --cached fe/lib/features/api_monitoring/infrastructure/ 2>/dev/null || true
  git add fe/lib/core/di/repository_providers.dart
  git commit -m "refactor(api_monitoring): rename infrastructure/ to data/"
}

# ---------------------------------------------------------------------------
# Step 2: Rename dashboard infrastructure/ → data/
# ---------------------------------------------------------------------------
step2_commit() {
  git add fe/lib/features/dashboard/data/
  git rm -r --cached fe/lib/features/dashboard/infrastructure/ 2>/dev/null || true
  git add fe/lib/core/di/repository_providers.dart
  git commit -m "refactor(dashboard): rename infrastructure/ to data/"
}

# ---------------------------------------------------------------------------
# Step 3: Rename incident infrastructure/ → data/
# ---------------------------------------------------------------------------
step3_commit() {
  git add fe/lib/features/incident/data/
  git rm -r --cached fe/lib/features/incident/infrastructure/ 2>/dev/null || true
  git add fe/lib/core/di/repository_providers.dart
  git commit -m "refactor(incident): rename infrastructure/ to data/"
}

# ---------------------------------------------------------------------------
# Step 4: Rename project infrastructure/ → data/
# ---------------------------------------------------------------------------
step4_commit() {
  git add fe/lib/features/project/data/
  git rm -r --cached fe/lib/features/project/infrastructure/ 2>/dev/null || true
  git add fe/lib/core/di/repository_providers.dart
  git commit -m "refactor(project): rename infrastructure/ to data/"
}

# ---------------------------------------------------------------------------
# Step 5: Move api_monitoring use_cases → domain/usecases/
# ---------------------------------------------------------------------------
step5_commit() {
  git add fe/lib/features/api_monitoring/domain/usecases/
  git rm -r --cached fe/lib/features/api_monitoring/application/use_cases/ 2>/dev/null || true
  git add fe/lib/features/api_monitoring/application/providers/service_provider.dart
  git commit -m "refactor(api_monitoring): move use_cases into domain/usecases/"
}

# ---------------------------------------------------------------------------
# Step 6: Move dashboard use_cases → domain/usecases/
# ---------------------------------------------------------------------------
step6_commit() {
  git add fe/lib/features/dashboard/domain/usecases/
  git rm -r --cached fe/lib/features/dashboard/application/use_cases/ 2>/dev/null || true
  git add fe/lib/features/dashboard/application/providers/dashboard_provider.dart
  git commit -m "refactor(dashboard): move use_cases into domain/usecases/"
}

# ---------------------------------------------------------------------------
# Step 7: Move incident use_cases → domain/usecases/
# ---------------------------------------------------------------------------
step7_commit() {
  git add fe/lib/features/incident/domain/usecases/
  git rm -r --cached fe/lib/features/incident/application/use_cases/ 2>/dev/null || true
  git add fe/lib/features/incident/application/providers/incident_provider.dart
  git commit -m "refactor(incident): move use_cases into domain/usecases/"
}

# ---------------------------------------------------------------------------
# Step 8: Move project use_cases → domain/usecases/
# ---------------------------------------------------------------------------
step8_commit() {
  git add fe/lib/features/project/domain/usecases/
  git rm -r --cached fe/lib/features/project/application/use_cases/ 2>/dev/null || true
  git add fe/lib/features/project/application/providers/bootstrap_provider.dart
  git add fe/lib/features/project/application/providers/project_provider.dart
  git add fe/lib/features/project/application/providers/project_health_provider.dart
  git commit -m "refactor(project): move use_cases into domain/usecases/"
}

# ---------------------------------------------------------------------------
# Step 9: Move api_monitoring application/providers/ → presentation/providers/
# ---------------------------------------------------------------------------
step9_commit() {
  git add fe/lib/features/api_monitoring/presentation/providers/
  git rm -r --cached fe/lib/features/api_monitoring/application/ 2>/dev/null || true
  # Stage any presentation files whose imports were updated
  git add fe/lib/features/api_monitoring/presentation/
  git commit -m "refactor(api_monitoring): move providers to presentation/providers/"
}

# ---------------------------------------------------------------------------
# Step 10: Move dashboard application/providers/ → presentation/providers/
# ---------------------------------------------------------------------------
step10_commit() {
  git add fe/lib/features/dashboard/presentation/providers/
  git rm -r --cached fe/lib/features/dashboard/application/ 2>/dev/null || true
  git add fe/lib/features/dashboard/presentation/
  git commit -m "refactor(dashboard): move providers to presentation/providers/"
}

# ---------------------------------------------------------------------------
# Step 11: Move incident application/providers/ → presentation/providers/
# ---------------------------------------------------------------------------
step11_commit() {
  git add fe/lib/features/incident/presentation/providers/
  git rm -r --cached fe/lib/features/incident/application/ 2>/dev/null || true
  git add fe/lib/features/incident/presentation/
  git commit -m "refactor(incident): move providers to presentation/providers/"
}

# ---------------------------------------------------------------------------
# Step 12: Move project application/providers/ → presentation/providers/
# ---------------------------------------------------------------------------
step12_commit() {
  git add fe/lib/features/project/presentation/providers/
  git rm -r --cached fe/lib/features/project/application/ 2>/dev/null || true
  git add fe/lib/features/project/presentation/
  git commit -m "refactor(project): move providers to presentation/providers/"
}

# ---------------------------------------------------------------------------
# Step 13: Move auth presentation/dialogs/ → presentation/widgets/
# ---------------------------------------------------------------------------
step13_commit() {
  git add fe/lib/features/auth/presentation/widgets/sign_up_dialog.dart
  git rm --cached fe/lib/features/auth/presentation/dialogs/sign_up_dialog.dart 2>/dev/null || true
  # Stage any screens whose imports were updated
  git add fe/lib/features/auth/presentation/screens/
  git commit -m "refactor(auth): move sign_up_dialog from dialogs/ to widgets/"
}

# ---------------------------------------------------------------------------
# Step 14: Create api_monitoring/di/ and extract serviceRepositoryProvider
# ---------------------------------------------------------------------------
step14_commit() {
  git add fe/lib/features/api_monitoring/di/repository_providers.dart
  git add fe/lib/core/di/repository_providers.dart
  git add fe/lib/features/api_monitoring/presentation/providers/service_provider.dart
  git commit -m "refactor(api_monitoring): extract serviceRepositoryProvider into feature di/"
}

# ---------------------------------------------------------------------------
# Step 15: Create dashboard/di/ and extract dashboard repository providers
# ---------------------------------------------------------------------------
step15_commit() {
  git add fe/lib/features/dashboard/di/repository_providers.dart
  git add fe/lib/core/di/repository_providers.dart
  git add fe/lib/features/dashboard/presentation/providers/dashboard_provider.dart
  git commit -m "refactor(dashboard): extract dashboard repository providers into feature di/"
}

# ---------------------------------------------------------------------------
# Step 16: Create incident/di/ and extract incidentRepositoryProvider
# ---------------------------------------------------------------------------
step16_commit() {
  git add fe/lib/features/incident/di/repository_providers.dart
  git add fe/lib/core/di/repository_providers.dart
  git add fe/lib/features/incident/presentation/providers/incident_provider.dart
  git commit -m "refactor(incident): extract incidentRepositoryProvider into feature di/"
}

# ---------------------------------------------------------------------------
# Step 17: Create project/di/ and extract project repository providers
# ---------------------------------------------------------------------------
step17_commit() {
  git add fe/lib/features/project/di/repository_providers.dart
  git add fe/lib/core/di/repository_providers.dart
  git add fe/lib/features/project/presentation/providers/bootstrap_provider.dart
  git add fe/lib/features/project/presentation/providers/project_provider.dart
  git add fe/lib/features/project/presentation/providers/project_health_provider.dart
  git commit -m "refactor(project): extract project repository providers into feature di/"
}

# ---------------------------------------------------------------------------
# Step 18: Move authRepositoryProvider to core/auth/di/ and delete core/di/repository_providers.dart
# ---------------------------------------------------------------------------
step18_commit() {
  git add fe/lib/core/auth/di/repository_providers.dart
  git rm --cached fe/lib/core/di/repository_providers.dart 2>/dev/null || true
  # Stage any files whose authRepositoryProvider import was updated
  git add fe/lib/core/
  git commit -m "refactor(core/auth): move authRepositoryProvider to core/auth/di/ and remove core/di/repository_providers.dart"
}

# ---------------------------------------------------------------------------
# Step 19: Remove orphan api_monitoring/domain/repositories/dashboard_repository.dart
# ---------------------------------------------------------------------------
step19_commit() {
  git rm fe/lib/features/api_monitoring/domain/repositories/dashboard_repository.dart
  git commit -m "refactor(api_monitoring): remove orphan dashboard_repository interface from api_monitoring domain"
}

# ---------------------------------------------------------------------------
# Step 20: Add public.dart barrel files to all layers
# ---------------------------------------------------------------------------
step20_commit() {
  git add fe/lib/core/auth/domain/public.dart
  git add fe/lib/core/auth/data/public.dart
  git add fe/lib/core/auth/di/public.dart
  git add fe/lib/core/auth/application/public.dart
  git add fe/lib/features/api_monitoring/domain/public.dart
  git add fe/lib/features/api_monitoring/data/public.dart
  git add fe/lib/features/api_monitoring/di/public.dart
  git add fe/lib/features/api_monitoring/presentation/public.dart
  git add fe/lib/features/dashboard/domain/public.dart
  git add fe/lib/features/dashboard/data/public.dart
  git add fe/lib/features/dashboard/di/public.dart
  git add fe/lib/features/dashboard/presentation/public.dart
  git add fe/lib/features/incident/domain/public.dart
  git add fe/lib/features/incident/data/public.dart
  git add fe/lib/features/incident/di/public.dart
  git add fe/lib/features/incident/presentation/public.dart
  git add fe/lib/features/project/domain/public.dart
  git add fe/lib/features/project/data/public.dart
  git add fe/lib/features/project/di/public.dart
  git add fe/lib/features/project/presentation/public.dart
  git add fe/lib/features/auth/presentation/public.dart
  git commit -m "refactor: add public.dart barrel files to all feature and core layers"
}

# ---------------------------------------------------------------------------
# Step 21: Remove duplicate widget files
# ---------------------------------------------------------------------------
step21_commit() {
  # Replace <orphan_file> with the actual file(s) identified in Step 21 investigation
  # Example:
  # git rm fe/lib/features/api_monitoring/presentation/widgets/<orphan_file>.dart
  # git rm fe/lib/features/project/presentation/widgets/<orphan_file>.dart
  git commit -m "refactor: remove duplicate dialog widget files in api_monitoring and project"
}
