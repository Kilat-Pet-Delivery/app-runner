import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../booking/data/models/booking_model.dart';
import '../cubit/job_list_cubit.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<JobListCubit>().loadJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'My Jobs'),
          ],
        ),
      ),
      body: BlocBuilder<JobListCubit, JobListState>(
        builder: (context, state) {
          if (state is JobListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is JobListError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<JobListCubit>().loadJobs(),
            );
          }
          if (state is JobListLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildJobList(
                  state.availableJobs,
                  emptyMessage: 'No available jobs right now',
                  emptyIcon: Icons.inbox,
                ),
                _buildJobList(
                  state.myJobs,
                  emptyMessage: 'No jobs assigned yet',
                  emptyIcon: Icons.assignment,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildJobList(
    List<BookingModel> bookings, {
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<JobListCubit>().loadJobs(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _JobCard(
            booking: booking,
            onTap: () => context.push('/jobs/${booking.id}'),
          );
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const _JobCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        booking.bookingStatus.color.withValues(alpha: 0.2),
                    child: Icon(Icons.pets,
                        color: booking.bookingStatus.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking.petSpec.name} (${booking.petSpec.petTypeDisplay})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          booking.bookingNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: booking.bookingStatus),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.pickupAddress.shortDisplay,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.flag,
                      size: 14, color: AppColors.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.dropoffAddress.shortDisplay,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (booking.routeSpec != null)
                    Text(
                      '${booking.routeSpec!.distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  Text(
                    CurrencyFormatter.formatMYR(
                        booking.estimatedPriceCents),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
