import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/patient_provider.dart';
import '../core/providers/scale_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/models/patient_model.dart';
import '../core/models/scale_model.dart';
import '../core/services/scale_definitions.dart';
import 'assessment_screen.dart';

class ScaleSelectionScreen extends StatelessWidget {
  final Patient? patient;
  final ScaleType? initialScale;
  final bool icuMode;

  const ScaleSelectionScreen({
    super.key,
    this.patient,
    this.initialScale,
    this.icuMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<PatientProvider, ScaleProvider>(
      builder: (context, patientProvider, scaleProvider, child) {
        // If a scale is pre-selected, navigate directly to assessment
        if (initialScale != null && patient != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scaleProvider.selectScale(initialScale!);
            scaleProvider.startAssessment();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AssessmentScreen(
                  patient: patient!,
                  isICUMode: icuMode,
                ),
              ),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(icuMode ? 'ICU Mode - Select Scale' : 'Select Assessment Scale'),
          ),
          body: patient == null
              ? _buildPatientSelection(context, patientProvider, scaleProvider)
              : _buildScaleList(context, scaleProvider),
        );
      },
    );
  }

  Widget _buildPatientSelection(
    BuildContext context,
    PatientProvider patientProvider,
    ScaleProvider scaleProvider,
  ) {
    return Column(
      children: [
        // Step indicator
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStepIndicator(1, 'Patient', true),
              const Expanded(child: Divider()),
              _buildStepIndicator(2, 'Scale', false),
            ],
          ),
        ),
        Expanded(
          child: patientProvider.patients.isEmpty
              ? _buildNoPatientsState(context)
              : _buildPatientList(context, patientProvider, scaleProvider),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isActive ? AppTheme.primaryColor : AppTheme.textHint,
          child: Text(
            '$step',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNoPatientsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text(
            'No patients found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please add a patient first',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Go back to add patient
            },
            child: const Text('Add Patient'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList(
    BuildContext context,
    PatientProvider patientProvider,
    ScaleProvider scaleProvider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: patientProvider.patients.length,
      itemBuilder: (context, index) {
        final patient = patientProvider.patients[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                patient.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(patient.name),
            subtitle: Text('${patient.age} yrs • ${patient.gender}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              scaleProvider.clearScores();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScaleSelectionScreen(
                    patient: patient,
                    icuMode: icuMode,
                    initialScale: initialScale,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildScaleList(BuildContext context, ScaleProvider scaleProvider) {
    final scales = ScaleDefinitions.allScales.values.toList();

    return Column(
      children: [
        // Step indicator
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStepIndicator(1, 'Patient', true),
              const Expanded(child: Divider()),
              _buildStepIndicator(2, 'Scale', true),
            ],
          ),
        ),
        if (patient != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Assessing: ${patient!.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scales.length,
            itemBuilder: (context, index) {
              final scale = scales[index];
              return _buildScaleCard(context, scaleProvider, scale);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScaleCard(
    BuildContext context,
    ScaleProvider scaleProvider,
    scale,
  ) {
    bool isCritical = scale.type == ScaleType.cssrs;
    
    return Card(
      child: InkWell(
        onTap: () {
          scaleProvider.selectScale(scale.type);
          scaleProvider.startAssessment();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssessmentScreen(
                patient: patient!,
                isICUMode: icuMode,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCritical
                      ? AppTheme.errorColor.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCritical ? Icons.warning : Icons.analytics,
                  color: isCritical ? AppTheme.errorColor : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          scale.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isCritical)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Chip(
                              label: const Text(
                                'Critical',
                                style: TextStyle(fontSize: 10, color: Colors.white),
                              ),
                              backgroundColor: AppTheme.errorColor,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scale.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}