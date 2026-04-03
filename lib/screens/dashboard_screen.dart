import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/providers/patient_provider.dart';
import '../core/providers/scale_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/models/scale_model.dart';
import 'scale_selection_screen.dart';
import 'patient_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PatientProvider, ScaleProvider>(
      builder: (context, patientProvider, scaleProvider, child) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('NeuroScale Pro'),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => _showAlerts(context, patientProvider),
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Quick Stats
                    _buildQuickStats(patientProvider),
                    
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(context, scaleProvider),

                    const SizedBox(height: 24),

                    // Recent Assessments
                    _buildRecentAssessments(context, patientProvider),

                    const SizedBox(height: 24),

                    // Risk Alerts
                    if (patientProvider.highRiskPatients > 0)
                      _buildRiskAlerts(context, patientProvider),
                  ]),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToNewAssessment(context),
            icon: const Icon(Icons.add),
            label: const Text('New Assessment'),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(PatientProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Patients', provider.totalPatients.toString(), Icons.people, AppTheme.primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('This Month', provider.assessmentsThisMonth.toString(), Icons.analytics, AppTheme.secondaryColor)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('High Risk', provider.highRiskPatients.toString(), Icons.warning, AppTheme.warningColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Scales Used', provider.scaleUsageStats.length.toString(), Icons.list, AppTheme.successColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ScaleProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'PHQ-9',
                'Depression',
                Icons.mood,
                ScaleType.phq9,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'GAD-7',
                'Anxiety',
                Icons.psychology,
                ScaleType.gad7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'C-SSRS',
                'Suicide Risk',
                Icons.warning,
                ScaleType.cssrs,
                isCritical: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'ICU Mode',
                'Fast Scoring',
                Icons.flash_on,
                null,
                isICU: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    ScaleType? scaleType, {
    bool isCritical = false,
    bool isICU = false,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          if (isICU) {
            // Navigate to ICU mode
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScaleSelectionScreen(icuMode: true),
              ),
            );
          } else if (scaleType != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScaleSelectionScreen(initialScale: scaleType),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: isCritical ? AppTheme.errorColor : AppTheme.primaryColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAssessments(BuildContext context, PatientProvider provider) {
    final recentAssessments = provider.recentAssessments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Assessments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full list
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentAssessments.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No assessments yet. Start by adding a patient.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentAssessments.length > 5 ? 5 : recentAssessments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final assessment = recentAssessments[index];
              final patient = provider.patients.firstWhere(
                (p) => p.id == assessment.patientId,
                orElse: () => provider.patients.first,
              );
              return _buildAssessmentTile(context, patient, assessment);
            },
          ),
      ],
    );
  }

  Widget _buildAssessmentTile(BuildContext context, patient, assessment) {
    final color = AppTheme.getRiskColorFromLevel(assessment.riskLevel);
    
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            Icons.analytics,
            color: color,
          ),
        ),
        title: Text(patient.name),
        subtitle: Text(
          '${assessment.scaleType.name.toUpperCase()} - ${assessment.severityLevel.name}\n${DateFormat('MMM d, h:mm a').format(assessment.assessedAt)}',
        ),
        trailing: assessment.hasSuicideRisk
            ? const Icon(Icons.warning, color: AppTheme.errorColor)
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(patientId: patient.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRiskAlerts(BuildContext context, PatientProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.errorColor,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: AppTheme.errorColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.warning, color: AppTheme.errorColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'High Risk Patients',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      Text(
                        '${provider.highRiskPatients} patient(s) require immediate attention',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Show high risk patients
                  },
                  child: const Text('View'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAlerts(BuildContext context, PatientProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alerts'),
        content: Text(
          provider.highRiskPatients > 0
              ? '${provider.highRiskPatients} high-risk patient(s) need attention.'
              : 'No active alerts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToNewAssessment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScaleSelectionScreen(),
      ),
    );
  }
}