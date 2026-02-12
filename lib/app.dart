import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bootstrap.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/jobs/presentation/cubit/job_list_cubit.dart';
import 'features/earnings/presentation/cubit/earnings_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/notification/presentation/cubit/notification_cubit.dart';
import 'features/notification/presentation/cubit/notification_preferences_cubit.dart';

class KilatRunnerApp extends StatelessWidget {
  const KilatRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<DashboardCubit>()),
        BlocProvider(create: (_) => getIt<JobListCubit>()),
        BlocProvider(create: (_) => getIt<EarningsCubit>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
        BlocProvider(create: (_) => getIt<NotificationCubit>()),
        BlocProvider(create: (_) => getIt<NotificationPreferencesCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Kilat Runner',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter.router,
      ),
    );
  }
}
