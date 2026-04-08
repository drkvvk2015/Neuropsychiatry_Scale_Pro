import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/ai_engine.dart';
import '../services/drug_engine.dart';
import '../services/scoring_engine.dart';
import '../models/patient.dart';
import '../models/scale_result.dart';
import '../core/constants.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../l10n/app_localizations_ext.dart';
import '../widgets/alert_banner.dart';
import '../widgets/scale_card.dart';
import 'scale_screen.dart';

/// Patient detail screen showing all scale assessments and AI summary.
class PatientScreen extends StatefulWidget {
  final String patientId;

  const PatientScreen({super.key, required this.patientId});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  Patient? _patient;
  List<ScaleResult> _results = [];
  bool _loading = true;
  late TabController _tabController;

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
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final patient = await _db.getPatient(widget.patientId);
      final results = await _db.getResultsForPatient(widget.patientId);
      if (mounted) {
        setState(() {
          _patient = patient;
          _results = results;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patient: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  ScaleResult? _latestResult(String scaleName) {
    final index = _results.indexWhere((r) => r.scaleName == scaleName);
    return index >= 0 ? _results[index] : null;
  }

  String get _overallRisk {
    String risk = AppConstants.riskNone;
    for (final r in _results) {
      if (_riskRank(r.riskLevel) > _riskRank(risk)) risk = r.riskLevel;
    }
    return risk;
  }

  int _riskRank(String risk) {
    switch (risk) {
      case AppConstants.riskCritical:
        return 4;
      case AppConstants.riskHigh:
        return 3;
      case AppConstants.riskModerate:
        return 2;
      case AppConstants.riskLow:
        return 1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsExt.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_patient == null) {
      return Scaffold(body: Center(child: Text(l10n.patientNotFound)));
    }

    final patient = _patient!;
    final risk = _overallRisk;
    final showAlert = risk == AppConstants.riskCritical ||
        risk == AppConstants.riskHigh;

    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: const Icon(Icons.assessment), text: l10n.scalesTab),
            Tab(icon: const Icon(Icons.smart_toy), text: l10n.aiSummaryTab),
            Tab(icon: const Icon(Icons.medication), text: l10n.drugsTab),
          ],
        ),
      ),
      body: ResponsivePage(
        padding: EdgeInsets.zero,
        child: Column(
        children: [
          // Patient header
          _buildPatientHeader(patient),
          // Alert banner
          if (showAlert)
            AlertBanner(
              riskLevel: risk,
              message: l10n.urgentClinicalAttention,
              onDismiss: () => setState(() {}),
            ),
          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScalesTab(),
                _buildAiSummaryTab(),
                _buildDrugsTab(),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPatientHeader(Patient patient) {
    final l10n = AppLocalizationsExt.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor.withValues(alpha: 0.05),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            child: Text(
              patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: ResponsiveLayout.isDesktop(context) ? 420 : MediaQuery.sizeOf(context).width - 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                  '${patient.age}Y • ${l10n.genderLabel(patient.gender)} • ${patient.ward.isNotEmpty ? patient.ward : l10n.wardFallback}'),
                if (patient.diagnosis.isNotEmpty)
                  Text('Dx: ${patient.diagnosis}',
                      style: const TextStyle(
                          color: AppTheme.primaryColor)),
              ],
            ),
          ),
          // Overall risk badge
          if (_results.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.riskColor(_overallRisk).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.riskColor(_overallRisk)),
              ),
              child: Column(
                children: [
                  Text(l10n.risk,
                      style: TextStyle(
                          color: AppTheme.riskColor(_overallRisk),
                          fontSize: 10)),
                  Text(
                    l10n.riskLabel(_overallRisk).replaceAll(' Risk', '').replaceAll(' ', '\n'),
                    style: TextStyle(
                        color: AppTheme.riskColor(_overallRisk),
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScalesTab() {
    final columns = ResponsiveLayout.gridColumns(context, phone: 1, tablet: 2, desktop: 2);
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: ResponsiveLayout.isPhone(context) ? 2.2 : 2.5,
      ),
      itemCount: _scales.length,
      itemBuilder: (ctx, i) {
        final scaleName = _scales[i];
        final result = _latestResult(scaleName);
        return ScaleCard(
          scaleName: scaleName,
          score: result?.totalScore,
          maxScore: ScoringEngine.getMaxScore(scaleName),
          severity: result?.severity ?? '',
          riskLevel: result?.riskLevel ?? '',
          assessedAt: result?.assessedAt,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScaleScreen(
                  patientId: widget.patientId,
                  scaleName: scaleName,
                  existingResult: result,
                ),
              ),
            ).then((_) => _load());
          },
        );
      },
    );
  }

  Widget _buildAiSummaryTab() {
    final l10n = AppLocalizationsExt.of(context);
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.completeScaleForSummary,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final summary = AiEngine.generateClinicalSummary(
      patient: _patient!,
      results: _results,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              summary,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aiVerifyNotice,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugsTab() {
    final l10n = AppLocalizationsExt.of(context);
    if (_patient == null || _patient!.diagnosis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.addDiagnosisForDrugs,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final severity = _results.isNotEmpty ? _results.first.severity : '';
    final suggestion = DrugEngine.getSuggestions(
      diagnosis: _patient!.diagnosis,
      severity: severity,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dx: ${suggestion.diagnosis}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _drugSection(l10n.firstLine, suggestion.firstLine,
              AppTheme.successColor),
          if (suggestion.secondLine.isNotEmpty) ...[
            const SizedBox(height: 12),
            _drugSection(l10n.secondLineAlternatives,
                suggestion.secondLine, AppTheme.warningColor),
          ],
          if (suggestion.adjuncts.isNotEmpty) ...[
            const SizedBox(height: 12),
            _drugSection(l10n.adjuncts, suggestion.adjuncts, AppTheme.accentColor),
          ],
          if (suggestion.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTheme.warningColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.notes,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            l10n.guidelineOnly,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _drugSection(String title, List<String> drugs, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        ...drugs.map((d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 8, color: color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(d, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),
      ],
    );
  }

  Future<void> _showEditDialog() async {
    final l10n = AppLocalizationsExt.of(context);
    final patient = _patient!;
    final nameCtrl = TextEditingController(text: patient.name);
    final ageCtrl = TextEditingController(text: patient.age.toString());
    final diagCtrl = TextEditingController(text: patient.diagnosis);
    final wardCtrl = TextEditingController(text: patient.ward);
    String gender = patient.gender;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.editPatient),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l10n.patientName),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.age),
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
                  onChanged: (v) =>
                      setDialogState(() => gender = v ?? 'Male'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: diagCtrl,
                  decoration: InputDecoration(labelText: l10n.diagnosis),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: wardCtrl,
                  decoration: InputDecoration(labelText: l10n.wardUnit),
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
                child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final age = int.tryParse(ageCtrl.text);
                if (age == null || age < 0 || age > 120) return;
                final updated = patient.copyWith(
                  name: nameCtrl.text.trim(),
                  age: age,
                  gender: gender,
                  diagnosis: diagCtrl.text.trim(),
                  ward: wardCtrl.text.trim(),
                );
                try {
                  await _db.updatePatient(updated);
                  if (ctx.mounted) {
                    nameCtrl.dispose();
                    ageCtrl.dispose();
                    diagCtrl.dispose();
                    wardCtrl.dispose();
                    Navigator.pop(ctx);
                  }
                  _load();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Failed to save: $e')),
                    );
                  }
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizationsExt.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePatientTitle),
        content: Text(l10n.deletePatientBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deletePatient(widget.patientId);
      if (mounted) Navigator.pop(context);
    }
  }
}
