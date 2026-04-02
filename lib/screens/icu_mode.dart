import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/scoring_engine.dart';
import '../models/patient.dart';
import '../models/scale_result.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/alert_banner.dart';

/// ICU Mode — ultra-fast tap-based scoring for emergency/ward use.
class IcuModeScreen extends StatefulWidget {
  const IcuModeScreen({super.key});

  @override
  State<IcuModeScreen> createState() => _IcuModeScreenState();
}

class _IcuModeScreenState extends State<IcuModeScreen> {
  final _db = DatabaseService();

  // Step tracking
  int _step = 0; // 0=select patient, 1=select scale, 2=score, 3=result
  Patient? _selectedPatient;
  String? _selectedScale;
  Map<String, int> _scores = {};
  List<ScaleItem> _items = [];
  int _currentItemIndex = 0;
  bool _saving = false;

  List<Patient> _patients = [];
  bool _loadingPatients = true;

  static const _quickScales = [
    AppConstants.scaleBPRS,
    AppConstants.scalePHQ9,
    AppConstants.scaleGAD7,
    AppConstants.scaleCSSRS,
    AppConstants.scaleHAMD,
    AppConstants.scaleYMRS,
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final patients = await _db.getAllPatients();
    if (mounted) {
      setState(() {
        _patients = patients;
        _loadingPatients = false;
      });
    }
  }

  void _selectPatient(Patient p) {
    setState(() {
      _selectedPatient = p;
      _step = 1;
    });
  }

  void _selectScale(String scale) {
    final items = ScoringEngine.getItems(scale);
    setState(() {
      _selectedScale = scale;
      _items = items;
      _scores = {for (final item in items) item.key: item.minScore};
      _currentItemIndex = 0;
      _step = 2;
    });
  }

  void _setScore(int value) {
    final item = _items[_currentItemIndex];
    setState(() {
      _scores[item.key] = value;
      if (_currentItemIndex < _items.length - 1) {
        _currentItemIndex++;
      } else {
        _step = 3;
      }
    });
  }

  int get _totalScore => _scores.values.fold(0, (s, v) => s + v);

  String get _severity {
    if (_selectedScale == AppConstants.scaleCSSRS) {
      return ScoringEngine.cssrsRisk(_scores);
    }
    return ScoringEngine.getSeverity(_selectedScale!, _totalScore);
  }

  String get _riskLevel {
    if (_selectedScale == AppConstants.scaleCSSRS) return _severity;
    switch (_severity) {
      case AppConstants.severityVerySevere:
        return AppConstants.riskHigh;
      case AppConstants.severitySevere:
        return AppConstants.riskModerate;
      default:
        return AppConstants.riskLow;
    }
  }

