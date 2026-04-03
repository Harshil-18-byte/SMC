import 'package:flutter/material.dart';

/// User Role Enum
enum UserRole {
  admin,
  fieldWorker,
  citizen,
  doctor,
  guest;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.fieldWorker:
        return 'Field Worker';
      case UserRole.citizen:
        return 'Citizen';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.guest:
        return 'Guest';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Command Center Access';
      case UserRole.fieldWorker:
        return 'Data Collection & Visits';
      case UserRole.citizen:
        return 'Health Records & Services';
      case UserRole.doctor:
        return 'Medical Consultation & Care';
      case UserRole.guest:
        return 'Trial Access';
    }
  }
}

/// Login Credentials Model
class LoginCredentials {
  final UserRole role;
  final String identifier; // Employee ID or Mobile
  final String password;

  LoginCredentials({
    required this.role,
    required this.identifier,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {'role': role.name, 'identifier': identifier, 'password': password};
  }
}

/// System Health Status
class SystemHealth {
  final bool isOnline;
  final int responseTime; // milliseconds
  final String status; // 'healthy', 'degraded', 'offline'
  final DateTime lastChecked;

  SystemHealth({
    required this.isOnline,
    required this.responseTime,
    required this.status,
    required this.lastChecked,
  });

  factory SystemHealth.fromMap(Map<String, dynamic> map) {
    return SystemHealth(
      isOnline: map['isOnline'] ?? false,
      responseTime: map['responseTime'] ?? 0,
      status: map['status'] ?? 'offline',
      lastChecked: map['lastChecked'] != null
          ? DateTime.parse(map['lastChecked'])
          : DateTime.now(),
    );
  }

  String get statusMessage {
    if (!isOnline) return 'System Offline';
    if (status == 'healthy') return 'All Systems Operational';
    if (status == 'degraded') return 'Performance Degraded';
    return 'System Unavailable';
  }

  Color get statusColor {
    if (!isOnline) return const Color(0xFFFF4D4D);
    if (status == 'healthy') return const Color(0xFF10B981);
    if (status == 'degraded') return const Color(0xFFFFAB00);
    return const Color(0xFFFF4D4D);
  }
}


