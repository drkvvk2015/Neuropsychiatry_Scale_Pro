import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/providers/patient_provider.dart';
import '../core/providers/scale_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/models/scale_model.dart';
import 'scale_selection_screen.dart';
import 'assessment_result_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PatientProvider, ScaleProvider>(
      builder: (context, patientProvider, scaleProvider, child) {
        final patient = patientProvider.patients.firstWhere(
          (p) => p.id == patientId,
          orElse: () => throw Exception('Patient not found'),
        );
        final assessments = patientProvider.getPatientAssessments(patientId);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar with patient info
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Text(
                                patient.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              patient.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${patient.age} years • ${patient.gender}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            if (patient.diagnosis != null && patient.diagnosis!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Chip(
                                  label: Text(
                                    patient.diagnosis!,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: AppTheme.secondaryColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editPatient(context, patient),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context, patient),
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Quick Actions
                    _buildQuickActions(context, patient),

                    const SizedBox(height: 24),

                    // Assessment History
                    _buildAssessmentHistory(context, assessments),

                    const SizedBox(height: 24),

                    // Patient Info
                    _buildPatientInfo(patient),
                  ]),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _startNewAssessment(context, patient),
            icon: const Icon(Icons.add),
            label: const Text('New Assessment'),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, patient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'PHQ-9',
                Icons.mood,
                () => _startAssessment(context, patient, ScaleType.phq9),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'GAD-7',
                Icons.psychology,
                () => _startAssessment(context, patient, ScaleType.gad7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 28),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentHistory(BuildContext context, List<Assessment> assessments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assessment History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (assessments.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No assessments yet',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assessments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final assessment = assessments[index];
              return _buildAssessmentCard(context, assessment);
            },
          ),
      ],
    );
  }

  Widget _buildAssessmentCard(BuildContext context, Assessment assessment) {
    final color = AppTheme.getRiskColorFromLevel(assessment.riskLevel);
    
    return Card(
      child: InkWell(
        onTap: () => _viewAssessment(context, assessment),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          assessment.scaleType.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (assessment.hasSuicideRisk)
                          const Icon(Icons.warning, color: AppTheme.errorColor, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${assessment.severityLevel.name} • Score: ${assessment.totalScore}',
                      style: TextStyle(color: color, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(assessment.assessedAt),
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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

  Widget _buildPatientInfo(patient) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', patient.name),
            _buildInfoRow('Age', '${patient.age} years'),
            _buildInfoRow('Gender', patient.gender),
            if (patient.phone != null) _buildInfoRow('Phone', patient.phone!),
            if (patient.address != null) _buildInfoRow('Address', patient.address!),
            if (patient.diagnosis != null) _buildInfoRow('Diagnosis', patient.diagnosis!),
            if (patient.notes != null) _buildInfoRow('Notes', patient.notes!),
            _buildInfoRow('Registered', patient.formattedCreatedAt),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _startNewAssessment(BuildContext context, patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScaleSelectionScreen(patient: patient),
      ),
    );
  }

  void _startAssessment(BuildContext context, patient, ScaleType scaleType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScaleSelectionScreen(
          patient: patient,
          initialScale: scaleType,
        ),
      ),
    );
  }

  void _viewAssessment(BuildContext context, Assessment assessment) {
    final patient = Provider.of<PatientProvider>(context, listen: false).patients.firstWhere(
      (p) => p.id == assessment.patientId,
      orElse: () => throw Exception('Patient not found'),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentResultScreen(assessment: assessment, patient: patient),
      ),
    );
  }

  void _editPatient(BuildContext context, patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit patient feature coming soon')),
    );
  }

  void _confirmDelete(BuildContext context, patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Are you sure you want to delete ${patient.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<PatientProvider>(context, listen: false).deletePatient(patient.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}