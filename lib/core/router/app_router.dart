import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

import '../../features/runner_setup/presentation/cubit/runner_setup_cubit.dart';
import '../../features/runner_setup/presentation/screens/runner_setup_screen.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

import '../../features/jobs/presentation/cubit/job_detail_cubit.dart';
import '../../features/jobs/presentation/screens/job_list_screen.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';

import '../../features/active_delivery/presentation/bloc/active_delivery_bloc.dart';
import '../../features/active_delivery/presentation/screens/active_delivery_screen.dart';

import '../../features/earnings/presentation/screens/earnings_screen.dart';

import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

import '../../features/notification/presentation/cubit/notification_cubit.dart';
import '../../features/notification/presentation/screens/notification_list_screen.dart';
import '../../features/notification/presentation/screens/notification_preferences_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/runner-setup',
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.instance<RunnerSetupCubit>(),
          child: const RunnerSetupScreen(),
        ),
      ),
      ShellRoute(
        builder: (_, __, child) => _AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/jobs',
            builder: (_, __) => const JobListScreen(),
          ),
          GoRoute(
            path: '/earnings',
            builder: (_, __) => const EarningsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/jobs/:id',
        builder: (_, state) => BlocProvider(
          create: (_) => GetIt.instance<JobDetailCubit>(),
          child: JobDetailScreen(
            jobId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/jobs/:id/active',
        builder: (_, state) => BlocProvider(
          create: (_) => GetIt.instance<ActiveDeliveryBloc>(),
          child: ActiveDeliveryScreen(
            bookingId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationListScreen(),
      ),
      GoRoute(
        path: '/notifications/settings',
        builder: (_, __) => const NotificationPreferencesScreen(),
      ),
    ],
  );
}

class _AppScaffold extends StatelessWidget {
  final Widget child;
  const _AppScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, notifState) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _calculateIndex(context),
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                case 1:
                  context.go('/jobs');
                case 2:
                  context.go('/earnings');
                case 3:
                  context.go('/profile');
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work),
                label: 'Jobs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Earnings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/jobs')) return 1;
    if (location.startsWith('/earnings')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }
}

/// Converts a Bloc stream into a Listenable for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}
