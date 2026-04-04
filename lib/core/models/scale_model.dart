import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../theme/app_theme.dart';

enum ScaleType {
  bprs,     // Brief Psychiatric Rating Scale (24 items)
  phq9,     // Patient Health Questionnaire-9
  gad7,     // Generalized Anxiety Disorder-7
  hamd,     // Hamilton Depression Rating Scale
  ymrs,     // Young Mania Rating Scale
  ybocs,    // Yale-Brown Obsessive Compulsive Scale
  mmse,     // Mini-Mental State Examination
  cssrs,    // Columbia-Suicide Severity Rating Scale
}

class ScaleDefinition {
  final ScaleType type;
  final String name;
  final String description;
  final List<ScaleItem> items;
  final double maxScore;
  final List<SeverityLevel> severityLevels;

  const ScaleDefinition({
    required this.type,
    required this.name,
    required this.description,
    required this.items,
    required this.maxScore,
    required this.severityLevels,
  });

  SeverityLevel getSeverityLevel(double score) {
    for (final level in severityLevels) {
      if (score >= level.minScore && score <= level.maxScore) {
        return level;
      }
    }
    return severityLevels.first;
  }
}

class ScaleItem {
  final String id;
  final String question;
  final String? description;
  final List<ScaleOption> options;
  final int maxScore;

  const ScaleItem({
    required this.id,
    required this.question,
    this.description,
    required this.options,
    required this.maxScore,
  });
}

class ScaleOption {
  final int value;
  final String label;
  final String? description;

  const ScaleOption({
    required this.value,
    required this.label,
    this.description,
  });
}

class SeverityLevel {
  final String name;
  final double minScore;
  final double maxScore;
  final String description;
  final RiskLevel riskLevel;

  const SeverityLevel({
    required this.name,
    required this.minScore,
    required this.maxScore,
    required this.description,
    required this.riskLevel,
  });
}

class Assessment {
  final String id;
  final String patientId;
  final ScaleType scaleType;
  final Map<String, int> itemScores;
  final double totalScore;
  final SeverityLevel severityLevel;
  final RiskLevel riskLevel;
  final DateTime assessedAt;
  final String? notes;
  final String? aiSummary;
  final bool hasSuicideRisk;
  final List<String> alerts;

  Assessment({
    required this.id,
    required this.patientId,
    required this.scaleType,
    required this.itemScores,
    required this.totalScore,
    required this.severityLevel,
    required this.riskLevel,
    required this.assessedAt,
    this.notes,
    this.aiSummary,
    this.hasSuicideRisk = false,
    this.alerts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'scaleType': scaleType.name,
      'itemScores': jsonEncode(itemScores),
      'totalScore': totalScore,
      'severityLevel': severityLevel.name,
      'riskLevel': riskLevel.name,
      'assessedAt': assessedAt.toIso8601String(),
      'notes': notes,
      'aiSummary': aiSummary,
      'hasSuicideRisk': hasSuicideRisk ? 1 : 0,
      'alerts': jsonEncode(alerts),
    };
  }

  factory Assessment.fromMap(Map<String, dynamic> map) {
    // Parse itemScores from JSON string
    Map<String, int> itemScores = {};
    if (map['itemScores'] != null) {
      if (map['itemScores'] is String) {
        try {
          final decoded = jsonDecode(map['itemScores']) as Map<String, dynamic>;
          itemScores = decoded.map((key, value) => MapEntry(key, (value as num).toInt()));
        } catch (e) {
          debugPrint('Assessment.fromMap itemScores parse error: $e');
          itemScores = {};
        }
      } else if (map['itemScores'] is Map) {
        itemScores = Map<String, int>.from(map['itemScores']);
      }
    }

    // Parse alerts from JSON string
    List<String> alerts = [];
    if (map['alerts'] != null) {
      if (map['alerts'] is String) {
        try {
          final decoded = jsonDecode(map['alerts']) as List;
          alerts = decoded.map((e) => e.toString()).toList();
        } catch (e) {
          debugPrint('Assessment.fromMap alerts parse error: $e');
          alerts = [];
        }
      } else if (map['alerts'] is List) {
        alerts = List<String>.from(map['alerts']);
      }
    }

    // Parse hasSuicideRisk (stored as 0/1 in SQLite)
    bool hasSuicideRisk = false;
    if (map['hasSuicideRisk'] != null) {
      if (map['hasSuicideRisk'] is int) {
        hasSuicideRisk = map['hasSuicideRisk'] == 1;
      } else if (map['hasSuicideRisk'] is bool) {
        hasSuicideRisk = map['hasSuicideRisk'];
      }
    }

    return Assessment(
      id: map['id'],
      patientId: map['patientId'],
      scaleType: ScaleType.values.firstWhere((e) => e.name == map['scaleType']),
      itemScores: itemScores,
      totalScore: map['totalScore'],
      severityLevel: SeverityLevel(
        name: map['severityLevel'],
        minScore: 0,
        maxScore: 100,
        description: '',
        riskLevel: RiskLevel.values.firstWhere(
          (e) => e.name == map['riskLevel'],
          orElse: () => RiskLevel.none,
        ),
      ),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == map['riskLevel'],
        orElse: () => RiskLevel.none,
      ),
      assessedAt: DateTime.parse(map['assessedAt']),
      notes: map['notes'],
      aiSummary: map['aiSummary'],
      hasSuicideRisk: hasSuicideRisk,
      alerts: alerts,
    );
  }

  Assessment copyWith({
    String? id,
    String? patientId,
    ScaleType? scaleType,
    Map<String, int>? itemScores,
    double? totalScore,
    SeverityLevel? severityLevel,
    RiskLevel? riskLevel,
    DateTime? assessedAt,
    String? notes,
    String? aiSummary,
    bool? hasSuicideRisk,
    List<String>? alerts,
  }) {
    return Assessment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      scaleType: scaleType ?? this.scaleType,
      itemScores: itemScores ?? this.itemScores,
      totalScore: totalScore ?? this.totalScore,
      severityLevel: severityLevel ?? this.severityLevel,
      riskLevel: riskLevel ?? this.riskLevel,
      assessedAt: assessedAt ?? this.assessedAt,
      notes: notes ?? this.notes,
      aiSummary: aiSummary ?? this.aiSummary,
      hasSuicideRisk: hasSuicideRisk ?? this.hasSuicideRisk,
      alerts: alerts ?? this.alerts,
    );
  }
}