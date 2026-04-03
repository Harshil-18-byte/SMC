import 'package:flutter/material.dart';

enum MedicationFrequency { daily, weekly, asNeeded }

class PatientMedication {
  final String id;
  final String name;
  final String dosage; // e.g., "500mg"
  final MedicationFrequency frequency;
  final List<TimeOfDay> reminderTimes;
  int dosesLeft;
  final int totalDoses;
  final String doctorName;
  final String instructions; // e.g., "Take with food"

  PatientMedication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.reminderTimes,
    required this.dosesLeft,
    required this.totalDoses,
    required this.doctorName,
    this.instructions = '',
  });

  // Helper getters
  double get progress => totalDoses > 0 ? dosesLeft / totalDoses : 0.0;

  bool get isLow => dosesLeft <= 5;

  factory PatientMedication.fromMap(Map<String, dynamic> map, String id) {
    return PatientMedication(
      id: id,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: MedicationFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == (map['frequency'] ?? 'daily'),
        orElse: () => MedicationFrequency.daily,
      ),
      reminderTimes: (map['reminderTimes'] as List<dynamic>? ?? []).map((t) {
        final parts = (t as String).split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList(),
      dosesLeft: map['dosesLeft'] ?? 0,
      totalDoses: map['totalDoses'] ?? 0,
      doctorName: map['doctorName'] ?? '',
      instructions: map['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency.toString().split('.').last,
      'reminderTimes': reminderTimes
          .map((t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}')
          .toList(),
      'dosesLeft': dosesLeft,
      'totalDoses': totalDoses,
      'doctorName': doctorName,
      'instructions': instructions,
    };
  }
}


