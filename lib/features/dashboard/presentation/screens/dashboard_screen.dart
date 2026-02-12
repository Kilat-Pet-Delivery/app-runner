import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../booking/data/models/booking_model.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kilat Runner')),
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError && state is! DashboardLoaded) {
            return ErrorView(
              message: state is DashboardError
                  ? (state as DashboardError).message
                  : 'Something went wrong',
              onRetry: () =>
                  context.read<DashboardCubit>().loadDashboard(),
            );
          }
          if (state is DashboardLoaded) {
            return _buildDashboard(context, state);
          }
          if (state is DashboardTogglingStatus) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, DashboardLoaded state) {
    final profile = state.profile;
    final isOnline = profile.isOnline;

    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Online/Offline Toggle
          Card(
            color: isOnline
                ? AppColors.success.withValues(alpha: 0.1)
                : Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isOnline ? Icons.circle : Icons.circle_outlined,
                    color: isOnline ? AppColors.success : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'You are Online' : 'You are Offline',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isOnline
                                ? AppColors.success
                                : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          isOnline
                              ? 'Accepting delivery requests'
                              : 'Go online to start receiving jobs',
                          style: TextStyle(
                            fontSize: 13,
                            color: isOnline
                                ? AppColors.success
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isOnline,
                    activeColor: AppColors.success,
                    onChanged: (value) async {
                      double? lat;
                      double? lng;
                      if (value) {
                        final pos = await _getCurrentPosition();
                        lat = pos?.latitude;
                        lng = pos?.longitude;
                      }
                      if (context.mounted) {
                        context.read<DashboardCubit>().toggleOnlineStatus(
                              value,
                              lat: lat,
                              lng: lng,
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              _StatCard(
                icon: Icons.star,
                label: 'Rating',
                value: profile.rating.toStringAsFixed(1),
                color: AppColors.warning,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.local_shipping,
                label: 'Total Trips',
                value: '${profile.totalTrips}',
                color: AppColors.info,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.directions_car,
                label: 'Vehicle',
                value: profile.vehicleTypeDisplay,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Job Card
          if (state.activeJob != null) ...[
            const Text(
              'Active Delivery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ActiveJobCard(
              booking: state.activeJob!,
              onTap: () =>
                  context.push('/jobs/${state.activeJob!.id}'),
            ),
            const SizedBox(height: 24),
          ],

          // Available Jobs
          if (isOnline) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Jobs',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/jobs'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.availableJobs.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox,
                            size: 48,
                            color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No available jobs nearby',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...state.availableJobs.take(5).map(
                    (booking) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.accent.withValues(alpha: 0.2),
                          child: const Icon(Icons.pets,
                              color: AppColors.accent),
                        ),
                        title: Text(
                          '${booking.petSpec.name} (${booking.petSpec.petTypeDisplay})',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${booking.pickupAddress.shortDisplay} → ${booking.dropoffAddress.shortDisplay}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          CurrencyFormatter.formatMYR(
                              booking.estimatedPriceCents),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        onTap: () =>
                            context.push('/jobs/${booking.id}'),
                      ),
                    ),
                  ),
          ] else ...[
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(Icons.local_shipping,
                      size: 64,
                      color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text(
                    'Go online to see available jobs',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const _ActiveJobCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
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
                  const Icon(Icons.pets, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${booking.petSpec.name} - ${booking.bookingNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  StatusBadge(status: booking.bookingStatus),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: AppColors.success),
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
                      size: 16, color: AppColors.error),
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.navigation),
                  label: Text(
                    booking.status == 'accepted'
                        ? 'Navigate to Pickup'
                        : 'Continue Delivery',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
