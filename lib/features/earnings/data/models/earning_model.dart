class EarningModel {
  final String id;
  final String bookingId;
  final String bookingNumber;
  final String escrowStatus;
  final int amountCents;
  final int platformFeeCents;
  final int runnerPayoutCents;
  final String currency;
  final DateTime? escrowReleasedAt;
  final DateTime createdAt;

  const EarningModel({
    required this.id,
    required this.bookingId,
    required this.bookingNumber,
    required this.escrowStatus,
    required this.amountCents,
    required this.platformFeeCents,
    required this.runnerPayoutCents,
    required this.currency,
    this.escrowReleasedAt,
    required this.createdAt,
  });

  bool get isReleased => escrowStatus == 'released';

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      id: json['id'] as String? ?? '',
      bookingId: json['booking_id'] as String? ?? '',
      bookingNumber: json['booking_number'] as String? ?? '',
      escrowStatus: json['escrow_status'] as String? ?? '',
      amountCents: json['amount_cents'] as int? ?? 0,
      platformFeeCents: json['platform_fee_cents'] as int? ?? 0,
      runnerPayoutCents: json['runner_payout_cents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'MYR',
      escrowReleasedAt: json['escrow_released_at'] != null
          ? DateTime.parse(json['escrow_released_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