  Future<void> _saveResult() async {
    if (_selectedPatient == null || _selectedScale == null) return;
    setState(() => _saving = true);
    final result = ScaleResult(
      patientId: _selectedPatient!.id,
      scaleName: _selectedScale!,
      totalScore: _totalScore,
      severity: _severity,
      riskLevel: _riskLevel,
      itemScores: Map.from(_scores),
    );
    await _db.insertScaleResult(result);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Saved: $_selectedScale — Score: $_totalScore'),
        backgroundColor: AppTheme.successColor,
      ));
      // Reset for next patient
      setState(() {
        _step = 0;
        _selectedPatient = null;
        _selectedScale = null;
        _scores = {};
        _currentItemIndex = 0;
      });
    }
  }

  void _reset() {
    setState(() {
      _step = 0;
      _selectedPatient = null;
      _selectedScale = null;
      _scores = {};
      _currentItemIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.yellow),
            const SizedBox(width: 8),
            const Text('ICU Mode',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (_step > 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _reset,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildPatientSelect();
      case 1:
        return _buildScaleSelect();
      case 2:
        return _buildScoring();
      case 3:
        return _buildResult();
      default:
        return _buildPatientSelect();
    }
  }

  Widget _buildPatientSelect() {
    return Column(
      key: const ValueKey('patient'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader('Step 1 / 3', 'Select Patient', Icons.person),
        Expanded(
          child: _loadingPatients
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _patients.isEmpty
                  ? Center(
                      child: Text(
                        'No patients found.\nAdd patients from Dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _patients.length,
                      itemBuilder: (ctx, i) {
                        final p = _patients[i];
                        return _icuTile(
                          onTap: () => _selectPatient(p),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Text(p.name[0].toUpperCase(),
                                  style:
                                      const TextStyle(color: Colors.white)),
                            ),
                            title: Text(p.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${p.age}Y • ${p.gender}${p.ward.isNotEmpty ? " • ${p.ward}" : ""}',
                              style: const TextStyle(color: Colors.white60),
                            ),
                            trailing: const Icon(Icons.chevron_right,
                                color: Colors.white54),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildScaleSelect() {
    return Column(
      key: const ValueKey('scale'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader('Step 2 / 3', 'Select Scale', Icons.assessment),
        _patientChip(),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: _quickScales
                .map((s) => _scaleButton(s))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _scaleButton(String scale) {
    final isCssrs = scale == AppConstants.scaleCSSRS;
    return GestureDetector(
      onTap: () => _selectScale(scale),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCssrs
                ? [AppTheme.dangerColor, const Color(0xFF880E4F)]
                : [AppTheme.primaryColor, AppTheme.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isCssrs ? AppTheme.dangerColor : AppTheme.primaryColor)
                  .withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCssrs ? Icons.emergency : Icons.assignment,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(scale,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Text(
                '${ScoringEngine.getItems(scale).length} items',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoring() {
    final item = _items[_currentItemIndex];
    final progress = (_currentItemIndex + 1) / _items.length;

    return Column(
      key: ValueKey('score_$_currentItemIndex'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader(
            '${_currentItemIndex + 1} / ${_items.length}',
            _selectedScale!,
            Icons.edit),
        _patientChip(),
        // Progress
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white12,
          valueColor:
              const AlwaysStoppedAnimation<Color>(Colors.yellow),
          minHeight: 4,
        ),
        const SizedBox(height: 16),
        // Question
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            item.question,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        // Score buttons
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount:
                  item.labels.length <= 4 ? item.labels.length : 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: List.generate(
                item.maxScore - item.minScore + 1,
                (i) {
                  final value = item.minScore + i;
                  final label = i < item.labels.length
                      ? item.labels[i]
                      : value.toString();
                  return _scoreButton(value, label);
                },
              ),
            ),
          ),
        ),
        // Back button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextButton(
            onPressed: () {
              if (_currentItemIndex > 0) {
                setState(() => _currentItemIndex--);
              } else {
                setState(() => _step = 1);
              }
            },
            child: const Text('← Back',
                style: TextStyle(color: Colors.white54)),
          ),
        ),
      ],
    );
  }

  Widget _scoreButton(int value, String label) {
    return GestureDetector(
      onTap: () => _setScore(value),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$value',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            if (label != value.toString())
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final severityColor = _selectedScale == AppConstants.scaleCSSRS
        ? AppTheme.riskColor(_riskLevel)
        : AppTheme.severityColor(_severity);
    final isCritical = _riskLevel == AppConstants.riskCritical ||
        _riskLevel == AppConstants.riskHigh;

    return Column(
      key: const ValueKey('result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader('Result', _selectedScale!, Icons.check_circle),
        if (isCritical)
          AlertBanner(
            riskLevel: _riskLevel,
            message: 'Urgent intervention required',
          ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Score circle
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: severityColor.withOpacity(0.15),
                    border:
                        Border.all(color: severityColor, width: 4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_totalScore',
                        style: TextStyle(
                            color: severityColor,
                            fontSize: 42,
                            fontWeight: FontWeight.bold),
                      ),
                      Text('Score',
                          style: TextStyle(
                              color: severityColor.withOpacity(0.8))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _severity,
                  style: TextStyle(
                      color: severityColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                if (_selectedScale == AppConstants.scaleCSSRS)
                  Text(_riskLevel,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  _selectedPatient?.name ?? '',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: _saving ? null : _saveResult,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text('Save & Continue'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppTheme.successColor,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _reset,
                child: const Text('← New Patient',
                    style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepHeader(String step, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.yellow, size: 20),
          const SizedBox(width: 8),
          Text(step,
              style:
                  const TextStyle(color: Colors.yellow, fontSize: 12)),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _patientChip() {
    if (_selectedPatient == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Chip(
        backgroundColor: Colors.white12,
        label: Text(
          '👤 ${_selectedPatient!.name}  •  ${_selectedPatient!.age}Y',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        avatar: const Icon(Icons.person, color: Colors.white54, size: 16),
      ),
    );
  }

  Widget _icuTile({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: child,
      ),
    );
  }
}
