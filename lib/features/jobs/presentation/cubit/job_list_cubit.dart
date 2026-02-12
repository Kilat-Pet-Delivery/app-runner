import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../domain/repositories/job_repository.dart';

// States
abstract class JobListState extends Equatable {
  const JobListState();
  @override
  List<Object?> get props => [];
}

class JobListInitial extends JobListState {}

class JobListLoading extends JobListState {}

class JobListLoaded extends JobListState {
  final List<BookingModel> availableJobs;
  final List<BookingModel> myJobs;

  const JobListLoaded({
    required this.availableJobs,
    required this.myJobs,
  });

  @override
  List<Object?> get props => [availableJobs.length, myJobs.length];
}

class JobListError extends JobListState {
  final String message;
  const JobListError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class JobListCubit extends Cubit<JobListState> {
  final JobRepository _repository;

  JobListCubit(this._repository) : super(JobListInitial());

  Future<void> loadJobs() async {
    emit(JobListLoading());
    try {
      final available = await _repository.getAvailableJobs();
      final myJobs = await _repository.getMyJobs();
      emit(JobListLoaded(availableJobs: available, myJobs: myJobs));
    } catch (e) {
      emit(JobListError(e.toString()));
    }
  }
}
