import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/providers/scale_provider.dart';
import '../core/providers/patient_provider.dart';
import '../core/providers/ai_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/models/patient_model.dart';
import '../core/models/scale_model.dart';
import '../core/services/scale_definitions.dart';
import 'patient_detail_screen.dart';

class AssessmentResultScreen extends StatelessWidget {
  final Assessment assessment;
  final Patient patient;

  const AssessmentResultScreen({
    super.key,
    required this.assessment,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final definition = ScaleDefinitions.allScales[assessment.scaleType];
    final severity = assessment.severityLevel;
    final riskColor = AppTheme.getRiskColorFromLevel(assessment.riskLevel);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: riskColor,
            title: const Text('Assessment Results'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareResults(context),
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _exportResults(context),
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Critical Alert Banner
                if (assessment.hasSuicideRisk || assessment.riskLevel == RiskLevel.critical)
                  _buildAlertBanner(context, assessment),

                const SizedBox(height: 16),

                // Score Card
                _buildScoreCard(definition, severity, riskColor),

                const SizedBox(height: 16),

                // Patient Info
                _buildPatientInfoCard(),

                const SizedBox(height: 16),

                // AI Summary
                if (assessment.aiSummary != null)
                  _buildAISummaryCard(context),

                const SizedBox(height: 16),

                // Item Details
                _buildItemDetailsCard(definition),

                const SizedBox(height: 16),

                // Actions
                _buildActionButtons(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context, Assessment assessment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        border: Border.all(color: AppTheme.errorColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: AppTheme.errorColor),
              const SizedBox(width: 12),
              Text(
                assessment.hasSuicideRisk
                    ? 'SUICIDE RISK DETECTED'
                    : 'CRITICAL SEVERITY',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...assessment.alerts.map((alert) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('• $alert', style: const TextStyle(fontSize: 12)),
          )),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showEmergencyProtocol(context),
            icon: const Icon(Icons.emergency),
            label: const Text('View Emergency Protocol'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(definition, severity, Color riskColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              definition?.name ?? 'Assessment',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: assessment.totalScore / (definition?.maxScore ?? 1),
                    strokeWidth: 12,
                    backgroundColor: AppTheme.textHint,
                    valueColor: AlwaysStoppedAnimation(riskColor),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${assessment.totalScore}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    Text(
                      '/ ${definition?.maxScore ?? 0}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: riskColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                severity.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              severity.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            patient.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(patient.name),
        subtitle: Text('${patient.age} years • ${patient.gender}'),
        trailing: Text(
          DateFormat('MMM d, yyyy\nh:mm a').format(assessment.assessedAt),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildAISummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'AI Clinical Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () => _copySummary(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              assessment.aiSummary!,
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetailsCard(definition) {
    if (definition == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Item Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...definition.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final score = assessment.itemScores[item.id] ?? 0;
              final option = item.options.firstWhere(
                (o) => o.value == score,
                orElse: () => item.options.first,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.question, style: const TextStyle(fontSize: 13)),
                          Text(
                            option.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getRiskColor(score.toDouble(), item.maxScore.toDouble()),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$score',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.getRiskColor(score.toDouble(), item.maxScore.toDouble()),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _generateDrugSuggestions(context),
                icon: const Icon(Icons.medication),
                label: const Text('Drug Suggestions'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToPatient(context),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Patient View'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEmergencyProtocol(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Protocol'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Ensure patient safety - do not leave alone'),
              SizedBox(height: 8),
              Text('2. Remove potential means of self-harm'),
              SizedBox(height: 8),
              Text('3. Contact emergency services if imminent danger'),
              SizedBox(height: 8),
              Text('4. Notify treating psychiatrist immediately'),
              SizedBox(height: 8),
              Text('5. Document all findings and actions taken'),
              SizedBox(height: 8),
              Text('6. Consider involuntary hospitalization if needed'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _shareResults(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon')),
    );
  }

  void _exportResults(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }

  void _copySummary(BuildContext context) {
    // In a real app, copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary copied to clipboard')),
    );
  }

  void _generateDrugSuggestions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Drug Suggestions'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<String>(
            future: Provider.of<AIProvider>(context, listen: false).generateDrugSuggestions(
              diagnosis: patient.diagnosis ?? 'Depression',
              severity: assessment.totalScore,
              patientAge: patient.age,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                child: Text(snapshot.data ?? 'Unable to generate suggestions'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToPatient(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patientId: patient.id),
      ),
      (route) => route.isFirst,
    );
  }
}