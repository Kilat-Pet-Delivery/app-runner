import '../../data/models/runner_profile_model.dart';

abstract class RunnerSetupRepository {
  Future<RunnerProfileModel> registerRunner({
    required String fullName,
    required String phone,
    required String vehicleType,
    required String vehiclePlate,
    required String vehicleModel,
    required int vehicleYear,
    required bool airConditioned,
  });

  Future<RunnerProfileModel> getMyProfile();

  Future<CrateSpecModel> addCrateSpec({
    required String size,
    required List<String> petTypes,
    required double maxWeightKg,
    required bool ventilated,
    required bool temperatureControlled,
  });

  Future<void> goOnline(double latitude, double longitude);

  Future<void> goOffline();

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    double? speedKmh,
    double? headingDegrees,
  });
}
