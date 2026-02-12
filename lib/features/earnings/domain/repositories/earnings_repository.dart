import '../../data/models/earning_model.dart';

abstract class EarningsRepository {
  Future<EarningModel> getPaymentForBooking(String bookingId);
  Future<List<EarningModel>> getEarnings();
}
