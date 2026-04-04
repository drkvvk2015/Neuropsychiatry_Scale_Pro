import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants.dart';
import '../models/patient.dart';
import '../models/scale_result.dart';

/// SQLite-based local storage service.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return openDatabase(
      path,
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

  // ── Patient CRUD ─────────────────────────────────────────────────────────

  Future<void> insertPatient(Patient patient) async {
    final database = await db;
    await database.insert('patients', patient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePatient(Patient patient) async {
    final database = await db;
    await database.update('patients', patient.toMap(),
        where: 'id = ?', whereArgs: [patient.id]);
  }

  Future<void> deletePatient(String id) async {
    final database = await db;
    await database.delete('patients', where: 'id = ?', whereArgs: [id]);
    await database.delete('scale_results',
        where: 'patient_id = ?', whereArgs: [id]);
  }

  Future<List<Patient>> getAllPatients() async {
    final database = await db;
    final maps = await database.query('patients', orderBy: 'updated_at DESC');
    return maps.map(Patient.fromMap).toList();
  }

  Future<Patient?> getPatient(String id) async {
    final database = await db;
    final maps =
        await database.query('patients', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  // ── ScaleResult CRUD ─────────────────────────────────────────────────────

  Future<void> insertScaleResult(ScaleResult result) async {
    final database = await db;
    await database.insert('scale_results', result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ScaleResult>> getResultsForPatient(String patientId) async {
    final database = await db;
    final maps = await database.query('scale_results',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'assessed_at DESC');
    return maps.map(ScaleResult.fromMap).toList();
  }

  /// Returns the single most-recent result per patient for a list of patient IDs.
  /// Uses one SQL query instead of one query per patient (avoids N+1 problem).
  /// The returned map contains an entry for every supplied patient ID;
  /// the value is null when no assessment has been recorded for that patient.
  Future<Map<String, ScaleResult?>> getLatestResultsForPatients(
      List<String> patientIds) async {
    // Pre-populate with null so callers can distinguish "no result" from
    // "patient not queried".
    final result = <String, ScaleResult?>{for (final id in patientIds) id: null};
    if (patientIds.isEmpty) return result;

    final database = await db;
    // Build one placeholder per patient ID for parameterized binding.
    // Parameters are passed separately to prevent SQL injection.
    final placeholders = List.filled(patientIds.length, '?').join(',');
    // Subquery selects the MAX assessed_at per patient; the join returns only
    // that single most-recent row per patient — no in-memory filtering needed.
    final maps = await database.rawQuery(
      'SELECT sr.* FROM scale_results sr '
      'INNER JOIN ('
      '  SELECT patient_id, MAX(assessed_at) AS max_at '
      '  FROM scale_results '
      '  WHERE patient_id IN ($placeholders) '
      '  GROUP BY patient_id'
      ') latest ON sr.patient_id = latest.patient_id '
      '        AND sr.assessed_at = latest.max_at',
      patientIds,
    );
    for (final map in maps) {
      final pid = map['patient_id'] as String;
      result[pid] = ScaleResult.fromMap(map);
    }
    return result;
  }

  Future<List<ScaleResult>> getResultsForScale(
      String patientId, String scaleName) async {
    final database = await db;
    final maps = await database.query('scale_results',
        where: 'patient_id = ? AND scale_name = ?',
        whereArgs: [patientId, scaleName],
        orderBy: 'assessed_at ASC');
    return maps.map(ScaleResult.fromMap).toList();
  }

  Future<List<ScaleResult>> getAllResults() async {
    final database = await db;
    final maps =
        await database.query('scale_results', orderBy: 'assessed_at DESC');
    return maps.map(ScaleResult.fromMap).toList();
  }

  Future<void> deleteResult(String id) async {
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
