import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_sentinel_fe_v2/core/di/providers.dart';
import 'package:service_sentinel_fe_v2/core/state/project_session_notifier.dart';
import '../../features/analysis/presentation/screens/analysis_overview_screen.dart';
import '../../features/api_monitoring/presentation/screens/service_detail_screen.dart';
import '../../features/api_monitoring/presentation/screens/services_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/incident/presentation/screens/ai_analysis_screen.dart';
import '../../features/incident/presentation/screens/incident_detail_screen.dart';
import '../../features/incident/presentation/screens/incidents_screen.dart';
import '../../features/project/presentation/screens/project_detail_screen.dart';
import '../../features/project/presentation/screens/project_selection_screen.dart';
import '../settings/presentation/screens/settings_screen.dart';
import '../navigation/main_scaffold.dart';

/// Route names
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String projectSelection = '/project-selection';
  static const String projectDetail = '/project/:id';
  static const String main = '/main';
  static const String dashboard = '/main/dashboard';
  static const String services = '/main/services';
  static const String serviceDetail = '/service/:id';
  static const String incidents = '/main/incidents';
  static const String incidentDetail = '/incident/:id';
  // static const String aiAnalysis = '/incident/:id/analysis';
  static const String analysis = '/main/analysis';
  static const String settings = '/main/settings';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final projectId = ref.read(projectSessionProvider).projectId;
      final firebaseAuth = ref.read(firebaseAuthProvider);
      final user = firebaseAuth.currentUser;
      final isInMainShell = location.startsWith('/main');

      // 프로젝트가 없는데 프로젝트 main 페이지로 진입시 프로젝트 선택 페이지로
      if (isInMainShell && projectId == null) {
        return AppRoutes.projectSelection;
      }

      // 로그인 되어있을 때, login 페이지 진입시 프로젝트 선택 페이지로 이동
      final isInLoginShell = location.startsWith('/login');

      if (isInLoginShell && user != null) {
        return AppRoutes.projectSelection; // 이미 로그인되어 있으면 메인으로 보내기
      }
      return null;
    },
    routes: [
      // Splash Screen - Initial loading and auth resolution
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Project Selection
      GoRoute(
        path: AppRoutes.projectSelection,
        builder: (context, state) => const ProjectSelectionScreen(),
      ),

      // Project Detail
      GoRoute(
        path: AppRoutes.projectDetail,
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return ProjectDetailScreen(projectId: projectId);
        },
      ),

      // Service Detail
      GoRoute(
        path: AppRoutes.serviceDetail,
        builder: (context, state) {
          final serviceId = state.pathParameters['id']!;
          return ServiceDetailScreen(serviceId: serviceId);
        },
      ),

      // Incident Detail
      GoRoute(
        path: AppRoutes.incidentDetail,
        builder: (context, state) {
          final incidentId = state.pathParameters['id']!;
          return IncidentDetailScreen(incidentId: incidentId);
        },
      ),

      // AI Analysis Detail
      GoRoute(
        path: '/incident/:id/analysis',
        builder: (context, state) {
          final incidentId = state.pathParameters['id']!;
          return AiAnalysisScreen(incidentId: incidentId);
        },
      ),

      // Main App with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          ref.read(projectSessionProvider).projectId == null
              ? Future.microtask(() {
                  context.go(AppRoutes.projectSelection);
                })
              : null;
          return MainScaffold(child: child);
        },
        routes: [
          // Dashboard - Overview
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),

          // Services - API monitoring list
          GoRoute(
            path: AppRoutes.services,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ServicesScreen(),
            ),
          ),

          // Incidents - Incident list and management
          GoRoute(
            path: AppRoutes.incidents,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const IncidentsScreen(),
            ),
          ),

          // AI Analysis - Overview of AI analyses
          GoRoute(
            path: AppRoutes.analysis,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AnalysisOverviewScreen(),
            ),
          ),

          // Settings - App settings and preferences
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.path,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );
});
