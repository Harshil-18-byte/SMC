import 'package:flutter/material.dart';

/// User Role Enum
enum UserRole {
  superAdmin, // National Level
  stateAdmin, // State Level
  cityAdmin, // City/Municipal Level
  fieldInspector, // Field Officers
  viewer; // Guest/Citizen view

  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'National Admin';
      case UserRole.stateAdmin:
        return 'State Admin';
      case UserRole.cityAdmin:
        return 'City Admin';
      case UserRole.fieldInspector:
        return 'Field Inspector';
      case UserRole.viewer:
        return 'Compliance Viewer';
    }
  }

  String get description {
    switch (this) {
      case UserRole.superAdmin:
        return 'National Infrastructure Monitoring';
      case UserRole.stateAdmin:
        return 'Regional Compliance Control';
      case UserRole.cityAdmin:
        return 'City-wide Asset Management';
      case UserRole.fieldInspector:
        return 'Asset Inspection & Reporting';
      case UserRole.viewer:
        return 'Public Transparency Access';
    }
  }

  String get homeRoute {
    switch (this) {
      case UserRole.superAdmin:
        return '/national-dashboard';
      case UserRole.stateAdmin:
        return '/state-dashboard';
      case UserRole.cityAdmin:
        return '/city-dashboard';
      case UserRole.fieldInspector:
        return '/inspector-home';
      case UserRole.viewer:
        return '/viewer-home';
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


