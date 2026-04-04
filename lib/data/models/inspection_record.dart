import 'package:flutter/material.dart';

enum AssetType {
  bridge,
  road,
  building,
  pipeline,
  telecomTower,
  powerGrid,
  waterTank,
  drainageSystem
}

enum ComplianceStatus {
  compliant,
  nonCompliant,
  critical,
  pendingReview
}

enum InspectionSeverity {
  low,
  medium,
  high,
  extreme
}

class InspectionRecord {
  final String id;
  final String inspectorId;
  final String assetId;
  final AssetType assetType;
  final String assetName;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime inspectionDate;
  final String type; // 'routine', 'structural', 'emergency'
  final List<DefectFound> defects;
  final Map<String, dynamic> aiAnalysisResult;
  final List<String> photoUrls;
  final String notes;
  final ComplianceStatus status;
  final DateTime? approvalDate;
  final String? reviewerId;
  final String? reviewerComments;

  InspectionRecord({
    required this.id,
    required this.inspectorId,
    required this.assetId,
    required this.assetType,
    required this.assetName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.inspectionDate,
    required this.type,
    required this.defects,
    required this.aiAnalysisResult,
    required this.photoUrls,
    required this.notes,
    required this.status,
    this.approvalDate,
    this.reviewerId,
    this.reviewerComments,
  });

  factory InspectionRecord.fromMap(Map<String, dynamic> map, String id) {
    return InspectionRecord(
      id: id,
      inspectorId: map['inspectorId'] ?? '',
      assetId: map['assetId'] ?? '',
      assetType: AssetType.values.firstWhere(
        (e) => e.name == map['assetType'],
        orElse: () => AssetType.bridge,
      ),
      assetName: map['assetName'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      inspectionDate: map['inspectionDate'] != null
          ? DateTime.parse(map['inspectionDate'])
          : DateTime.now(),
      type: map['type'] ?? 'routine',
      defects: (map['defects'] as List? ?? [])
          .map((d) => DefectFound.fromMap(d))
          .toList(),
      aiAnalysisResult: map['aiAnalysisResult'] ?? {},
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      notes: map['notes'] ?? '',
      status: ComplianceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ComplianceStatus.pendingReview,
      ),
      approvalDate: map['approvalDate'] != null
          ? DateTime.parse(map['approvalDate'])
          : null,
      reviewerId: map['reviewerId'],
      reviewerComments: map['reviewerComments'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inspectorId': inspectorId,
      'assetId': assetId,
      'assetType': assetType.name,
      'assetName': assetName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'inspectionDate': inspectionDate.toIso8601String(),
      'type': type,
      'defects': defects.map((d) => d.toMap()).toList(),
      'aiAnalysisResult': aiAnalysisResult,
      'photoUrls': photoUrls,
      'notes': notes,
      'status': status.name,
      'approvalDate': approvalDate?.toIso8601String(),
      'reviewerId': reviewerId,
      'reviewerComments': reviewerComments,
    };
  }

  Color get statusColor {
    switch (status) {
      case ComplianceStatus.compliant:
        return const Color(0xFF10B981);
      case ComplianceStatus.nonCompliant:
        return const Color(0xFFFFAB00);
      case ComplianceStatus.critical:
        return const Color(0xFFFF4D4D);
      case ComplianceStatus.pendingReview:
        return const Color(0xFF6366F1);
    }
  }
}

class DefectFound {
  final String component;
  final String type; // Crack, Rust, etc.
  final String description;
  final InspectionSeverity severity;
  final List<String> capturedPhotos;

  DefectFound({
    required this.component,
    required this.type,
    required this.description,
    required this.severity,
    required this.capturedPhotos,
  });

  factory DefectFound.fromMap(Map<String, dynamic> map) {
    return DefectFound(
      component: map['component'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      severity: InspectionSeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => InspectionSeverity.low,
      ),
      capturedPhotos: List<String>.from(map['capturedPhotos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'component': component,
      'type': type,
      'description': description,
      'severity': severity.name,
      'capturedPhotos': capturedPhotos,
    };
  }
}
