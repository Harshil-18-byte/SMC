import 'package:flutter/material.dart';

/// Audit Log Entry Model
class AuditLogEntry {
  final String id;
  final String action;
  final String actorId;
  final String actorName;
  final DateTime timestamp;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final Map<String, dynamic> metadata;

  AuditLogEntry({
    required this.id,
    required this.action,
    required this.actorId,
    required this.actorName,
    required this.timestamp,
    this.oldValue,
    this.newValue,
    required this.metadata,
  });

  factory AuditLogEntry.fromMap(Map<String, dynamic> map, String id) {
    return AuditLogEntry(
      id: id,
      action: map['action'] ?? '',
      actorId: map['actorId'] ?? '',
      actorName: map['actorName'] ?? 'Unknown',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      oldValue: map['oldValue'] as Map<String, dynamic>?,
      newValue: map['newValue'] as Map<String, dynamic>?,
      metadata: map['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'actorId': actorId,
      'actorName': actorName,
      'timestamp': timestamp.toIso8601String(),
      'oldValue': oldValue,
      'newValue': newValue,
      'metadata': metadata,
    };
  }

  Color get actionColor {
    if (action.contains('DELETE') || action.contains('SUSPEND')) {
      return const Color(0xFFFF4D4D);
    } else if (action.contains('CREATE') || action.contains('APPROVE')) {
      return const Color(0xFF10B981);
    } else if (action.contains('UPDATE') || action.contains('CHANGE')) {
      return const Color(0xFFFFAB00);
    }
    return const Color(0xFF137fec);
  }

  IconData get actionIcon {
    if (action.contains('DELETE')) return Icons.delete;
    if (action.contains('CREATE')) return Icons.add_circle;
    if (action.contains('UPDATE')) return Icons.edit;
    if (action.contains('LOCK')) return Icons.lock;
    if (action.contains('SUSPEND')) return Icons.block;
    if (action.contains('ALERT')) return Icons.campaign;
    if (action.contains('ROLE')) return Icons.swap_horiz;
    return Icons.info;
  }

  String getFormattedTimestamp() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String getFullTimestamp() {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}


