import 'package:go_router/go_router.dart';
import 'package:it_helpdesk_client/features/auth/auth_controller.dart';
import 'package:it_helpdesk_client/features/auth/login_screen.dart';
import 'package:it_helpdesk_client/features/auth/register_screen.dart';
import 'package:it_helpdesk_client/features/cases/case_create_screen.dart';
import 'package:it_helpdesk_client/features/cases/case_detail_screen.dart';
import 'package:it_helpdesk_client/features/cases/case_list_screen.dart';
import 'package:it_helpdesk_client/features/dashboard/dashboard_screen.dart';
import 'package:it_helpdesk_client/features/knowledge/knowledge_screen.dart';
import 'package:it_helpdesk_client/features/reports/reports_screen.dart';
import 'package:it_helpdesk_client/shared/widgets/responsive_layout.dart';

GoRouter createRouter(AuthController authController) {
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: authController,
    redirect: (context, state) {
      final isLoggedIn = authController.isAuthenticated;
      final isAuthRoute = state.uri.path == '/login' || state.uri.path == '/register';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      // Unauthenticated Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Authenticated Shell Routes with Responsive Layout
      ShellRoute(
        builder: (context, state, child) {
          int index = 0;
          if (state.uri.path.startsWith('/cases')) index = 1;
          if (state.uri.path.startsWith('/knowledge')) index = 2;
          if (state.uri.path.startsWith('/reports')) index = 3;

          return ResponsiveLayout(
            currentIndex: index,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/cases',
            builder: (context, state) => const CaseListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CaseCreateScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final caseId = state.pathParameters['id']!;
                  return CaseDetailScreen(caseId: caseId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/knowledge',
            builder: (context, state) => const KnowledgeScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
    ],
  );
}
