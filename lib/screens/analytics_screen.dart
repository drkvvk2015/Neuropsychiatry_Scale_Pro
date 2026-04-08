import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/database_service.dart';
import '../services/export/export_service.dart';
import '../models/patient.dart';
import '../models/scale_result.dart';
import '../core/constants.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../l10n/app_localizations_ext.dart';

/// Analytics screen with patient trend charts and CSV export.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _db = DatabaseService();
  final _exportService = ExportService();
  List<Patient> _patients = [];
  List<ScaleResult> _allResults = [];
  Patient? _selectedPatient;
  String _selectedScale = AppConstants.scalePHQ9;
  bool _loading = true;
  bool _exporting = false;

  static const _scales = [
    AppConstants.scaleBPRS,
    AppConstants.scalePHQ9,
    AppConstants.scaleGAD7,
    AppConstants.scaleHAMD,
    AppConstants.scaleYMRS,
    AppConstants.scaleYBOCS,
    AppConstants.scaleMMSE,
    AppConstants.scaleCSSRS,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final patients = await _db.getAllPatients();
      final results = await _db.getAllResults();
      if (mounted) {
        setState(() {
          _patients = patients;
          _allResults = results;
          _selectedPatient = patients.isNotEmpty ? patients.first : null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ScaleResult> get _chartResults {
    if (_selectedPatient == null) return [];
    return _allResults
        .where((r) =>
            r.patientId == _selectedPatient!.id &&
            r.scaleName == _selectedScale)
        .toList()
      ..sort((a, b) => a.assessedAt.compareTo(b.assessedAt));
  }

  Map<String, int> get _severityDistribution {
    final counts = <String, int>{};
    for (final r in _allResults) {
      final key = r.severity.isNotEmpty ? r.severity : r.riskLevel;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> get _scaleDistribution {
    final counts = <String, int>{};
    for (final r in _allResults) {
      counts[r.scaleName] = (counts[r.scaleName] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsExt.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analyticsTitle),
        actions: [
          _exporting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: l10n.exportCsv,
                  onPressed: _exportCsv,
                ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _allResults.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  child: ResponsivePage(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(),
                      const SizedBox(height: 20),
                      _buildPatientTrendChart(),
                      const SizedBox(height: 20),
                      _buildSeverityPieChart(),
                      const SizedBox(height: 20),
                      _buildScaleUsageChart(),
                    ],
                  ),
                ),
                ),
    );
  }

  Widget _buildSummaryCards() {
    final l10n = AppLocalizationsExt.of(context);
    final totalPatients = _patients.length;
    final totalAssessments = _allResults.length;
    final highRisk = _allResults
        .where((r) =>
            r.riskLevel == AppConstants.riskHigh ||
            r.riskLevel == AppConstants.riskCritical)
        .length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SizedBox(
          width: ResponsiveLayout.isPhone(context) ? double.infinity : 220,
          child: _summaryCard(l10n.patients, totalPatients, Icons.people,
              AppTheme.primaryColor),
        ),
        SizedBox(
          width: ResponsiveLayout.isPhone(context) ? double.infinity : 220,
          child: _summaryCard(l10n.assessments, totalAssessments, Icons.assignment,
              AppTheme.secondaryColor),
        ),
        SizedBox(
          width: ResponsiveLayout.isPhone(context) ? double.infinity : 220,
          child: _summaryCard(l10n.highRisk, highRisk, Icons.warning,
              AppTheme.dangerColor),
        ),
      ],
    );
  }

  Widget _summaryCard(
      String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text('$value',
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientTrendChart() {
    final l10n = AppLocalizationsExt.of(context);
    final results = _chartResults;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.patientTrendChart,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            // Patient selector
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: ResponsiveLayout.isPhone(context) ? double.infinity : 280,
                  child: DropdownButtonFormField<Patient>(
                    initialValue: _selectedPatient,
                    decoration: InputDecoration(
                        labelText: l10n.patient,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8)),
                    items: _patients
                        .map((p) => DropdownMenuItem(
                            value: p, child: Text(p.name)))
                        .toList(),
                    onChanged: (p) =>
                        setState(() => _selectedPatient = p),
                  ),
                ),
                SizedBox(
                  width: ResponsiveLayout.isPhone(context) ? double.infinity : 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedScale,
                    decoration: InputDecoration(
                        labelText: l10n.scale,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8)),
                    items: _scales
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (s) =>
                        setState(() => _selectedScale = s ?? _selectedScale),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (results.isEmpty)
              Center(child: Text(l10n.noDataForSelection))
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (v, m) => Text(
                            v.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, m) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= results.length) {
                              return const SizedBox.shrink();
                            }
                            final dt = results[idx].assessedAt;
                            return Text(
                              '${dt.day}/${dt.month}',
                              style: const TextStyle(fontSize: 9),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: results
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(),
                                e.value.totalScore.toDouble()))
                            .toList(),
                        isCurved: true,
                        color: AppTheme.primaryColor,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color:
                              AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityPieChart() {
    final l10n = AppLocalizationsExt.of(context);
    final dist = _severityDistribution;
    if (dist.isEmpty) return const SizedBox.shrink();

    final entries = dist.entries.toList();
    final total = entries.fold(0, (s, e) => s + e.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.severityDistributionWard,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: PieChart(
                    PieChartData(
                      sections: entries.map((e) {
                        final color = AppTheme.severityColor(e.key);
                        final pct = e.value / total * 100;
                        return PieChartSectionData(
                          color: color,
                          value: e.value.toDouble(),
                          title: '${pct.round()}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveLayout.isPhone(context) ? double.infinity : 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries
                        .map((e) => _legendItem(
                            e.key, e.value, AppTheme.severityColor(e.key)))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleUsageChart() {
    final l10n = AppLocalizationsExt.of(context);
    final dist = _scaleDistribution;
    if (dist.isEmpty) return const SizedBox.shrink();

    final entries = dist.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = entries.first.value.toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.scaleUsage,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal * 1.2,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              entries[idx].key,
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, m) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(fontSize: 9),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: entries
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.value.toDouble(),
                                color: AppTheme.primaryColor,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4)),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$label: $count',
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizationsExt.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n.noAnalyticsData,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv() async {
    if (_exporting) return;
    final l10n = AppLocalizationsExt.of(context);
    setState(() => _exporting = true);
    try {
      final csv = await _db.exportToCsv();
      await _exportService.exportCsv(
        csv,
        'neuroscale_export.csv',
        shareSubject: l10n.exportSubject,
      );
    } catch (e) {
      if (mounted) {
        final msg = e.toString();
        final truncated = msg.length > 120 ? '${msg.substring(0, 120)}...' : msg;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(truncated))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}
