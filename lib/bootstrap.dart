import 'package:get_it/get_it.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'core/websocket/ws_manager.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/runner_setup/data/repositories/runner_setup_repository_impl.dart';
import 'features/runner_setup/domain/repositories/runner_setup_repository.dart';
import 'features/runner_setup/presentation/cubit/runner_setup_cubit.dart';

import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';

import 'features/jobs/data/repositories/job_repository_impl.dart';
import 'features/jobs/domain/repositories/job_repository.dart';
import 'features/jobs/presentation/cubit/job_list_cubit.dart';
import 'features/jobs/presentation/cubit/job_detail_cubit.dart';

import 'features/active_delivery/presentation/bloc/active_delivery_bloc.dart';
import 'features/active_delivery/services/location_service.dart';

import 'features/earnings/data/repositories/earnings_repository_impl.dart';
import 'features/earnings/domain/repositories/earnings_repository.dart';
import 'features/earnings/presentation/cubit/earnings_cubit.dart';

import 'features/profile/presentation/cubit/profile_cubit.dart';

import 'features/notification/data/repositories/notification_repository_impl.dart';
import 'features/notification/domain/repositories/notification_repository.dart';
import 'features/notification/presentation/cubit/notification_cubit.dart';
import 'features/notification/presentation/cubit/notification_preferences_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Config
  getIt.registerSingleton<AppConfig>(AppConfig.dev());

  // Storage
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // Network
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(storage: getIt(), config: getIt()),
  );
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(config: getIt(), authInterceptor: getIt()),
  );
  getIt.registerLazySingleton<WebSocketManager>(
    () => WebSocketManager(storage: getIt(), config: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<RunnerSetupRepository>(
    () => RunnerSetupRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<EarningsRepository>(
    () => EarningsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt()),
  );

  // Services
  getIt.registerLazySingleton<LocationService>(
    () => LocationService(getIt()),
  );

  // Blocs & Cubits
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: getIt(), storage: getIt()),
  );

  getIt.registerFactory<RunnerSetupCubit>(
    () => RunnerSetupCubit(getIt()),
  );
  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(getIt(), getIt()),
  );
  getIt.registerFactory<JobListCubit>(
    () => JobListCubit(getIt()),
  );
  getIt.registerFactory<JobDetailCubit>(
    () => JobDetailCubit(getIt()),
  );
  getIt.registerFactory<ActiveDeliveryBloc>(
    () => ActiveDeliveryBloc(getIt(), getIt()),
  );
  getIt.registerFactory<EarningsCubit>(
    () => EarningsCubit(getIt()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt(), getIt()),
  );
  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(getIt()),
  );
  getIt.registerFactory<NotificationPreferencesCubit>(
    () => NotificationPreferencesCubit(getIt()),
  );

  // Router
  getIt.registerLazySingleton<AppRouter>(
    () => AppRouter(getIt()),
  );
}
