import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/models/earning_model.dart';
import '../cubit/earnings_cubit.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EarningsCubit>().loadEarnings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: BlocBuilder<EarningsCubit, EarningsState>(
        builder: (context, state) {
          if (state is EarningsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EarningsError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<EarningsCubit>().loadEarnings(),
            );
          }
          if (state is EarningsLoaded) {
            return _buildContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, EarningsLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<EarningsCubit>().loadEarnings(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          Card(
            color: AppColors.primary.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Total Earnings',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.formatMYR(
                        state.totalEarningsCents),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SummaryItem(
                        icon: Icons.check_circle,
                        label: 'Completed',
                        value: '${state.totalTrips}',
                      ),
                      _SummaryItem(
                        icon: Icons.receipt,
                        label: 'Total Jobs',
                        value: '${state.earnings.length}',
                      ),
                      if (state.totalTrips > 0)
                        _SummaryItem(
                          icon: Icons.trending_up,
                          label: 'Avg/Trip',
                          value: CurrencyFormatter.formatMYR(
                            state.totalEarningsCents ~/
                                state.totalTrips,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // History
          const Text(
            'Payment History',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (state.earnings.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    const Text(
                      'No earnings yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...state.earnings.map((e) => _EarningTile(earning: e)),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _EarningTile extends StatelessWidget {
  final EarningModel earning;
  const _EarningTile({required this.earning});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: earning.isReleased
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.warning.withValues(alpha: 0.2),
          child: Icon(
            earning.isReleased
                ? Icons.check_circle
                : Icons.hourglass_bottom,
            color: earning.isReleased
                ? AppColors.success
                : AppColors.warning,
          ),
        ),
        title: Text(
          earning.bookingNumber.isNotEmpty
              ? earning.bookingNumber
              : 'Booking',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          earning.escrowReleasedAt != null
              ? DateFormatter.dateTime(earning.escrowReleasedAt!)
              : DateFormatter.dateTime(earning.createdAt),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          CurrencyFormatter.formatMYR(earning.runnerPayoutCents),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: earning.isReleased
                ? AppColors.success
                : AppColors.warning,
          ),
        ),
      ),
    );
  }
}
