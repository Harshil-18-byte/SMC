import 'package:flutter/material.dart';

/// System Inspection Metric Model
class SystemInspectionMetric {
  final String id;
  final String name;
  final double value;
  final String unit;
  final double threshold;
  final String status; // 'inspectiony', 'critical', 'warning'
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
      name: map['name'] ?? 'Metric',
      value: (map['value'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      threshold: (map['threshold'] ?? 100.0).toDouble(),
      status: map['status'] ?? 'inspectiony',
      lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated']) : DateTime.now(),
    );
  }

  Color get statusColor {
    switch (status) {
      case 'critical': return Colors.red;
      case 'warning': return Colors.orange;
      default: return Colors.green;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'critical': return Icons.error_rounded;
      case 'warning': return Icons.warning_rounded;
      default: return Icons.check_circle_rounded;
    }
  }
}

/// Maintenance Task Model
class MaintenanceTask {
  final String id;
  final String title;
  final String description;
  final String status; // 'pending', 'in_progress', 'completed'
  final String priority; // 'high', 'medium', 'low'
  final DateTime scheduledDate;
  final String assignedTo;
  final bool isOverdue;

  MaintenanceTask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.scheduledDate,
    required this.assignedTo,
    this.isOverdue = false,
  });

  factory MaintenanceTask.fromMap(Map<String, dynamic> map, String id) {
    final schDate = map['scheduledDate'] != null ? DateTime.parse(map['scheduledDate']) : DateTime.now();
    return MaintenanceTask(
      id: id,
      title: map['title'] ?? 'Maintenance Task',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      priority: map['priority'] ?? 'medium',
      scheduledDate: schDate,
      assignedTo: map['assignedTo'] ?? 'Unassigned',
      isOverdue: map['isOverdue'] ?? schDate.isBefore(DateTime.now()),
    );
  }

  Color get statusColor {
    switch (status) {
      case 'completed': return Colors.green;
      case 'in_progress': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      default: return Colors.blue;
    }
  }
}
