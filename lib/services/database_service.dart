import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../models/patient.dart';
import '../models/scale_result.dart';

/// SQLite-based local storage service.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const _secureStorage = FlutterSecureStorage();
  static const _dbKeyName = 'neuroscale_db_key';
  static const _webPatientsKey = 'neuroscale_web_patients';
  static const _webResultsKey = 'neuroscale_web_results';

  Database? _db;
  SharedPreferences? _prefs;

  Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    final password = await _getOrCreateDatabaseKey();
    return openDatabase(
      path,
      password: password,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE patients (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            gender TEXT NOT NULL,
            diagnosis TEXT,
            ward TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE scale_results (
            id TEXT PRIMARY KEY,
            patient_id TEXT NOT NULL,
            scale_name TEXT NOT NULL,
            total_score INTEGER NOT NULL,
            severity TEXT NOT NULL,
            risk_level TEXT NOT NULL,
            item_scores TEXT,
            clinical_notes TEXT,
            assessed_at TEXT NOT NULL,
            FOREIGN KEY (patient_id) REFERENCES patients(id)
          )
        ''');
      },
    );
  }

  Future<String> _getOrCreateDatabaseKey() async {
    final existing = await _secureStorage.read(key: _dbKeyName);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = const Uuid().v4().replaceAll('-', '') + const Uuid().v4().replaceAll('-', '');
    await _secureStorage.write(key: _dbKeyName, value: generated);
    return generated;
  }

  Future<List<Patient>> _webPatients() async {
    final prefs = await _sharedPrefs;
    final raw = prefs.getString(_webPatientsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => Patient.fromMap(Map<String, dynamic>.from(entry as Map)))
        .toList();
  }

  Future<void> _saveWebPatients(List<Patient> patients) async {
    final prefs = await _sharedPrefs;
    await prefs.setString(
      _webPatientsKey,
      jsonEncode(patients.map((patient) => patient.toMap()).toList()),
    );
  }

  Future<List<ScaleResult>> _webResults() async {
    final prefs = await _sharedPrefs;
    final raw = prefs.getString(_webResultsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => ScaleResult.fromMap(Map<String, dynamic>.from(entry as Map)))
        .toList();
  }

  Future<void> _saveWebResults(List<ScaleResult> results) async {
    final prefs = await _sharedPrefs;
    await prefs.setString(
      _webResultsKey,
      jsonEncode(results.map((result) => result.toMap()).toList()),
    );
  }

  // ── Patient CRUD ─────────────────────────────────────────────────────────

  Future<void> insertPatient(Patient patient) async {
    if (kIsWeb) {
      final patients = await _webPatients();
      final next = patients.where((entry) => entry.id != patient.id).toList()..add(patient);
      await _saveWebPatients(next);
      return;
    }

    final database = await db;
    await database.insert('patients', patient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePatient(Patient patient) async {
    if (kIsWeb) {
      final patients = await _webPatients();
      final next = patients.map((entry) => entry.id == patient.id ? patient : entry).toList();
      await _saveWebPatients(next);
      return;
    }

    final database = await db;
    await database.update('patients', patient.toMap(),
        where: 'id = ?', whereArgs: [patient.id]);
  }

  Future<void> deletePatient(String id) async {
    if (kIsWeb) {
      final patients = await _webPatients();
      final results = await _webResults();
      await _saveWebPatients(patients.where((patient) => patient.id != id).toList());
      await _saveWebResults(results.where((result) => result.patientId != id).toList());
      return;
    }

    final database = await db;
    await database.delete('patients', where: 'id = ?', whereArgs: [id]);
    await database.delete('scale_results',
        where: 'patient_id = ?', whereArgs: [id]);
  }

  Future<List<Patient>> getAllPatients() async {
    if (kIsWeb) {
      final patients = await _webPatients();
      patients.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return patients;
    }

    final database = await db;
    final maps = await database.query('patients', orderBy: 'updated_at DESC');
    return maps.map(Patient.fromMap).toList();
  }

  Future<Patient?> getPatient(String id) async {
    if (kIsWeb) {
      final patients = await _webPatients();
      try {
        return patients.firstWhere((patient) => patient.id == id);
      } catch (_) {
        return null;
      }
    }

    final database = await db;
    final maps =
        await database.query('patients', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  // ── ScaleResult CRUD ─────────────────────────────────────────────────────

  Future<void> insertScaleResult(ScaleResult result) async {
    if (kIsWeb) {
      final results = await _webResults();
      final next = results.where((entry) => entry.id != result.id).toList()..add(result);
      await _saveWebResults(next);
      return;
    }

    final database = await db;
    await database.insert('scale_results', result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ScaleResult>> getResultsForPatient(String patientId) async {
    if (kIsWeb) {
      final results = await _webResults();
      return results.where((result) => result.patientId == patientId).toList()
        ..sort((a, b) => b.assessedAt.compareTo(a.assessedAt));
    }

    final database = await db;
    final maps = await database.query('scale_results',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'assessed_at DESC');
    return maps.map(ScaleResult.fromMap).toList();
  }

  Future<List<ScaleResult>> getResultsForScale(
      String patientId, String scaleName) async {
    if (kIsWeb) {
      final results = await _webResults();
      return results
          .where((result) => result.patientId == patientId && result.scaleName == scaleName)
          .toList()
        ..sort((a, b) => a.assessedAt.compareTo(b.assessedAt));
    }

    final database = await db;
    final maps = await database.query('scale_results',
        where: 'patient_id = ? AND scale_name = ?',
        whereArgs: [patientId, scaleName],
        orderBy: 'assessed_at ASC');
    return maps.map(ScaleResult.fromMap).toList();
  }

  Future<List<ScaleResult>> getAllResults() async {
    if (kIsWeb) {
      final results = await _webResults();
      results.sort((a, b) => b.assessedAt.compareTo(a.assessedAt));
      return results;
    }

    final database = await db;
    final maps =
        await database.query('scale_results', orderBy: 'assessed_at DESC');
    return maps.map(ScaleResult.fromMap).toList();
  }

  Future<void> deleteResult(String id) async {
    if (kIsWeb) {
      final results = await _webResults();
      await _saveWebResults(results.where((result) => result.id != id).toList());
      return;
    }

    final database = await db;
    await database.delete('scale_results', where: 'id = ?', whereArgs: [id]);
  }

  // ── Export ────────────────────────────────────────────────────────────────

  /// Returns CSV-formatted data for all results.
  Future<String> exportToCsv() async {
    final patients = await getAllPatients();
    final results = await getAllResults();
    final patientMap = {for (final p in patients) p.id: p};

    final rows = <List<String>>[
      [
        'Patient ID',
        'Name',
        'Age',
        'Gender',
        'Diagnosis',
        'Ward',
        'Scale',
        'Score',
        'Severity',
        'Risk Level',
        'Assessed At',
      ]
    ];

    for (final r in results) {
      final p = patientMap[r.patientId];
      rows.add([
        r.patientId,
        p?.name ?? '',
        p?.age.toString() ?? '',
        p?.gender ?? '',
        p?.diagnosis ?? '',
        p?.ward ?? '',
        r.scaleName,
        r.totalScore.toString(),
        r.severity,
        r.riskLevel,
        r.assessedAt.toIso8601String(),
      ]);
    }

    return rows.map((row) => row.map(_escapeCsv).join(',')).join('\n');
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
