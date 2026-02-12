import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../models/earning_model.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final ApiClient _apiClient;

  EarningsRepositoryImpl(this._apiClient);

  @override
  Future<EarningModel> getPaymentForBooking(String bookingId) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/payments/booking/$bookingId',
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return EarningModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ??
            'Failed to load payment',
      );
    }
  }

  @override
  Future<List<EarningModel>> getEarnings() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/payments');
      final items = response.data['data']['items'] as List<dynamic>? ??
          response.data['data'] as List<dynamic>? ??
          [];
      return items
          .map((e) => EarningModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error']?.toString() ??
            'Failed to load earnings',
      );
    }
  }
}
