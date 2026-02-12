import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../jobs/domain/repositories/job_repository.dart';
import '../../services/location_service.dart';

// States
abstract class ActiveDeliveryState extends Equatable {
  const ActiveDeliveryState();
  @override
  List<Object?> get props => [];
}

class ActiveDeliveryInitial extends ActiveDeliveryState {}

class ActiveDeliveryLoading extends ActiveDeliveryState {}

class ActiveDeliveryActive extends ActiveDeliveryState {
  final BookingModel booking;
  final double? currentLat;
  final double? currentLng;

  const ActiveDeliveryActive({
    required this.booking,
    this.currentLat,
    this.currentLng,
  });

  @override
  List<Object?> get props =>
      [booking.id, booking.status, currentLat, currentLng];
}

class ActiveDeliveryCompleted extends ActiveDeliveryState {}

class ActiveDeliveryError extends ActiveDeliveryState {
  final String message;
  const ActiveDeliveryError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ActiveDeliveryBloc extends Cubit<ActiveDeliveryState> {
  final JobRepository _jobRepo;
  final LocationService _locationService;
  StreamSubscription<Position>? _positionSub;

  ActiveDeliveryBloc(this._jobRepo, this._locationService)
      : super(ActiveDeliveryInitial());

  Future<void> startDelivery(String bookingId) async {
    emit(ActiveDeliveryLoading());
    try {
      final booking = await _jobRepo.getJob(bookingId);
      _locationService.startTracking();

      // Listen for position updates to update the UI
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((pos) {
        if (state is ActiveDeliveryActive) {
          emit(ActiveDeliveryActive(
            booking: (state as ActiveDeliveryActive).booking,
            currentLat: pos.latitude,
            currentLng: pos.longitude,
          ));
        }
      });

      emit(ActiveDeliveryActive(booking: booking));
    } catch (e) {
      emit(ActiveDeliveryError(e.toString()));
    }
  }

  Future<void> pickup(String bookingId) async {
    try {
      final booking = await _jobRepo.pickupJob(bookingId);
      final current = state;
      emit(ActiveDeliveryActive(
        booking: booking,
        currentLat: current is ActiveDeliveryActive
            ? current.currentLat
            : null,
        currentLng: current is ActiveDeliveryActive
            ? current.currentLng
            : null,
      ));
    } catch (e) {
      emit(ActiveDeliveryError(e.toString()));
    }
  }

  Future<void> deliver(String bookingId) async {
    try {
      await _jobRepo.deliverJob(bookingId);
      _locationService.stopTracking();
      _positionSub?.cancel();
      emit(ActiveDeliveryCompleted());
    } catch (e) {
      emit(ActiveDeliveryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _locationService.stopTracking();
    return super.close();
  }
}
