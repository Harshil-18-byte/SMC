import 'package:flutter/material.dart';

/// System Alert Model - Infrastructure Focus
class SystemAlert {
  final String id;
  final String message;
  final String severity; // 'critical', 'warning', 'info'
  final DateTime timestamp;
  final bool isRead;

  SystemAlert({
    required this.id,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });

  factory SystemAlert.fromMap(Map<String, dynamic> map, String id) {
    return SystemAlert(
      id: id,
      message: map['message'] ?? '',
      severity: map['severity'] ?? 'info',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is String ? DateTime.parse(map['timestamp']) : (map['timestamp'] as dynamic).toDate())
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  Color get severityColor {
    switch (severity) {
      case 'critical':
        return const Color(0xFFFF4D4D);
      case 'warning':
        return const Color(0xFFFFAB00);
      default:
        return const Color(0xFF137fec);
    }
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

/// Asset Maintenance Status Model
class AssetStatus {
  final String id;
  final String name;
  final int healthScore;
  final int maxHealth;
  final int stabilityLevel; // percentage
  final int repairBacklogDays;
  final bool maintenanceLocked;
  final String? lockReason;

  AssetStatus({
    required this.id,
    required this.name,
    required this.healthScore,
    required this.maxHealth,
    required this.stabilityLevel,
    required this.repairBacklogDays,
    this.maintenanceLocked = false,
    this.lockReason,
  });

  factory AssetStatus.fromMap(Map<String, dynamic> map, String id) {
    return AssetStatus(
      id: id,
      name: map['name'] ?? '',
      healthScore: map['healthScore'] ?? map['bedAvailable'] ?? 0,
      maxHealth: map['maxHealth'] ?? map['bedTotal'] ?? 100,
      stabilityLevel: map['stabilityLevel'] ?? map['oxygenLevel'] ?? 0,
      repairBacklogDays: map['repairBacklogDays'] ?? map['triageWaitMinutes'] ?? 0,
      maintenanceLocked: map['maintenanceLocked'] ?? map['intakeLocked'] ?? false,
      lockReason: map['lockReason'],
    );
  }

  double get integrityPercentage => (healthScore / maxHealth) * 100;

  Color get statusColor {
    if (integrityPercentage < 40) return const Color(0xFFFF4D4D);
    if (integrityPercentage < 70) return const Color(0xFFFFAB00);
    return const Color(0xFF10B981);
  }
}

/// Command Center KPI Model - Infrastructure Focus
class InfraKPI {
  final int criticalDefects;
  final double infrastructureUptime; // percentage
  final double structuralRiskIndex; // 0-100

  InfraKPI({
    required this.criticalDefects,
    required this.infrastructureUptime,
    required this.structuralRiskIndex,
  });

  factory InfraKPI.fromMap(Map<String, dynamic> map) {
    return InfraKPI(
      criticalDefects: map['criticalDefects'] ?? map['activeCases'] ?? 0,
      infrastructureUptime: (map['infrastructureUptime'] ?? map['icuCapacity'] ?? 0.0).toDouble(),
      structuralRiskIndex: (map['structuralRiskIndex'] ?? map['siteStressIndex'] ?? 0.0).toDouble(),
    );
  }

  Color get riskColor {
    if (structuralRiskIndex > 80) return const Color(0xFFFF4D4D);
    if (structuralRiskIndex > 50) return const Color(0xFFFFAB00);
    return const Color(0xFF10B981);
  }
}
