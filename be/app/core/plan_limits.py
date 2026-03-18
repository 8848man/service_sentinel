PLAN_LIMITS: dict[str, dict[str, int]] = {
    "free": {"max_projects": 3,  "max_services": 10},
    "pro":  {"max_projects": 10, "max_services": 20},
    "max":  {"max_projects": 10, "max_services": 50},
}

FALLBACK_PLAN = "free"


def get_limits(plan: str) -> dict[str, int]:
    """Return limits for a plan, falling back to free if unknown."""
    return PLAN_LIMITS.get(plan, PLAN_LIMITS[FALLBACK_PLAN])
