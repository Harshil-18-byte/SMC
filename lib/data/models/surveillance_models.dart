import 'package:flutter/material.dart';

/// Defect Trend Data Model - Infrastructure Focus
class DefectCaseData {
  final DateTime date;
  final int newDefects;
  final int resolvedDefects;
  final int pendingDefects;
  final int criticalFailures;

  DefectCaseData({
    required this.date,
    required this.newDefects,
    required this.resolvedDefects,
    required this.pendingDefects,
    required this.criticalFailures,
  });

  factory DefectCaseData.fromMap(Map<String, dynamic> map, String id) {
    return DefectCaseData(
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      newDefects: map['newDefects'] ?? map['newCases'] ?? 0,
      resolvedDefects: map['resolvedDefects'] ?? map['recoveredCases'] ?? 0,
      pendingDefects: map['pendingDefects'] ?? map['activeCases'] ?? 0,
      criticalFailures: map['criticalFailures'] ?? map['deaths'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'newDefects': newDefects,
      'resolvedDefects': resolvedDefects,
      'pendingDefects': pendingDefects,
      'criticalFailures': criticalFailures,
    };
  }
}

/// Geospatial Heatmap Zone Data - Asset Risk focus
class ZoneHeatmapData {
  final String zoneId;
  final String zoneName;
  final int defectCount;
  final double latitude;
  final double longitude;
  final String riskLevel; // 'low', 'medium', 'high', 'critical'

  ZoneHeatmapData({
    required this.zoneId,
    required this.zoneName,
    required this.defectCount,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
  });

  factory ZoneHeatmapData.fromMap(Map<String, dynamic> map, String id) {
    return ZoneHeatmapData(
      zoneId: id,
      zoneName: map['zoneName'] ?? '',
      defectCount: map['defectCount'] ?? map['caseCount'] ?? 0,
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      riskLevel: map['riskLevel'] ?? map['severity'] ?? 'low',
    );
  }

  Color get riskColor {
    switch (riskLevel) {
      case 'critical': return const Color(0xFFFF4D4D);
      case 'high': return const Color(0xFFFF8A00);
      case 'medium': return const Color(0xFFFFAB00);
      default: return const Color(0xFF10B981);
    }
  }
}

/// Raw Asset Defect Entry
class RawCaseEntry {
  final String id;
  final String assetId;
  final String defectType;
  final String zone;
  final DateTime reportedDate;
  final String status; // 'pending', 'resolved', 'critical'
  final String severity; // 'S1', 'S2', 'S3'

  RawCaseEntry({
    required this.id,
    required this.assetId,
    required this.defectType,
    required this.zone,
    required this.reportedDate,
    required this.status,
    required this.severity,
  });

  factory RawCaseEntry.fromMap(Map<String, dynamic> map, String id) {
    return RawCaseEntry(
      id: id,
      assetId: map['assetId'] ?? '',
      defectType: map['defectType'] ?? map['defect'] ?? 'Structural',
      zone: map['zone'] ?? 'Unknown',
      reportedDate: map['reportedDate'] != null 
          ? (map['reportedDate'] is String ? DateTime.parse(map['reportedDate']) : (map['reportedDate'] as dynamic).toDate())
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      severity: map['severity'] ?? 'S2',
    );
  }

  Color get statusColor {
    switch (status) {
      case 'resolved': return const Color(0xFF10B981);
      case 'critical': return const Color(0xFFFF4D4D);
      default: return const Color(0xFFFFAB00);
    }
  }
}
