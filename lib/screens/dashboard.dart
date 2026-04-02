import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/patient.dart';
import '../models/scale_result.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/alert_banner.dart';
import 'patient_screen.dart';

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
  }

  Future<void> _loadPatients() async {
    setState(() => _loading = true);
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
        _loading = false;
      });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Analytics',
            onPressed: () {
              Navigator.pushNamed(context, '/analytics').then((_) => _loadPatients());
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Critical alert banner
                if (_criticalCount > 0)
                  AlertBanner(
                    riskLevel: AppConstants.riskCritical,
                    message:
                        '$_criticalCount patient(s) require urgent attention',
                  ),
                // Stats row
                _buildStatsRow(),
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search patients...',
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
            ),
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
            label: const Text('ICU Mode'),
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
    final total = _patients.length;
    final critical = _criticalCount;
    final assessed = _latestResults.values.where((r) => r != null).length;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total', total.toString(), Icons.people),
          _statItem('Assessed', assessed.toString(), Icons.check_circle),
          _statItem('Urgent', critical.toString(), Icons.warning,
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
          backgroundColor: riskColor.withOpacity(0.2),
          child: Text(
            patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
            style: TextStyle(
                color: riskColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(patient.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${patient.age}Y • ${patient.gender} • ${patient.ward.isNotEmpty ? patient.ward : "OPD"}'
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
                      color: riskColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: riskColor),
                    ),
                    child: Text(
                      result.riskLevel != AppConstants.riskNone
                          ? result.riskLevel
                          : result.severity,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No patients yet\nTap + to add a patient'
                : 'No patients match "$_searchQuery"',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPatientDialog() async {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final diagCtrl = TextEditingController();
    final wardCtrl = TextEditingController();
    String gender = 'Male';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Patient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name *',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age *',
                    prefixIcon: Icon(Icons.cake),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => gender = v ?? 'Male'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: diagCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Diagnosis',
                    prefixIcon: Icon(Icons.medical_information),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: wardCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ward / Unit',
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || ageCtrl.text.isEmpty) {
                  return;
                }
                final patient = Patient(
                  name: nameCtrl.text.trim(),
                  age: int.tryParse(ageCtrl.text) ?? 0,
                  gender: gender,
                  diagnosis: diagCtrl.text.trim(),
                  ward: wardCtrl.text.trim(),
                );
                await _db.insertPatient(patient);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadPatients();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
