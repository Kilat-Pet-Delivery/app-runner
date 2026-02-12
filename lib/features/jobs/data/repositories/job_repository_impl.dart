import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../domain/repositories/job_repository.dart';

class JobRepositoryImpl implements JobRepository {
  final ApiClient _apiClient;

  JobRepositoryImpl(this._apiClient);

  @override
  Future<List<BookingModel>> getAvailableJobs() async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/bookings',
        queryParameters: {'status': 'requested'},
      );
      final items = response.data['data']['items'] as List<dynamic>? ??
          response.data['data'] as List<dynamic>? ??
          [];
      return items
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ?? 'Failed to load jobs',
      );
    }
  }

  @override
  Future<List<BookingModel>> getMyJobs() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/bookings');
      final items = response.data['data']['items'] as List<dynamic>? ??
          response.data['data'] as List<dynamic>? ??
          [];
      return items
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ?? 'Failed to load jobs',
      );
    }
  }

  @override
  Future<BookingModel> getJob(String id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/bookings/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return BookingModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ?? 'Failed to load job',
      );
    }
  }

  @override
  Future<BookingModel> acceptJob(String id) async {
    try {
      final response =
          await _apiClient.dio.post('/api/v1/bookings/$id/accept');
      final data = response.data['data'] as Map<String, dynamic>;
      return BookingModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ?? 'Failed to accept job',
      );
    }
  }

  @override
  Future<BookingModel> pickupJob(String id) async {
    try {
      final response =
          await _apiClient.dio.post('/api/v1/bookings/$id/pickup');
      final data = response.data['data'] as Map<String, dynamic>;
      return BookingModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ?? 'Failed to start pickup',
      );
    }
  }

  @override
  Future<BookingModel> deliverJob(String id) async {
    try {
      final response =
          await _apiClient.dio.post('/api/v1/bookings/$id/deliver');
      final data = response.data['data'] as Map<String, dynamic>;
      return BookingModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ??
            'Failed to confirm delivery',
      );
    }
  }
}
