#!/usr/bin/env bash
# Backend refactoring git commits
# Run from D:/projects/service_sentinel/be/ (or adjust BE_DIR below)
# Each block corresponds to one step in be_refactor.md.
# Assumes the developer has already applied the source changes for that step.

set -e

BE_DIR="D:/projects/service_sentinel/be"

# ---------------------------------------------------------------------------
# Step 1 — Remove v1/v2 legacy files and router registrations
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git rm app/api/dashboard.py \
         app/api/dashboard_v2.py \
         app/api/incidents.py \
         app/api/incidents_v2.py \
         app/api/projects.py \
         app/api/services.py \
         app/api/services_v2.py && \
  git add app/main.py && \
  git commit -m "$(cat <<'EOF'
refactor(api): remove v1/v2 legacy routers and their registrations in main.py

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 2 — Move scheduler.py into services/monitoring/
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git mv app/scheduler.py app/services/monitoring/scheduler.py && \
  git add app/main.py && \
  git commit -m "$(cat <<'EOF'
refactor(services/monitoring): move scheduler.py from app root into services/monitoring/

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 3.1 — Move module-level core/notification files
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git mv app/core/notification/context.py     app/services/notification/context.py && \
  git mv app/core/notification/decision.py    app/services/notification/decision.py && \
  git mv app/core/notification/enum.py        app/services/notification/enum.py && \
  git mv app/core/notification/policy_chain.py app/services/notification/policy_chain.py && \
  git commit -m "$(cat <<'EOF'
refactor(core/notification): move context, decision, enum, policy_chain to services/notification/

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 3.2 — Move policies/ subtree
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git mv app/core/notification/policies/__init__.py  app/services/notification/policies/__init__.py && \
  git mv app/core/notification/policies/base.py      app/services/notification/policies/base.py && \
  git mv app/core/notification/policies/chain.py     app/services/notification/policies/chain.py && \
  git mv app/core/notification/policies/incident.py  app/services/notification/policies/incident.py && \
  git mv app/core/notification/policies/project.py   app/services/notification/policies/project.py && \
  git mv app/core/notification/policies/service.py   app/services/notification/policies/service.py && \
  git mv app/core/notification/policies/user_plan.py app/services/notification/policies/user_plan.py && \
  git commit -m "$(cat <<'EOF'
refactor(core/notification): move policies/ subtree to services/notification/policies/

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 3.3 — Move rules/ subtree
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git mv app/core/notification/rules/__init__.py  app/services/notification/rules/__init__.py && \
  git mv app/core/notification/rules/evaluator.py app/services/notification/rules/evaluator.py && \
  git mv app/core/notification/rules/parser.py    app/services/notification/rules/parser.py && \
  git mv app/core/notification/rules/rule.py      app/services/notification/rules/rule.py && \
  git commit -m "$(cat <<'EOF'
refactor(core/notification): move rules/ subtree to services/notification/rules/

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 3.4 — Update imports inside moved policy files
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git add \
    app/services/notification/policies/base.py \
    app/services/notification/policies/chain.py \
    app/services/notification/policies/project.py \
    app/services/notification/policies/service.py && \
  git commit -m "$(cat <<'EOF'
refactor(services/notification): update internal imports in moved policy files to app.services.notification

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 3.5 — Update imports in existing callers
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git add \
    app/services/notification/context_factory.py \
    app/services/notification/usecase.py \
    app/services/notification/senders/base.py \
    app/services/notification/senders/firebase_sender.py \
    app/services/notification/senders/log.py \
    app/services/incident_service.py \
    app/services/monitoring/monitoring_worker.py \
    app/main_notification_test.py && \
  git commit -m "$(cat <<'EOF'
refactor(services): replace app.core.notification imports with app.services.notification across callers

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 3.6 — Delete core/notification/ directory
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git rm app/core/notification/__init__.py && \
  git commit -m "$(cat <<'EOF'
refactor(core): delete core/notification/ after full migration to services/notification/

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 4.1 — Rename auth_context.py → auth_context_schema.py
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git mv app/schemas/auth_context.py app/schemas/auth_context_schema.py && \
  git add \
    app/core/auth_v3.py \
    app/api/v3/dashboard.py \
    app/api/v3/incidents.py \
    app/api/v3/projects.py \
    app/api/v3/services.py && \
  git commit -m "$(cat <<'EOF'
refactor(schemas): rename auth_context.py to auth_context_schema.py and update all callers

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 4.2 — Rename device_token.py → device_token_schema.py
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git mv app/schemas/device_token.py app/schemas/device_token_schema.py && \
  git add app/api/v3/device_token.py && \
  git commit -m "$(cat <<'EOF'
refactor(schemas): rename device_token.py to device_token_schema.py and update caller

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 4.3 — Rename common.py → common_schema.py
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git mv app/schemas/common.py app/schemas/common_schema.py && \
  git commit -m "$(cat <<'EOF'
refactor(schemas): rename common.py to common_schema.py

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 5.1 — Remove HealthCheckCreate schema import from health_check_repository
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git add app/repositories/health_check_repository.py && \
  git commit -m "$(cat <<'EOF'
refactor(repositories): remove HealthCheckCreate schema import from health_check_repository

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 5.2 — Remove IncidentCreate schema import from incident_repository
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git add app/repositories/incident_repository.py && \
  git commit -m "$(cat <<'EOF'
refactor(repositories): remove IncidentCreate schema import from incident_repository

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 5.3 — Remove ServiceCreate/ServiceUpdate schema imports from service_repository
#            Update callers in services/ and api/ to pass dict
# ---------------------------------------------------------------------------

cd "$BE_DIR" && \
  git add app/repositories/service_repository.py && \
  git commit -m "$(cat <<'EOF'
refactor(repositories): remove ServiceCreate/ServiceUpdate schema imports from service_repository

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# Step 5.3b — Update callers (services and routers that pass ServiceCreate/ServiceUpdate)
# Run: grep -r "service_repo\.create\|service_repo\.update\|ServiceRepository" app/services app/api
# to find all call sites, update each to pass model_dump(), then:
cd "$BE_DIR" && \
  git add app/services/ app/api/ && \
  git commit -m "$(cat <<'EOF'
refactor(services/api): update service_repository callers to pass dict instead of schema objects

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# ---------------------------------------------------------------------------
# Step 5.4 — Move ProjectHealth to models layer; update repository import
# ---------------------------------------------------------------------------

# 5.4a: Add ProjectHealth to app/models/project.py and update schema re-export
cd "$BE_DIR" && \
  git add app/models/project.py app/schemas/project_schema.py && \
  git commit -m "$(cat <<'EOF'
refactor(models): move ProjectHealth definition to models/project.py; re-export from schema

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# 5.4b: Update project_repository to import ProjectHealth from models
cd "$BE_DIR" && \
  git add app/repositories/project_repository.py && \
  git commit -m "$(cat <<'EOF'
refactor(repositories): replace schema import of ProjectHealth with models import in project_repository

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
