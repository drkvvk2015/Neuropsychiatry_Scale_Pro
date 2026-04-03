import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../core/providers/patient_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/models/scale_model.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Analytics'),
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _exportData(context),
              ),
            ],
          ),
          body: provider.patients.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => provider.loadPatients(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Overview Stats
                      _buildOverviewStats(provider),
                      
                      const SizedBox(height: 24),
                      
                      // Scale Usage Chart
                      _buildScaleUsageChart(provider),
                      
                      const SizedBox(height: 24),
                      
                      // Risk Distribution
                      _buildRiskDistribution(provider),
                      
                      const SizedBox(height: 24),
                      
                      // Monthly Trend
                      _buildMonthlyTrend(provider),
                      
                      const SizedBox(height: 24),
                      
                      // Recent High Risk
                      _buildHighRiskList(provider),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text(
            'No data available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add patients and assessments to see analytics',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStats(PatientProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Patients', provider.totalPatients.toString(), Icons.people, AppTheme.primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Assessments', provider.assessments.length.toString(), Icons.analytics, AppTheme.secondaryColor)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('This Month', provider.assessmentsThisMonth.toString(), Icons.calendar_today, AppTheme.successColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('High Risk', provider.highRiskPatients.toString(), Icons.warning, AppTheme.warningColor)),
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
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleUsageChart(PatientProvider provider) {
    final stats = provider.scaleUsageStats;
    final sections = stats.entries.where((e) => e.value > 0).map((entry) {
      final color = _getScaleColor(entry.key.name);
      return PieChartSectionData(
        title: entry.key.name.substring(0, 3).toUpperCase(),
        value: entry.value.toDouble(),
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    if (sections.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: Text('No assessment data yet')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scale Usage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: stats.entries.where((e) => e.value > 0).map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getScaleColor(entry.key.name),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('${entry.key.name.toUpperCase()}: ${entry.value}'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScaleColor(String scaleType) {
    final colors = {
      'phq9': AppTheme.primaryColor,
      'gad7': AppTheme.secondaryColor,
      'bprs': AppTheme.errorColor,
      'hamd': AppTheme.warningColor,
      'ymrs': Colors.purple,
      'ybocs': Colors.teal,
      'mmse': Colors.orange,
      'cssrs': Colors.red,
    };
    return colors[scaleType] ?? AppTheme.primaryColor;
  }

  Widget _buildRiskDistribution(PatientProvider provider) {
    final assessments = provider.assessments;
    if (assessments.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: Text('No assessment data yet')),
        ),
      );
    }

    final riskCounts = <RiskLevel, int>{
      RiskLevel.none: 0,
      RiskLevel.mild: 0,
      RiskLevel.moderate: 0,
      RiskLevel.severe: 0,
      RiskLevel.critical: 0,
    };

    for (final assessment in assessments) {
      riskCounts[assessment.riskLevel] = (riskCounts[assessment.riskLevel] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Risk Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...riskCounts.entries.where((e) => e.value > 0).map((entry) {
              final percentage = (entry.value / assessments.length * 100).toInt();
              final color = AppTheme.getRiskColorFromLevel(entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key.name.toUpperCase()),
                        Text('${entry.value} (${percentage}%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(color),
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

  Widget _buildMonthlyTrend(PatientProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barGroups: _generateBarGroups(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final month = DateTime(now.year, now.month - (5 - index), 1);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (index + 1) * 1.5,
            color: AppTheme.primaryColor,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHighRiskList(PatientProvider provider) {
    final highRiskAssessments = provider.assessments
        .where((a) => a.riskLevel == RiskLevel.severe || a.riskLevel == RiskLevel.critical)
        .toList();

    if (highRiskAssessments.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.check_circle, color: AppTheme.successColor, size: 48),
                SizedBox(height: 12),
                Text('No high-risk patients'),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'High Risk Patients',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 12),
            ...highRiskAssessments.take(5).map((assessment) {
              final patient = provider.patients.firstWhere(
                (p) => p.id == assessment.patientId,
                orElse: () => provider.patients.first,
              );
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.errorColor.withOpacity(0.2),
                  child: const Icon(Icons.warning, color: AppTheme.errorColor, size: 18),
                ),
                title: Text(patient.name),
                subtitle: Text(
                  '${assessment.scaleType.name.toUpperCase()} - ${assessment.severityLevel.name}',
                ),
                trailing: Text(
                  DateFormat('MMM d').format(assessment.assessedAt),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }
}