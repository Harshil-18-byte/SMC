import 'package:smc/data/models/auth_models.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? photoUrl;
  final String? employeeId;
  final String? department;

  // Multi-tenant Scoping
  final String? stateId;
  final String? cityId;
  final String? wardId;

  // Inspector / Field Officer specific
  final int? todayInspections;
  final int? monthlyInspections;
  final int? totalInspections;
  final int? resolvedDefects;
  final int? streak;
  final String? assignedZone;
  final String? supervisorName;
  final String? lastInspection;

  // Admin specific
  final int? activeInspectors;
  final int? pendingTasks;
  final int? criticalAlerts;

  // Compliance Viewer specific
  final String? region;
  final String? organization;
  final int? trustScore;
  final int? complianceScore;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.employeeId,
    this.department,
    this.stateId,
    this.cityId,
    this.wardId,
    this.todayInspections,
    this.monthlyInspections,
    this.totalInspections,
    this.resolvedDefects,
    this.streak,
    this.assignedZone,
    this.supervisorName,
    this.lastInspection,
    this.activeInspectors,
    this.pendingTasks,
    this.criticalAlerts,
    this.region,
    this.organization,
    this.trustScore,
    this.complianceScore,
  });

  factory User.mockNationalAdmin() {
    return User(
      id: 'nat_admin_1',
      name: 'Dr. Amitabh Kant',
      email: 'amitabh.kant@nic.in',
      phone: '+91 11 2309 6576',
      role: UserRole.superAdmin,
      employeeId: 'GOI-HQ-001',
      department: 'NITI Aayog / Infrastructure',
      activeInspectors: 4520,
      pendingTasks: 120,
      criticalAlerts: 8,
    );
  }

  factory User.mockCityAdmin() {
    return User(
      id: 'city_admin_1',
      name: 'Suhas Diwase',
      email: 'commissioner@smc.gov.in',
      phone: '+91 217 2740300',
      role: UserRole.cityAdmin,
      employeeId: 'SMC-ADM-001',
      department: 'Municipal Administration',
      stateId: 'maharashtra',
      cityId: 'Bharat',
      activeInspectors: 142,
      pendingTasks: 45,
      criticalAlerts: 12,
    );
  }

  factory User.mockFieldInspector() {
    return User(
      id: 'inspector_1',
      name: 'Rahul More',
      email: 'rahul.more@infra.smc.in',
      phone: '+91 98234 56789',
      role: UserRole.fieldInspector,
      employeeId: 'SMC-FI-402',
      department: 'Roads & Bridges Unit',
      stateId: 'maharashtra',
      cityId: 'Bharat',
      wardId: 'ward_12',
      todayInspections: 5,
      monthlyInspections: 84,
      totalInspections: 1240,
      resolvedDefects: 42,
      streak: 12,
      assignedZone: 'Bharat North',
      supervisorName: 'Er. Kulkarni',
      lastInspection: '2026-04-02 14:30',
    );
  }

  factory User.mockViewer() {
    return User(
      id: 'viewer_123',
      name: 'Suresh Patil',
      email: 'suresh.patil@citizen.in',
      phone: '+91 91234 56789',
      role: UserRole.viewer,
      organization: 'Public Safety Watch',
      region: 'Maharashtra',
      trustScore: 92,
      complianceScore: 88,
      lastInspection: '2026-04-01',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'photoUrl': photoUrl,
      'employeeId': employeeId,
      'department': department,
      'stateId': stateId,
      'cityId': cityId,
      'wardId': wardId,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.viewer,
      ),
      photoUrl: json['photoUrl'],
      employeeId: json['employeeId'],
      department: json['department'],
      stateId: json['stateId'],
      cityId: json['cityId'],
      wardId: json['wardId'],
    );
  }
}


