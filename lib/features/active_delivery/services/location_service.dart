import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../runner_setup/domain/repositories/runner_setup_repository.dart';

class LocationService {
  final RunnerSetupRepository _runnerRepo;
  StreamSubscription<Position>? _positionSubscription;
  bool _isTracking = false;

  LocationService(this._runnerRepo);

  bool get isTracking => _isTracking;

  Future<void> startTracking() async {
    if (_isTracking) return;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      if (result == LocationPermission.denied ||
          result == LocationPermission.deniedForever) {
        return;
      }
    }

    _isTracking = true;
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    ).listen((position) {
      _runnerRepo.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        speedKmh: position.speed * 3.6, // m/s to km/h
        headingDegrees: position.heading,
      );
    });
  }

  void stopTracking() {
    _isTracking = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void dispose() {
    stopTracking();
  }
}
