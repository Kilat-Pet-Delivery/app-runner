import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../runner_setup/data/models/runner_profile_model.dart';
import '../../../runner_setup/domain/repositories/runner_setup_repository.dart';
import '../../../jobs/domain/repositories/job_repository.dart';
import '../../../booking/data/models/booking_model.dart';

// States
abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final RunnerProfileModel profile;
  final List<BookingModel> availableJobs;
  final BookingModel? activeJob;

  const DashboardLoaded({
    required this.profile,
    required this.availableJobs,
    this.activeJob,
  });

  @override
  List<Object?> get props => [profile.id, availableJobs.length, activeJob?.id];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

class DashboardTogglingStatus extends DashboardState {}

// Cubit
class DashboardCubit extends Cubit<DashboardState> {
  final RunnerSetupRepository _runnerRepo;
  final JobRepository _jobRepo;

  DashboardCubit(this._runnerRepo, this._jobRepo) : super(DashboardInitial());

  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    try {
      final profile = await _runnerRepo.getMyProfile();

      List<BookingModel> availableJobs = [];
      BookingModel? activeJob;

      if (profile.isOnline) {
        try {
          availableJobs = await _jobRepo.getAvailableJobs();
        } catch (_) {}
      }

      // Check for active job (accepted or in_transit)
      try {
        final myJobs = await _jobRepo.getMyJobs();
        activeJob = myJobs
            .where((b) =>
                b.status == 'accepted' || b.status == 'in_transit')
            .firstOrNull;
      } catch (_) {}

      emit(DashboardLoaded(
        profile: profile,
        availableJobs: availableJobs,
        activeJob: activeJob,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> toggleOnlineStatus(bool goOnline,
      {double? lat, double? lng}) async {
    final currentState = state;
    emit(DashboardTogglingStatus());
    try {
      if (goOnline) {
        await _runnerRepo.goOnline(
          lat ?? 3.1390,
          lng ?? 101.6869,
        );
      } else {
        await _runnerRepo.goOffline();
      }
      await loadDashboard();
    } catch (e) {
      if (currentState is DashboardLoaded) {
        emit(currentState);
      }
      emit(DashboardError(e.toString()));
    }
  }
}
