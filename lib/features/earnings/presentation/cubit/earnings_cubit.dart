import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/earning_model.dart';
import '../../domain/repositories/earnings_repository.dart';

// States
abstract class EarningsState extends Equatable {
  const EarningsState();
  @override
  List<Object?> get props => [];
}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsLoaded extends EarningsState {
  final List<EarningModel> earnings;
  final int totalEarningsCents;
  final int totalTrips;

  const EarningsLoaded({
    required this.earnings,
    required this.totalEarningsCents,
    required this.totalTrips,
  });

  @override
  List<Object?> get props => [earnings.length, totalEarningsCents];
}

class EarningsError extends EarningsState {
  final String message;
  const EarningsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class EarningsCubit extends Cubit<EarningsState> {
  final EarningsRepository _repository;

  EarningsCubit(this._repository) : super(EarningsInitial());

  Future<void> loadEarnings() async {
    emit(EarningsLoading());
    try {
      final earnings = await _repository.getEarnings();
      final totalCents = earnings.fold<int>(
        0,
        (sum, e) => sum + e.runnerPayoutCents,
      );
      emit(EarningsLoaded(
        earnings: earnings,
        totalEarningsCents: totalCents,
        totalTrips: earnings.where((e) => e.isReleased).length,
      ));
    } catch (e) {
      emit(EarningsError(e.toString()));
    }
  }
}
