import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../booking/data/models/booking_model.dart';
import '../cubit/job_detail_cubit.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JobDetailCubit>().loadJob(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: BlocConsumer<JobDetailCubit, JobDetailState>(
        listener: (context, state) {
          if (state is JobDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is JobDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is JobDetailError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<JobDetailCubit>().loadJob(widget.jobId),
            );
          }
          if (state is JobDetailLoaded) {
            return _buildContent(context, state.booking);
          }
          if (state is JobDetailActionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, BookingModel booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + Booking Number
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.bookingNumber,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StatusBadge(status: booking.bookingStatus),
            ],
          ),
          const SizedBox(height: 16),

          // Pet Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pets, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Pet Information',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoRow('Name', booking.petSpec.name),
                  _InfoRow('Type', booking.petSpec.petTypeDisplay),
                  if (booking.petSpec.breed.isNotEmpty)
                    _InfoRow('Breed', booking.petSpec.breed),
                  _InfoRow('Weight',
                      '${booking.petSpec.weightKg.toStringAsFixed(1)} kg'),
                  if (booking.petSpec.specialNeeds.isNotEmpty)
                    _InfoRow('Special Needs', booking.petSpec.specialNeeds),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Addresses Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.route, color: AppColors.info),
                      const SizedBox(width: 8),
                      const Text('Route',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.circle,
                              size: 12, color: AppColors.success),
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          const Icon(Icons.circle,
                              size: 12, color: AppColors.error),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pickup',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            Text(booking.pickupAddress.fullDisplay,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 20),
                            const Text('Dropoff',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            Text(booking.dropoffAddress.fullDisplay,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (booking.routeSpec != null) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _RouteInfo(
                          icon: Icons.straighten,
                          label: 'Distance',
                          value:
                              '${booking.routeSpec!.distanceKm.toStringAsFixed(1)} km',
                        ),
                        _RouteInfo(
                          icon: Icons.timer,
                          label: 'Est. Time',
                          value:
                              '${booking.routeSpec!.estimatedDurationMin} min',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Price & Notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Price',
                          style: TextStyle(fontSize: 14)),
                      Text(
                        CurrencyFormatter.formatMYR(
                            booking.estimatedPriceCents),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (booking.notes != null &&
                      booking.notes!.isNotEmpty) ...[
                    const Divider(height: 24),
                    const Text('Notes',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(booking.notes!),
                  ],
                  if (booking.scheduledAt != null) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Scheduled: ${DateFormatter.dateTime(booking.scheduledAt!)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          _buildActionButton(context, booking),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, BookingModel booking) {
    switch (booking.status) {
      case 'requested':
        return PrimaryButton(
          label: 'Accept Job',
          icon: Icons.check_circle,
          onPressed: () =>
              context.read<JobDetailCubit>().acceptJob(widget.jobId),
        );
      case 'accepted':
        return PrimaryButton(
          label: 'Picked Up Pet',
          icon: Icons.pets,
          onPressed: () =>
              context.read<JobDetailCubit>().pickupJob(widget.jobId),
        );
      case 'in_transit':
        return PrimaryButton(
          label: 'Confirm Delivery',
          icon: Icons.check_circle,
          onPressed: () =>
              context.read<JobDetailCubit>().deliverJob(widget.jobId),
        );
      case 'delivered':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_bottom,
                  color: AppColors.success),
              SizedBox(width: 8),
              Text(
                'Waiting for owner confirmation',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        );
      case 'completed':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: 8),
              Text(
                'Delivery Completed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _RouteInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RouteInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
