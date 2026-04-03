import 'package:flutter/material.dart';

/// System Alert Model
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
          ? DateTime.parse(map['timestamp'])
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

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Hospital Intake Status Model
class HospitalIntakeStatus {
  final String id;
  final String name;
  final int bedAvailable;
  final int bedTotal;
  final int oxygenLevel; // percentage
  final int triageWaitMinutes;
  final bool intakeLocked;
  final String? lockReason;
  final double latitude;
  final double longitude;

  HospitalIntakeStatus({
    required this.id,
    required this.name,
    required this.bedAvailable,
    required this.bedTotal,
    required this.oxygenLevel,
    required this.triageWaitMinutes,
    this.intakeLocked = false,
    this.lockReason,
    this.latitude = 17.6599, // Default Bharat
    this.longitude = 75.9064, // Default Bharat
  });

  factory HospitalIntakeStatus.fromMap(Map<String, dynamic> map, String id) {
    return HospitalIntakeStatus(
      id: id,
      name: map['name'] ?? '',
      bedAvailable: map['bedAvailable'] ?? 0,
      bedTotal: map['bedTotal'] ?? 0,
      oxygenLevel: map['oxygenLevel'] ?? 0,
      triageWaitMinutes: map['triageWaitMinutes'] ?? 0,
      intakeLocked: map['intakeLocked'] ?? false,
      lockReason: map['lockReason'],
      latitude: (map['latitude'] ?? 17.6599).toDouble(),
      longitude: (map['longitude'] ?? 75.9064).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bedAvailable': bedAvailable,
      'bedTotal': bedTotal,
      'oxygenLevel': oxygenLevel,
      'triageWaitMinutes': triageWaitMinutes,
      'intakeLocked': intakeLocked,
      'lockReason': lockReason,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  double get bedOccupancyPercentage {
    if (bedTotal == 0) return 0;
    return ((bedTotal - bedAvailable) / bedTotal) * 100;
  }

  Color get statusColor {
    if (intakeLocked) return const Color(0xFFFF4D4D);
    if (bedOccupancyPercentage > 90) return const Color(0xFFFF4D4D);
    if (bedOccupancyPercentage > 75) return const Color(0xFFFFAB00);
    return const Color(0xFF10B981);
  }

  String get statusText {
    if (intakeLocked) return 'LOCKED';
    if (bedOccupancyPercentage > 90) return 'CRITICAL';
    if (bedOccupancyPercentage > 75) return 'HIGH';
    return 'NORMAL';
  }
}

/// Command Center KPI Model
class CommandCenterKPI {
  final int activeCases;
  final double icuCapacity; // percentage
  final double hospitalStressIndex; // 0-100

  CommandCenterKPI({
    required this.activeCases,
    required this.icuCapacity,
    required this.hospitalStressIndex,
  });

  factory CommandCenterKPI.fromMap(Map<String, dynamic> map) {
    return CommandCenterKPI(
      activeCases: map['activeCases'] ?? 0,
      icuCapacity: (map['icuCapacity'] ?? 0.0).toDouble(),
      hospitalStressIndex: (map['hospitalStressIndex'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activeCases': activeCases,
      'icuCapacity': icuCapacity,
      'hospitalStressIndex': hospitalStressIndex,
    };
  }

  Color get stressColor {
    if (hospitalStressIndex > 80) return const Color(0xFFFF4D4D);
    if (hospitalStressIndex > 60) return const Color(0xFFFFAB00);
    return const Color(0xFF10B981);
  }

  String get stressLevel {
    if (hospitalStressIndex > 80) return 'CRITICAL';
    if (hospitalStressIndex > 60) return 'ELEVATED';
    return 'NORMAL';
  }
}


