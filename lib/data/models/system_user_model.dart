import 'package:flutter/material.dart';

/// System User Model
class SystemUser {
  final String id;
  final String name;
  final String role; // 'Admin', 'Field Worker', 'Citizen'
  final String status; // 'Active', 'Suspended'
  final DateTime? lastLogin;
  final String email;
  final String phone;

  SystemUser({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    this.lastLogin,
    required this.email,
    required this.phone,
  });

  factory SystemUser.fromMap(Map<String, dynamic> map, String id) {
    return SystemUser(
      id: id,
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      status: map['status'] ?? 'Active',
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'])
          : null,
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'status': status,
      'lastLogin': lastLogin?.toIso8601String(),
      'email': email,
      'phone': phone,
    };
  }

  Color get statusColor {
    return status == 'Active'
        ? const Color(0xFF10B981)
        : const Color(0xFFFF4D4D);
  }

  Color get roleColor {
    switch (role) {
      case 'Admin':
        return const Color(0xFFFF4D4D);
      case 'Field Worker':
        return const Color(0xFF137fec);
      default:
        return const Color(0xFF10B981);
    }
  }

  String getLastLoginText() {
    if (lastLogin == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastLogin!);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}


