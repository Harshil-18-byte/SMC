import 'package:flutter/material.dart';

/// Visit Record Model
class VisitRecord {
  final String id;
  final String fieldWorkerId;
  final String householdId;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime visitDate;
  final String visitType; // 'routine', 'follow_up', 'emergency'
  final List<Map<String, dynamic>> membersScreened; // Changed from List<String>
  final Map<String, dynamic> findings;
  final List<String> photoUrls;
  final List<String> detectedSymptoms;
  final String notes;
  final String status; // 'draft', 'submitted', 'synced'

  VisitRecord({
    required this.id,
    required this.fieldWorkerId,
    required this.householdId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.visitDate,
    required this.visitType,
    required this.membersScreened,
    required this.findings,
    required this.photoUrls,
    this.detectedSymptoms = const [],
    required this.notes,
    required this.status,
  });

  factory VisitRecord.fromMap(Map<String, dynamic> map, String id) {
    return VisitRecord(
      id: id,
      fieldWorkerId: map['fieldWorkerId'] ?? '',
      householdId: map['householdId'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      visitDate: map['visitDate'] != null
          ? DateTime.parse(map['visitDate'])
          : DateTime.now(),
      visitType: map['visitType'] ?? 'routine',
      membersScreened:
          List<Map<String, dynamic>>.from(map['membersScreened'] ?? []),
      findings: map['findings'] ?? {},
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      detectedSymptoms: List<String>.from(map['detectedSymptoms'] ?? []),
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'draft',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fieldWorkerId': fieldWorkerId,
      'householdId': householdId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'visitDate': visitDate.toIso8601String(),
      'visitType': visitType,
      'membersScreened': membersScreened,
      'findings': findings,
      'photoUrls': photoUrls,
      'detectedSymptoms': detectedSymptoms,
      'notes': notes,
      'status': status,
    };
  }

  Color get visitTypeColor {
    switch (visitType) {
      case 'emergency':
        return const Color(0xFFFF4D4D);
      case 'follow_up':
        return const Color(0xFFFFAB00);
      default:
        return const Color(0xFF137fec);
    }
  }
}

/// Household Member Model
class HouseholdMember {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String relation;
  final bool hasSymptoms;

  HouseholdMember({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.relation,
    this.hasSymptoms = false,
  });

  factory HouseholdMember.fromMap(Map<String, dynamic> map, String id) {
    return HouseholdMember(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      relation: map['relation'] ?? '',
      hasSymptoms: map['hasSymptoms'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'relation': relation,
      'hasSymptoms': hasSymptoms,
    };
  }
}


