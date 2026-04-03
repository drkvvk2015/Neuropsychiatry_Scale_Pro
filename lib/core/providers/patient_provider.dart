import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/patient_model.dart';
import '../models/scale_model.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class PatientProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Patient> _patients = [];
  List<Assessment> _assessments = [];
  Patient? _selectedPatient;
  bool _isLoading = false;

  List<Patient> get patients => _patients;
  List<Assessment> get assessments => _assessments;
  Patient? get selectedPatient => _selectedPatient;
  bool get isLoading => _isLoading;

  List<Assessment> getPatientAssessments(String patientId) {
    return _assessments.where((a) => a.patientId == patientId).toList();
  }

  Future<void> loadPatients() async {
    _isLoading = true;
    notifyListeners();

    try {
      _patients = await _databaseService.getAllPatients();
      _assessments = await _databaseService.getAllAssessments();
    } catch (e) {
      debugPrint('Error loading patients: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPatient(Patient patient) async {
    try {
      await _databaseService.insertPatient(patient);
      await loadPatients();
    } catch (e) {
      debugPrint('Error adding patient: $e');
    }
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      final updated = patient.copyWith(updatedAt: DateTime.now());
      await _databaseService.updatePatient(updated);
      await loadPatients();
    } catch (e) {
      debugPrint('Error updating patient: $e');
    }
  }

  Future<void> deletePatient(String patientId) async {
    try {
      await _databaseService.deletePatient(patientId);
      await loadPatients();
    } catch (e) {
      debugPrint('Error deleting patient: $e');
    }
  }

  void selectPatient(Patient patient) {
    _selectedPatient = patient;
    notifyListeners();
  }

  void clearSelectedPatient() {
    _selectedPatient = null;
    notifyListeners();
  }

  Future<Patient?> createPatient({
    required String name,
    required int age,
    required String gender,
    String? phone,
    String? address,
    String? diagnosis,
    String? notes,
  }) async {
    final patient = Patient(
      id: const Uuid().v4(),
      name: name,
      age: age,
      gender: gender,
      phone: phone,
      address: address,
      diagnosis: diagnosis,
      notes: notes,
      createdAt: DateTime.now(),
    );

    await addPatient(patient);
    return patient;
  }

  // Get statistics
  int get totalPatients => _patients.length;

  int get assessmentsThisMonth {
    final now = DateTime.now();
    return _assessments.where((a) {
      return a.assessedAt.month == now.month && a.assessedAt.year == now.year;
    }).length;
  }

  int get highRiskPatients {
    final highRiskScaleTypes = {ScaleType.cssrs};
    return _assessments.where((a) {
      return highRiskScaleTypes.contains(a.scaleType) &&
          (a.riskLevel == RiskLevel.severe || a.riskLevel == RiskLevel.critical);
    }).length;
  }

  Map<ScaleType, int> get scaleUsageStats {
    final stats = <ScaleType, int>{};
    for (final assessment in _assessments) {
      stats[assessment.scaleType] = (stats[assessment.scaleType] ?? 0) + 1;
    }
    return stats;
  }

  // Get recent assessments
  List<Assessment> get recentAssessments {
    final sorted = List<Assessment>.from(_assessments)
      ..sort((a, b) => b.assessedAt.compareTo(a.assessedAt));
    return sorted.take(10).toList();
  }
}