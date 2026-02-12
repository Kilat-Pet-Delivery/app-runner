import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/runner_setup_cubit.dart';

class RunnerSetupScreen extends StatefulWidget {
  const RunnerSetupScreen({super.key});

  @override
  State<RunnerSetupScreen> createState() => _RunnerSetupScreenState();
}

class _RunnerSetupScreenState extends State<RunnerSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();

  String _vehicleType = 'motorcycle';
  bool _airConditioned = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _vehiclePlateController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RunnerSetupCubit, RunnerSetupState>(
      listener: (context, state) {
        if (state is RunnerSetupSuccess) {
          context.go('/home');
        } else if (state is RunnerSetupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Runner Setup'),
          automaticallyImplyLeading: false,
        ),
        body: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _currentStep > 0
              ? () => setState(() => _currentStep--)
              : null,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (_currentStep < 1)
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: const Text('Next'),
                    )
                  else
                    BlocBuilder<RunnerSetupCubit, RunnerSetupState>(
                      builder: (context, state) {
                        return PrimaryButton(
                          label: 'Register',
                          isLoading: state is RunnerSetupLoading,
                          onPressed: details.onStepContinue,
                        );
                      },
                    ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Personal Info'),
              content: _buildPersonalInfoStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
            ),
            Step(
              title: const Text('Vehicle Details'),
              content: _buildVehicleStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _fullNameController,
            label: 'Full Name',
            prefixIcon: const Icon(Icons.person),
            validator: (v) =>
                v == null || v.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _phoneController,
            label: 'Phone Number',
            prefixIcon: const Icon(Icons.phone),
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.isEmpty ? 'Phone is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vehicle Type',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'motorcycle',
              label: Text('Motorcycle'),
              icon: Icon(Icons.two_wheeler),
            ),
            ButtonSegment(
              value: 'car',
              label: Text('Car'),
              icon: Icon(Icons.directions_car),
            ),
            ButtonSegment(
              value: 'van',
              label: Text('Van'),
              icon: Icon(Icons.airport_shuttle),
            ),
          ],
          selected: {_vehicleType},
          onSelectionChanged: (v) =>
              setState(() => _vehicleType = v.first),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _vehiclePlateController,
          label: 'License Plate',
          prefixIcon: const Icon(Icons.confirmation_number),
          validator: (v) =>
              v == null || v.isEmpty ? 'Plate is required' : null,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _vehicleModelController,
          label: 'Vehicle Model',
          prefixIcon: const Icon(Icons.directions_car),
          validator: (v) =>
              v == null || v.isEmpty ? 'Model is required' : null,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _vehicleYearController,
          label: 'Vehicle Year',
          prefixIcon: const Icon(Icons.calendar_today),
          keyboardType: TextInputType.number,
          validator: (v) =>
              v == null || v.isEmpty ? 'Year is required' : null,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Air Conditioned'),
          subtitle: const Text('Vehicle has working AC'),
          value: _airConditioned,
          onChanged: (v) => setState(() => _airConditioned = v),
        ),
      ],
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      if (_vehiclePlateController.text.isEmpty ||
          _vehicleModelController.text.isEmpty ||
          _vehicleYearController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all vehicle details')),
        );
        return;
      }

      context.read<RunnerSetupCubit>().registerRunner(
            fullName: _fullNameController.text,
            phone: _phoneController.text,
            vehicleType: _vehicleType,
            vehiclePlate: _vehiclePlateController.text,
            vehicleModel: _vehicleModelController.text,
            vehicleYear:
                int.tryParse(_vehicleYearController.text) ?? 2024,
            airConditioned: _airConditioned,
          );
    }
  }
}
