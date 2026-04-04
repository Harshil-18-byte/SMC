import 'package:flutter/material.dart';

enum MedicationFrequency {
  daily,
  weekly,
  monthly,
}

/// Asset Maintenance / Medication Model (Refactoring to MaintenanceReminder)
/// Satisfies legacy clinical imports while providing infrastructure logic.
class AssetMedication {
  final String id;
  final String name;
  final String dosage; // Amount (e.g., 500mg or 5 liters)
  final MedicationFrequency frequency;
  final List<TimeOfDay> reminderTimes;
  final int dosesLeft;
  final int totalDoses;
  final String doctorName; // Assigned Inspector
  final String instructions;

  AssetMedication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.reminderTimes,
    required this.dosesLeft,
    required this.totalDoses,
    required this.doctorName,
    required this.instructions,
  });

  double get progress => totalDoses > 0 ? (dosesLeft / totalDoses) : 0.0;
  bool get isLow => dosesLeft <= 5;

  factory AssetMedication.fromMap(Map<String, dynamic> map, String id) {
    return AssetMedication(
      id: id,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: _parseFrequency(map['frequency']),
      reminderTimes: _parseTimes(map['reminderTimes']),
      dosesLeft: map['dosesLeft'] ?? 0,
      totalDoses: map['totalDoses'] ?? 30,
      doctorName: map['doctorName'] ?? 'Assigned Inspector',
      instructions: map['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency.toString().split('.').last,
      'reminderTimes': reminderTimes.map((t) => '${t.hour}:${t.minute}').toList(),
      'dosesLeft': dosesLeft,
      'totalDoses': totalDoses,
      'doctorName': doctorName,
      'instructions': instructions,
    };
  }

  static MedicationFrequency _parseFrequency(dynamic f) {
    if (f == 'weekly') return MedicationFrequency.weekly;
    if (f == 'monthly') return MedicationFrequency.monthly;
    return MedicationFrequency.daily;
  }

  static List<TimeOfDay> _parseTimes(dynamic t) {
    if (t == null || t is! List) return [const TimeOfDay(hour: 9, minute: 0)];
    return t.map((time) {
      final parts = (time as String).split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();
  }
}
