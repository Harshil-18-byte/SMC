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
        return 'National Manager';
      case UserRole.stateAdmin:
        return 'State Manager';
      case UserRole.cityAdmin:
        return 'Admin (Manager)';
      case UserRole.fieldInspector:
        return 'Inspector (Field Engineer)';
      case UserRole.viewer:
        return 'Reviewer / Authority';
    }
  }

  String get description {
    switch (this) {
      case UserRole.superAdmin:
        return 'National Infrastructure Oversight';
      case UserRole.stateAdmin:
        return 'Regional Compliance Management';
      case UserRole.cityAdmin:
        return 'City Asset Assignment & Control';
      case UserRole.fieldInspector:
        return 'Field Inspection & Data Upload';
      case UserRole.viewer:
        return 'Report Review & Approval Authority';
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
        return '/reviewer-home';
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

/// System Inspection Status
class SystemInspection {
  final bool isOnline;
  final int responseTime; // milliseconds
  final String status; // 'inspectiony', 'degraded', 'offline'
  final DateTime lastChecked;

  SystemInspection({
    required this.isOnline,
    required this.responseTime,
    required this.status,
    required this.lastChecked,
  });

  factory SystemInspection.fromMap(Map<String, dynamic> map) {
    return SystemInspection(
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
    if (status == 'inspectiony') return 'All Systems Operational';
    if (status == 'degraded') return 'Performance Degraded';
    return 'System Unavailable';
  }

  Color get statusColor {
    if (!isOnline) return const Color(0xFFFF4D4D);
    if (status == 'inspectiony') return const Color(0xFF10B981);
    if (status == 'degraded') return const Color(0xFFFFAB00);
    return const Color(0xFFFF4D4D);
  }
}


