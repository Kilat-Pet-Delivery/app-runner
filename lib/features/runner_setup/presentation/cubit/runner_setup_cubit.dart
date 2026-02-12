import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/runner_profile_model.dart';
import '../../domain/repositories/runner_setup_repository.dart';

// States
abstract class RunnerSetupState extends Equatable {
  const RunnerSetupState();
  @override
  List<Object?> get props => [];
}

class RunnerSetupInitial extends RunnerSetupState {}

class RunnerSetupLoading extends RunnerSetupState {}

class RunnerSetupCheckingProfile extends RunnerSetupState {}

class RunnerSetupNeeded extends RunnerSetupState {}

class RunnerSetupAlreadyComplete extends RunnerSetupState {
  final RunnerProfileModel profile;
  const RunnerSetupAlreadyComplete(this.profile);
  @override
  List<Object?> get props => [profile.id];
}

class RunnerSetupSuccess extends RunnerSetupState {
  final RunnerProfileModel profile;
  const RunnerSetupSuccess(this.profile);
  @override
  List<Object?> get props => [profile.id];
}

class RunnerSetupError extends RunnerSetupState {
  final String message;
  const RunnerSetupError(this.message);
  @override
  List<Object?> get props => [message];
}

class CrateSpecAdded extends RunnerSetupState {
  final CrateSpecModel crate;
  const CrateSpecAdded(this.crate);
  @override
  List<Object?> get props => [crate.id];
}

// Cubit
class RunnerSetupCubit extends Cubit<RunnerSetupState> {
  final RunnerSetupRepository _repository;

  RunnerSetupCubit(this._repository) : super(RunnerSetupInitial());

  Future<void> checkProfile() async {
    emit(RunnerSetupCheckingProfile());
    try {
      final profile = await _repository.getMyProfile();
      emit(RunnerSetupAlreadyComplete(profile));
    } catch (_) {
      emit(RunnerSetupNeeded());
    }
  }

  Future<void> registerRunner({
    required String fullName,
    required String phone,
    required String vehicleType,
    required String vehiclePlate,
    required String vehicleModel,
    required int vehicleYear,
    required bool airConditioned,
  }) async {
    emit(RunnerSetupLoading());
    try {
      final profile = await _repository.registerRunner(
        fullName: fullName,
        phone: phone,
        vehicleType: vehicleType,
        vehiclePlate: vehiclePlate,
        vehicleModel: vehicleModel,
        vehicleYear: vehicleYear,
        airConditioned: airConditioned,
      );
      emit(RunnerSetupSuccess(profile));
    } catch (e) {
      emit(RunnerSetupError(e.toString()));
    }
  }

  Future<void> addCrateSpec({
    required String size,
    required List<String> petTypes,
    required double maxWeightKg,
    required bool ventilated,
    required bool temperatureControlled,
  }) async {
    emit(RunnerSetupLoading());
    try {
      final crate = await _repository.addCrateSpec(
        size: size,
        petTypes: petTypes,
        maxWeightKg: maxWeightKg,
        ventilated: ventilated,
        temperatureControlled: temperatureControlled,
      );
      emit(CrateSpecAdded(crate));
    } catch (e) {
      emit(RunnerSetupError(e.toString()));
    }
  }
}
