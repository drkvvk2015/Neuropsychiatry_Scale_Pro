import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/providers/patient_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/models/patient_model.dart';
import 'patient_detail_screen.dart';
import 'add_patient_screen.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Patients'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showSearch(context),
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.patients.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.patients.length,
                      itemBuilder: (context, index) {
                        final patient = provider.patients[index];
                        final assessments = provider.getPatientAssessments(patient.id);
                        return _buildPatientCard(context, patient, assessments);
                      },
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addPatient(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildPatientCard(BuildContext context, Patient patient, assessments) {
    final lastAssessment = assessments.isNotEmpty
        ? assessments.reduce((a, b) => a.assessedAt.isAfter(b.assessedAt) ? a : b)
        : null;
    final riskColor = lastAssessment != null
        ? AppTheme.getRiskColorFromLevel(lastAssessment.riskLevel)
        : AppTheme.primaryColor;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: riskColor.withOpacity(0.2),
          child: Text(
            patient.name.substring(0, 1).toUpperCase(),
            style: TextStyle(color: riskColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(patient.name),
        subtitle: Text(
          '${patient.age} yrs • ${patient.gender}\n'
          '${lastAssessment != null ? '${lastAssessment.scaleType.name.toUpperCase()} - ${lastAssessment.severityLevel.name}' : 'No assessments yet'}',
        ),
        trailing: lastAssessment?.hasSuicideRisk == true
            ? const Icon(Icons.warning, color: AppTheme.errorColor)
            : Text(
                '${assessments.length}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
        onTap: () => _openPatientDetail(context, patient),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text(
            'No patients yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first patient to get started',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addPatient(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Patient'),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: PatientSearchDelegate(),
    );
  }

  void _addPatient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPatientScreen()),
    );
  }

  void _openPatientDetail(BuildContext context, Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patientId: patient.id),
      ),
    );
  }
}

class PatientSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context, listen: false);
    final results = provider.patients
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final patient = results[index];
        return Card(
          child: ListTile(
            title: Text(patient.name),
            subtitle: Text('${patient.age} yrs • ${patient.gender}'),
            onTap: () {
              close(context, null);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailScreen(patientId: patient.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}