import 'package:flutter/material.dart';

/// Citizen Model
class Citizen {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String healthId;
  final DateTime dateOfBirth;
  final String bloodGroup;
  final String address;
  final List<FamilyMember> familyMembers;

  Citizen({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.healthId,
    required this.dateOfBirth,
    required this.bloodGroup,
    required this.address,
    this.familyMembers = const [],
  });

  factory Citizen.fromMap(Map<String, dynamic> map, String id) {
    return Citizen(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      healthId: map['healthId'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : DateTime.now(),
      bloodGroup: map['bloodGroup'] ?? '',
      address: map['address'] ?? '',
      familyMembers: map['familyMembers'] != null
          ? (map['familyMembers'] as List)
              .map((item) => FamilyMember.fromMap(item, item['id'] ?? ''))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'healthId': healthId,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'bloodGroup': bloodGroup,
      'address': address,
      'familyMembers': familyMembers.map((m) => m.toMap()).toList(),
    };
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}

/// Health Alert Model
class HealthAlert {
  final String id;
  final String title;
  final String message;
  final String severity; // 'info', 'warning', 'critical'
  final DateTime timestamp;
  final bool isRead;

  HealthAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });

  factory HealthAlert.fromMap(Map<String, dynamic> map, String id) {
    return HealthAlert(
      id: id,
      title: map['title'] ?? '',
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
      'title': title,
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

  IconData get severityIcon {
    switch (severity) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }
}

/// Family Member Model for Virtual Family Ward
class FamilyMember {
  final String id;
  final String name;
  final String relation; // e.g., 'Spouse', 'Child', 'Parent'
  final int age;
  final String gender;
  final String healthId;
  final String? profileImageUrl;
  final List<String> chronicConditions;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.age,
    required this.gender,
    required this.healthId,
    this.profileImageUrl,
    this.chronicConditions = const [],
  });

  factory FamilyMember.fromMap(Map<String, dynamic> map, String id) {
    return FamilyMember(
      id: id,
      name: map['name'] ?? '',
      relation: map['relation'] ?? 'Relative',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? 'Other',
      healthId: map['healthId'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      chronicConditions: List<String>.from(map['chronicConditions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relation': relation,
      'age': age,
      'gender': gender,
      'healthId': healthId,
      'profileImageUrl': profileImageUrl,
      'chronicConditions': chronicConditions,
    };
  }
}


