import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../booking/data/models/booking_model.dart';
import '../bloc/active_delivery_bloc.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final String bookingId;
  const ActiveDeliveryScreen({super.key, required this.bookingId});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    context.read<ActiveDeliveryBloc>().startDelivery(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActiveDeliveryBloc, ActiveDeliveryState>(
      listener: (context, state) {
        if (state is ActiveDeliveryCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Delivery completed!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
        if (state is ActiveDeliveryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ActiveDeliveryLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ActiveDeliveryActive) {
          return _buildActiveView(context, state);
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Active Delivery')),
          body: const Center(child: Text('No active delivery')),
        );
      },
    );
  }

  Widget _buildActiveView(
      BuildContext context, ActiveDeliveryActive state) {
    final booking = state.booking;
    final pickupLatLng = LatLng(
      booking.pickupAddress.latitude,
      booking.pickupAddress.longitude,
    );
    final dropoffLatLng = LatLng(
      booking.dropoffAddress.latitude,
      booking.dropoffAddress.longitude,
    );
    final currentLatLng = state.currentLat != null && state.currentLng != null
        ? LatLng(state.currentLat!, state.currentLng!)
        : null;

    // Center map on current position or pickup
    final center = currentLatLng ?? pickupLatLng;

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kilatpet.app_runner',
              ),
              MarkerLayer(
                markers: [
                  // Pickup marker
                  Marker(
                    point: pickupLatLng,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on,
                        color: AppColors.success, size: 40),
                  ),
                  // Dropoff marker
                  Marker(
                    point: dropoffLatLng,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.flag,
                        color: AppColors.error, size: 40),
                  ),
                  // Current position
                  if (currentLatLng != null)
                    Marker(
                      point: currentLatLng,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.info.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // Route line
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      if (currentLatLng != null) currentLatLng,
                      pickupLatLng,
                      dropoffLatLng,
                    ],
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ],
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          // Bottom sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(context, booking),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, BookingModel booking) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Status + Pet info
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

              // Address
              Row(
                children: [
                  Icon(
                    booking.status == 'accepted'
                        ? Icons.location_on
                        : Icons.flag,
                    size: 16,
                    color: booking.status == 'accepted'
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.status == 'accepted'
                          ? 'Pickup: ${booking.pickupAddress.shortDisplay}'
                          : 'Dropoff: ${booking.dropoffAddress.shortDisplay}',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action button
              if (booking.status == 'accepted')
                PrimaryButton(
                  label: 'Pet Picked Up',
                  icon: Icons.pets,
                  onPressed: () => context
                      .read<ActiveDeliveryBloc>()
                      .pickup(booking.id),
                )
              else if (booking.status == 'in_transit')
                PrimaryButton(
                  label: 'Confirm Delivery',
                  icon: Icons.check_circle,
                  onPressed: () => context
                      .read<ActiveDeliveryBloc>()
                      .deliver(booking.id),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
