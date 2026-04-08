import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/patient.dart';
import '../models/scale_result.dart';
import '../core/constants.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../l10n/app_localizations_ext.dart';
import '../widgets/alert_banner.dart';
import '../voice/model_manager_sheet.dart';
import 'patient_screen.dart';
import 'privacy_notice.dart';

/// Main dashboard showing patient list and ward overview.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = DatabaseService();
  List<Patient> _patients = [];
  Map<String, ScaleResult?> _latestResults = {};
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _showPrivacyIfNeeded();
  }

  Future<void> _showPrivacyIfNeeded() async {
    // Defer until first frame so context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) await showPrivacyNoticeIfNeeded(context);
    });
  }

  Future<void> _loadPatients() async {
    setState(() => _loading = true);
    try {
      final patients = await _db.getAllPatients();
      final resultsMap = <String, ScaleResult?>{};
      for (final p in patients) {
        final results = await _db.getResultsForPatient(p.id);
        resultsMap[p.id] = results.isNotEmpty ? results.first : null;
      }
      if (mounted) {
        setState(() {
          _patients = patients;
          _latestResults = resultsMap;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patients: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Patient> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    final q = _searchQuery.toLowerCase();
    return _patients
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.diagnosis.toLowerCase().contains(q) ||
            p.ward.toLowerCase().contains(q))
        .toList();
  }

  int get _criticalCount => _latestResults.values
      .where((r) =>
          r != null &&
          (r.riskLevel == AppConstants.riskCritical ||
              r.riskLevel == AppConstants.riskHigh ||
              r.severity == AppConstants.severityVerySevere))
      .length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsExt.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.memory),
            tooltip: l10n.modelManager,
            onPressed: () => showModelManagerSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: l10n.analytics,
            onPressed: () {
              Navigator.pushNamed(context, '/analytics').then((_) => _loadPatients());
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ResponsivePage(
              padding: EdgeInsets.zero,
              child: Column(
              children: [
                // Critical alert banner
                if (_criticalCount > 0)
                  AlertBanner(
                    riskLevel: AppConstants.riskCritical,
                    message: l10n.criticalPatientsBanner(_criticalCount),
                  ),
                // Stats row
                _buildStatsRow(),
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l10n.searchPatients,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(height: 8),
                // Patient list
                Expanded(
                  child: _filteredPatients.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          itemCount: _filteredPatients.length,
                          itemBuilder: (ctx, i) =>
                              _buildPatientTile(_filteredPatients[i]),
                        ),
                ),
              ],
            )),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'icu',
            onPressed: () {
              Navigator.pushNamed(context, '/icu').then((_) => _loadPatients());
            },
            backgroundColor: AppTheme.dangerColor,
            icon: const Icon(Icons.flash_on),
            label: Text(l10n.icuMode),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _showAddPatientDialog,
            child: const Icon(Icons.person_add),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final l10n = AppLocalizationsExt.of(context);
    final total = _patients.length;
    final critical = _criticalCount;
    final assessed = _latestResults.values.where((r) => r != null).length;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 24,
        runSpacing: 12,
        children: [
          _statItem(l10n.total, total.toString(), Icons.people),
          _statItem(l10n.assessed, assessed.toString(), Icons.check_circle),
          _statItem(l10n.urgent, critical.toString(), Icons.warning,
              color: critical > 0 ? Colors.yellow : Colors.white),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon,
      {Color color = Colors.white}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildPatientTile(Patient patient) {
    final l10n = AppLocalizationsExt.of(context);
    final result = _latestResults[patient.id];
    final riskColor = result != null
        ? AppTheme.riskColor(result.riskLevel)
        : Colors.grey;
    final isCritical = result?.riskLevel == AppConstants.riskCritical ||
        result?.riskLevel == AppConstants.riskHigh;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: riskColor.withValues(alpha: 0.2),
          child: Text(
            patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
            style: TextStyle(
                color: riskColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(patient.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${patient.age}Y • ${l10n.genderLabel(patient.gender)} • ${patient.ward.isNotEmpty ? patient.ward : l10n.wardFallback}'
          '${patient.diagnosis.isNotEmpty ? " • ${patient.diagnosis}" : ""}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: result != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: riskColor),
                    ),
                    child: Text(
                      result.riskLevel != AppConstants.riskNone
                        ? l10n.riskLabel(result.riskLevel)
                        : l10n.severityLabel(result.severity),
                      style: TextStyle(
                          color: riskColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isCritical)
                    const Icon(Icons.emergency, color: Colors.red, size: 16),
                ],
              )
            : const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientScreen(patientId: patient.id),
            ),
          ).then((_) => _loadPatients());
        },
        onLongPress: isCritical
            ? () => showEmergencyAlert(context, patient.name, result!.riskLevel)
            : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizationsExt.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? l10n.noPatientsYet
                : l10n.noPatientsMatch(_searchQuery),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPatientDialog() async {
    final l10n = AppLocalizationsExt.of(context);
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final diagCtrl = TextEditingController();
    final wardCtrl = TextEditingController();
    String gender = 'Male';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.addPatient),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.patientNameRequired,
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.ageRequired,
                    prefixIcon: const Icon(Icons.cake),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: gender,
                  decoration: InputDecoration(labelText: l10n.gender),
                  items: [
                    DropdownMenuItem(value: 'Male', child: Text(l10n.male)),
                    DropdownMenuItem(value: 'Female', child: Text(l10n.female)),
                    DropdownMenuItem(value: 'Other', child: Text(l10n.other)),
                  ],
                  onChanged: (v) => setDialogState(() => gender = v ?? 'Male'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: diagCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.diagnosis,
                    prefixIcon: const Icon(Icons.medical_information),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: wardCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.wardUnit,
                    prefixIcon: const Icon(Icons.local_hospital),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameCtrl.dispose();
                ageCtrl.dispose();
                diagCtrl.dispose();
                wardCtrl.dispose();
                Navigator.pop(ctx);
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final age = int.tryParse(ageCtrl.text);
                if (age == null || age < 0 || age > 120) return;
                final patient = Patient(
                  name: nameCtrl.text.trim(),
                  age: age,
                  gender: gender,
                  diagnosis: diagCtrl.text.trim(),
                  ward: wardCtrl.text.trim(),
                );
                try {
                  await _db.insertPatient(patient);
                  if (ctx.mounted) {
                    nameCtrl.dispose();
                    ageCtrl.dispose();
                    diagCtrl.dispose();
                    wardCtrl.dispose();
                    Navigator.pop(ctx);
                  }
                  _loadPatients();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Failed to save: $e')),
                    );
                  }
                }
              },
              child: Text(l10n.addPatient),
            ),
          ],
        ),
      ),
    );
  }
}
