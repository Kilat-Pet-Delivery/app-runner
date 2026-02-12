import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../domain/repositories/job_repository.dart';

// States
abstract class JobDetailState extends Equatable {
  const JobDetailState();
  @override
  List<Object?> get props => [];
}

class JobDetailInitial extends JobDetailState {}

class JobDetailLoading extends JobDetailState {}

class JobDetailLoaded extends JobDetailState {
  final BookingModel booking;
  const JobDetailLoaded(this.booking);
  @override
  List<Object?> get props => [booking.id, booking.status];
}

class JobDetailActionLoading extends JobDetailState {}

class JobDetailError extends JobDetailState {
  final String message;
  const JobDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class JobDetailCubit extends Cubit<JobDetailState> {
  final JobRepository _repository;

  JobDetailCubit(this._repository) : super(JobDetailInitial());

  Future<void> loadJob(String id) async {
    emit(JobDetailLoading());
    try {
      final booking = await _repository.getJob(id);
      emit(JobDetailLoaded(booking));
    } catch (e) {
      emit(JobDetailError(e.toString()));
    }
  }

  Future<void> acceptJob(String id) async {
    emit(JobDetailActionLoading());
    try {
      final booking = await _repository.acceptJob(id);
      emit(JobDetailLoaded(booking));
    } catch (e) {
      emit(JobDetailError(e.toString()));
    }
  }

  Future<void> pickupJob(String id) async {
    emit(JobDetailActionLoading());
    try {
      final booking = await _repository.pickupJob(id);
      emit(JobDetailLoaded(booking));
    } catch (e) {
      emit(JobDetailError(e.toString()));
    }
  }

  Future<void> deliverJob(String id) async {
    emit(JobDetailActionLoading());
    try {
      final booking = await _repository.deliverJob(id);
      emit(JobDetailLoaded(booking));
    } catch (e) {
      emit(JobDetailError(e.toString()));
    }
  }
}
