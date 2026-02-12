import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/runner_setup_repository.dart';
import '../models/runner_profile_model.dart';

class RunnerSetupRepositoryImpl implements RunnerSetupRepository {
  final ApiClient _apiClient;

  RunnerSetupRepositoryImpl(this._apiClient);

  @override
  Future<RunnerProfileModel> registerRunner({
    required String fullName,
    required String phone,
    required String vehicleType,
    required String vehiclePlate,
    required String vehicleModel,
    required int vehicleYear,
    required bool airConditioned,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/runners',
        data: {
          'full_name': fullName,
          'phone': phone,
          'vehicle_type': vehicleType,
          'vehicle_plate': vehiclePlate,
          'vehicle_model': vehicleModel,
          'vehicle_year': vehicleYear,
          'air_conditioned': airConditioned,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return RunnerProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ?? 'Registration failed',
      );
    }
  }

  @override
  Future<RunnerProfileModel> getMyProfile() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/runners/me');
      final data = response.data['data'] as Map<String, dynamic>;
      return RunnerProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ?? 'Failed to load profile',
      );
    }
  }

  @override
  Future<CrateSpecModel> addCrateSpec({
    required String size,
    required List<String> petTypes,
    required double maxWeightKg,
    required bool ventilated,
    required bool temperatureControlled,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/runners/me/crates',
        data: {
          'size': size,
          'pet_types': petTypes,
          'max_weight_kg': maxWeightKg,
          'ventilated': ventilated,
          'temperature_controlled': temperatureControlled,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return CrateSpecModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ?? 'Failed to add crate',
      );
    }
  }

  @override
  Future<void> goOnline(double latitude, double longitude) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/runners/me/online',
        data: {'latitude': latitude, 'longitude': longitude},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ?? 'Failed to go online',
      );
    }
  }

  @override
  Future<void> goOffline() async {
    try {
      await _apiClient.dio.post('/api/v1/runners/me/offline');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ?? 'Failed to go offline',
      );
    }
  }

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    double? speedKmh,
    double? headingDegrees,
  }) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/runners/me/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          if (speedKmh != null) 'speed_kmh': speedKmh,
          if (headingDegrees != null) 'heading_degrees': headingDegrees,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ?? 'Failed to update location',
      );
    }
  }
}
