import '../../../booking/data/models/booking_model.dart';

abstract class JobRepository {
  Future<List<BookingModel>> getAvailableJobs();
  Future<List<BookingModel>> getMyJobs();
  Future<BookingModel> getJob(String id);
  Future<BookingModel> acceptJob(String id);
  Future<BookingModel> pickupJob(String id);
  Future<BookingModel> deliverJob(String id);
}
