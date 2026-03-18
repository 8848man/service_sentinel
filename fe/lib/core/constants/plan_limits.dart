const Map<String, Map<String, int>> planLimits = {
  'free': {'maxProjects': 3,  'maxServices': 10},
  'pro':  {'maxProjects': 10, 'maxServices': 20},
  'max':  {'maxProjects': 10, 'maxServices': 50},
};

const String fallbackPlan = 'free';

Map<String, int> getLimitsForPlan(String plan) {
  return planLimits[plan] ?? planLimits[fallbackPlan]!;
}
