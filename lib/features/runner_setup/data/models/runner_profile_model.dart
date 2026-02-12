import '../../../booking/data/models/booking_model.dart';

class RunnerProfileModel {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String vehicleType;
  final String vehiclePlate;
  final String vehicleModel;
  final bool airConditioned;
  final String sessionStatus;
  final double rating;
  final int totalTrips;
  final List<CrateSpecModel> crateSpecs;
  final DateTime createdAt;

  const RunnerProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.airConditioned,
    required this.sessionStatus,
    required this.rating,
    required this.totalTrips,
    required this.crateSpecs,
    required this.createdAt,
  });

  bool get isOnline => sessionStatus == 'active';

  factory RunnerProfileModel.fromJson(Map<String, dynamic> json) {
    return RunnerProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? '',
      vehiclePlate: json['vehicle_plate'] as String? ?? '',
      vehicleModel: json['vehicle_model'] as String? ?? '',
      airConditioned: json['air_conditioned'] as bool? ?? false,
      sessionStatus: json['session_status'] as String? ?? 'inactive',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: json['total_trips'] as int? ?? 0,
      crateSpecs: (json['crate_specs'] as List<dynamic>?)
              ?.map((e) =>
                  CrateSpecModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get vehicleTypeDisplay {
    switch (vehicleType) {
      case 'car':
        return 'Car';
      case 'van':
        return 'Van';
      case 'motorcycle':
        return 'Motorcycle';
      default:
        return vehicleType;
    }
  }
}

class CrateSpecModel {
  final String id;
  final String size;
  final List<String> petTypes;
  final double maxWeightKg;
  final bool ventilated;
  final bool temperatureControlled;

  const CrateSpecModel({
    required this.id,
    required this.size,
    required this.petTypes,
    required this.maxWeightKg,
    required this.ventilated,
    required this.temperatureControlled,
  });

  factory CrateSpecModel.fromJson(Map<String, dynamic> json) {
    return CrateSpecModel(
      id: json['id'] as String? ?? '',
      size: json['size'] as String? ?? 'small',
      petTypes: (json['pet_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      maxWeightKg: (json['max_weight_kg'] as num?)?.toDouble() ?? 0,
      ventilated: json['ventilated'] as bool? ?? false,
      temperatureControlled:
          json['temperature_controlled'] as bool? ?? false,
    );
  }

  String get sizeDisplay {
    switch (size) {
      case 'small':
        return 'Small';
      case 'medium':
        return 'Medium';
      case 'large':
        return 'Large';
      case 'xlarge':
        return 'X-Large';
      default:
        return size;
    }
  }

  String get petTypesDisplay => petTypes.join(', ');
}
