import 'package:uuid/uuid.dart';

class ScaleResult {
  final String id;
  final String patientId;
  final String scaleName;
  final int totalScore;
  final String severity;
  final String riskLevel;
  final Map<String, int> itemScores;
  final String clinicalNotes;
  final DateTime assessedAt;

  ScaleResult({
    String? id,
    required this.patientId,
    required this.scaleName,
    required this.totalScore,
    required this.severity,
    required this.riskLevel,
    required this.itemScores,
    this.clinicalNotes = '',
    DateTime? assessedAt,
  })  : id = id ?? const Uuid().v4(),
        assessedAt = assessedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'scale_name': scaleName,
      'total_score': totalScore,
      'severity': severity,
      'risk_level': riskLevel,
      'item_scores': itemScores.entries
          .map((e) => '${e.key}:${e.value}')
          .join(','),
      'clinical_notes': clinicalNotes,
      'assessed_at': assessedAt.toIso8601String(),
    };
  }

  factory ScaleResult.fromMap(Map<String, dynamic> map) {
    final rawItems = map['item_scores'] as String? ?? '';
    final itemScores = <String, int>{};
    if (rawItems.isNotEmpty) {
      for (final entry in rawItems.split(',')) {
        final parts = entry.split(':');
        if (parts.length == 2) {
          itemScores[parts[0]] = int.tryParse(parts[1]) ?? 0;
        }
      }
    }
    return ScaleResult(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      scaleName: map['scale_name'] as String,
      totalScore: map['total_score'] as int,
      severity: map['severity'] as String,
      riskLevel: map['risk_level'] as String,
      itemScores: itemScores,
      clinicalNotes: map['clinical_notes'] as String? ?? '',
      assessedAt: DateTime.parse(map['assessed_at'] as String),
    );
  }
}
