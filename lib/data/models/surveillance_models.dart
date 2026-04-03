import 'package:flutter/material.dart';

/// Disease Case Data Model
class DiseaseCaseData {
  final DateTime date;
  final int newCases;
  final int recoveredCases;
  final int activeCases;
  final int deaths;

  DiseaseCaseData({
    required this.date,
    required this.newCases,
    required this.recoveredCases,
    required this.activeCases,
    required this.deaths,
  });

  factory DiseaseCaseData.fromMap(Map<String, dynamic> map, String id) {
    return DiseaseCaseData(
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      newCases: map['newCases'] ?? 0,
      recoveredCases: map['recoveredCases'] ?? 0,
      activeCases: map['activeCases'] ?? 0,
      deaths: map['deaths'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'newCases': newCases,
      'recoveredCases': recoveredCases,
      'activeCases': activeCases,
      'deaths': deaths,
    };
  }
}

/// Geospatial Heatmap Zone Data
class ZoneHeatmapData {
  final String zoneId;
  final String zoneName;
  final int caseCount;
  final double latitude;
  final double longitude;
  final String severity; // 'low', 'medium', 'high', 'critical'

  ZoneHeatmapData({
    required this.zoneId,
    required this.zoneName,
    required this.caseCount,
    required this.latitude,
    required this.longitude,
    required this.severity,
  });

  factory ZoneHeatmapData.fromMap(Map<String, dynamic> map, String id) {
    return ZoneHeatmapData(
      zoneId: id,
      zoneName: map['zoneName'] ?? '',
      caseCount: map['caseCount'] ?? 0,
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      severity: map['severity'] ?? 'low',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'zoneName': zoneName,
      'caseCount': caseCount,
      'latitude': latitude,
      'longitude': longitude,
      'severity': severity,
    };
  }

  Color get severityColor {
    switch (severity) {
      case 'critical':
        return const Color(0xFFFF4D4D);
      case 'high':
        return const Color(0xFFFF8A00);
      case 'medium':
        return const Color(0xFFFFAB00);
      default:
        return const Color(0xFF10B981);
    }
  }
}

/// Raw Case Entry Model
class RawCaseEntry {
  final String id;
  final String patientId;
  final String disease;
  final String zone;
  final DateTime reportedDate;
  final String status; // 'active', 'recovered', 'deceased'
  final int age;
  final String gender;

  RawCaseEntry({
    required this.id,
    required this.patientId,
    required this.disease,
    required this.zone,
    required this.reportedDate,
    required this.status,
    required this.age,
    required this.gender,
  });

  factory RawCaseEntry.fromMap(Map<String, dynamic> map, String id) {
    return RawCaseEntry(
      id: id,
      patientId: map['patientId'] ?? '',
      disease: map['disease'] ?? 'Dengue',
      zone: map['zone'] ?? '',
      reportedDate: map['reportedDate'] != null
          ? DateTime.parse(map['reportedDate'])
          : DateTime.now(),
      status: map['status'] ?? 'active',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'disease': disease,
      'zone': zone,
      'reportedDate': reportedDate.toIso8601String(),
      'status': status,
      'age': age,
      'gender': gender,
    };
  }

  Color get statusColor {
    switch (status) {
      case 'recovered':
        return const Color(0xFF10B981);
      case 'deceased':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFFFFAB00);
    }
  }
}


