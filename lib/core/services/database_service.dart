import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/patient_model.dart';
import '../models/scale_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();
  
  factory DatabaseService() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('neuroscale.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const intTypeNullable = 'INTEGER';
    const realType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    // Patients table
    await db.execute('''
      CREATE TABLE patients (
        id $idType,
        name $textType,
        age $intType,
        gender $textType,
        phone $textTypeNullable,
        address $textTypeNullable,
        diagnosis $textTypeNullable,
        notes $textTypeNullable,
        createdAt $textType,
        updatedAt $textTypeNullable,
        photoUrl $textTypeNullable
      )
    ''');

    // Assessments table
    await db.execute('''
      CREATE TABLE assessments (
        id $idType,
        patientId $textType,
        scaleType $textType,
        itemScores $textType,
        totalScore $realType,
        severityLevel $textType,
        riskLevel $textType,
        assessedAt $textType,
        notes $textTypeNullable,
        aiSummary $textTypeNullable,
        hasSuicideRisk $boolType DEFAULT 0,
        alerts $textTypeNullable,
        FOREIGN KEY (patientId) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    // Create index for faster queries
    await db.execute('CREATE INDEX idx_assessments_patientId ON assessments(patientId)');
    await db.execute('CREATE INDEX idx_assessments_assessedAt ON assessments(assessedAt)');
    await db.execute('CREATE INDEX idx_assessments_scaleType ON assessments(scaleType)');
  }

  // Patient CRUD operations
  Future<Patient> insertPatient(Patient patient) async {
    final db = await database;
    await db.insert('patients', patient.toMap());
    return patient;
  }

  Future<Patient> updatePatient(Patient patient) async {
    final db = await database;
    await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
    return patient;
  }

  Future<void> deletePatient(String patientId) async {
    final db = await database;
    // Delete assessments first (or rely on CASCADE if supported)
    await db.delete('assessments', where: 'patientId = ?', whereArgs: [patientId]);
    await db.delete('patients', where: 'id = ?', whereArgs: [patientId]);
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await database;
    final maps = await db.query('patients', orderBy: 'createdAt DESC');
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  Future<Patient?> getPatient(String patientId) async {
    final db = await database;
    final maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [patientId],
    );
    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  // Assessment CRUD operations
  Future<Assessment> insertAssessment(Assessment assessment) async {
    final db = await database;
    await db.insert('assessments', assessment.toMap());
    return assessment;
  }

  Future<void> deleteAssessment(String assessmentId) async {
    final db = await database;
    await db.delete('assessments', where: 'id = ?', whereArgs: [assessmentId]);
  }

  Future<List<Assessment>> getAllAssessments() async {
    final db = await database;
    final maps = await db.query('assessments', orderBy: 'assessedAt DESC');
    return maps.map((map) => Assessment.fromMap(map)).toList();
  }

  Future<List<Assessment>> getAssessmentsByPatient(String patientId) async {
    final db = await database;
    final maps = await db.query(
      'assessments',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'assessedAt DESC',
    );
    return maps.map((map) => Assessment.fromMap(map)).toList();
  }

  Future<List<Assessment>> getAssessmentsByScale(ScaleType scaleType) async {
    final db = await database;
    final maps = await db.query(
      'assessments',
      where: 'scaleType = ?',
      whereArgs: [scaleType.name],
      orderBy: 'assessedAt DESC',
    );
    return maps.map((map) => Assessment.fromMap(map)).toList();
  }

  Future<List<Assessment>> getRecentAssessments({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'assessments',
      orderBy: 'assessedAt DESC',
      limit: limit,
    );
    return maps.map((map) => Assessment.fromMap(map)).toList();
  }

  // Analytics queries
  Future<Map<String, int>> getScaleUsageStats() async {
    final db = await database;
    final result = <String, int>{};
    
    for (final scaleType in ScaleType.values) {
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM assessments WHERE scaleType = ?',
        [scaleType.name],
      ));
      result[scaleType.name] = count ?? 0;
    }
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getMonthlyAssessmentTrend({int months = 6}) async {
    final db = await database;
    final now = DateTime.now();
    final results = <Map<String, dynamic>>[];
    
    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final nextDate = DateTime(date.year, date.month + 1, 1);
      
      final count = Sqflite.firstIntValue(await db.rawQuery(
        '''SELECT COUNT(*) FROM assessments 
           WHERE assessedAt >= ? AND assessedAt < ?''',
        [date.toIso8601String(), nextDate.toIso8601String()],
      ));
      
      results.add({
        'month': '${date.year}-${date.month.toString().padLeft(2, '0')}',
        'count': count ?? 0,
      });
    }
    
    return results;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}