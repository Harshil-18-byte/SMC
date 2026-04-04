import 'package:flutter/material.dart';

/// System Inspection Metric Model
class SystemInspectionMetric {
  final String id;
  final String name;
  final double value;
  final String unit;
  final double threshold;
  final String status; // 'inspectiony', 'warning', 'critical'
  final DateTime lastUpdated;

  SystemInspectionMetric({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.threshold,
    required this.status,
    required this.lastUpdated,
  });

  factory SystemInspectionMetric.fromMap(Map<String, dynamic> map, String id) {
    return SystemInspectionMetric(
      id: id,
      name: map['name'] ?? '',
      value: (map['value'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      threshold: (map['threshold'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'inspectiony',
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'threshold': threshold,
      'status': status,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Color get statusColor {
    switch (status) {
      case 'critical':
        return const Color(0xFFFF4D4D);
      case 'warning':
        return const Color(0xFFFFAB00);
      default:
        return const Color(0xFF10B981);
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.check_circle;
    }
  }
}

/// Maintenance Task Model
class MaintenanceTask {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final String priority; // 'low', 'medium', 'high'
  final String status; // 'pending', 'in_progress', 'completed'
  final String assignedTo;

  MaintenanceTask({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.priority,
    required this.status,
    required this.assignedTo,
  });

  factory MaintenanceTask.fromMap(Map<String, dynamic> map, String id) {
    return MaintenanceTask(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      scheduledDate: map['scheduledDate'] != null
          ? DateTime.parse(map['scheduledDate'])
          : DateTime.now(),
      priority: map['priority'] ?? 'medium',
      status: map['status'] ?? 'pending',
      assignedTo: map['assignedTo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'priority': priority,
      'status': status,
      'assignedTo': assignedTo,
    };
  }

  Color get priorityColor {
    switch (priority) {
      case 'high':
        return const Color(0xFFFF4D4D);
      case 'medium':
        return const Color(0xFFFFAB00);
      default:
        return const Color(0xFF137fec);
    }
  }

  Color get statusColor {
    switch (status) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'in_progress':
        return const Color(0xFF137fec);
      default:
        return const Color(0xFF6B7280);
    }
  }

  bool get isOverdue {
    return status != 'completed' && scheduledDate.isBefore(DateTime.now());
  }
}


