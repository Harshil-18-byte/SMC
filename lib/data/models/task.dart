import 'package:flutter/material.dart';

/// Task Model
/// Represents a field worker's assigned task/visit
class Task {
  final String id;
  final String householdId;
  final String title;
  final String description;
  final String priority; // 'PRIORITY', 'ROUTINE', 'SURVEY'
  final String imageUrl;
  final bool isCompleted;
  final DateTime assignedDate;
  final String? notes;
  final double latitude;
  final double longitude;

  Task({
    required this.id,
    required this.householdId,
    required this.title,
    required this.description,
    required this.priority,
    required this.imageUrl,
    this.isCompleted = false,
    required this.assignedDate,
    this.notes,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  // Create from Firestore document
  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      householdId: map['householdId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: map['priority'] ?? 'ROUTINE',
      imageUrl: map['imageUrl'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      assignedDate: map['assignedDate'] != null
          ? DateTime.parse(map['assignedDate'])
          : DateTime.now(),
      notes: map['notes'],
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'householdId': householdId,
      'title': title,
      'description': description,
      'priority': priority,
      'imageUrl': imageUrl,
      'isCompleted': isCompleted,
      'assignedDate': assignedDate.toIso8601String(),
      'notes': notes,
    };
  }

  // Get priority color
  TaskPriorityStyle getPriorityStyle() {
    switch (priority) {
      case 'PRIORITY':
        return TaskPriorityStyle(
          bgColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFB45309),
          darkBgColor: const Color(0xFFB45309).withValues(alpha: 0.2),
          darkTextColor: const Color(0xFFFBBF24),
        );
      case 'SURVEY':
        return TaskPriorityStyle(
          bgColor: const Color(0xFFECFDF5),
          textColor: const Color(0xFF059669),
          darkBgColor: const Color(0xFF059669).withValues(alpha: 0.2),
          darkTextColor: const Color(0xFF34D399),
        );
      default: // ROUTINE
        return TaskPriorityStyle(
          bgColor: const Color(0xFFF1F5F9), // Slate
          textColor: const Color(0xFF475569), // Steel
          darkBgColor: const Color(0xFF334155).withValues(alpha: 0.3),
          darkTextColor: const Color(0xFF94A3B8),
        );
    }
  }
}

class TaskPriorityStyle {
  final Color bgColor;
  final Color textColor;
  final Color darkBgColor;
  final Color darkTextColor;

  TaskPriorityStyle({
    required this.bgColor,
    required this.textColor,
    required this.darkBgColor,
    required this.darkTextColor,
  });
}


