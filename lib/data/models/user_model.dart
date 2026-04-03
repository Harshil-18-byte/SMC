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

  // Field Worker specific
  final int? todayVisits;
  final int? monthlyVisits;
  final int? totalVisits;
  final int? streak;
  final String? assignedZone;
  final String? supervisorName;

  // Admin specific
  final int? activeUsers;
  final int? activeCases;
  final int? alerts;

  // Citizen specific
  final String? healthId;
  final String? bloodGroup;
  final int? healthScore;
  final int? vaccinationCount;
  final String? lastCheckup;
  final String? address;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.employeeId,
    this.department,
    this.todayVisits,
    this.monthlyVisits,
    this.totalVisits,
    this.streak,
    this.assignedZone,
    this.supervisorName,
    this.activeUsers,
    this.activeCases,
    this.alerts,
    this.healthId,
    this.bloodGroup,
    this.healthScore,
    this.vaccinationCount,
    this.lastCheckup,
    this.address,
  });

  factory User.mockAdmin() {
    return User(
      id: 'admin_1',
      name: 'Dr. Anjali Deshpande',
      email: 'anjali.d@solapur.gov.in',
      phone: '+91 98765 43210',
      role: UserRole.admin,
      employeeId: 'SMC-ADM-001',
      department: 'Health Administration',
      activeUsers: 1240,
      activeCases: 86,
      alerts: 12,
    );
  }

  factory User.mockFieldWorker() {
    return User(
      id: 'worker_1',
      name: 'Rahul More',
      email: 'rahul.more@smc.in',
      phone: '+91 98234 56789',
      role: UserRole.fieldWorker,
      employeeId: 'SMC-FW-402',
      department: 'Epidemiology Unit',
      todayVisits: 8,
      monthlyVisits: 142,
      totalVisits: 1240,
      streak: 12,
      assignedZone: 'Solapur North',
      supervisorName: 'Dr. Kulkarni',
    );
  }

  factory User.mockCitizen() {
    return User(
      id: 'citizen_123',
      name: 'Suresh Patil',
      email: 'suresh.patil@gmail.com',
      phone: '+91 91234 56789',
      role: UserRole.citizen,
      healthId: 'SOL-4522-8901',
      bloodGroup: 'O+',
      healthScore: 85,
      vaccinationCount: 3,
      lastCheckup: '2025-12-10',
      address: '123, Navi Peth, Solapur',
    );
  }

  factory User.mockDoctor() {
    return User(
      id: 'doc_456',
      name: 'Dr. Sameer Joshi',
      email: 'sameer.joshi@smc.in',
      phone: '+91 99887 76655',
      role: UserRole.doctor,
      employeeId: 'SMC-DOC-082',
      department: 'General Medicine',
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
        orElse: () => UserRole.citizen,
      ),
      photoUrl: json['photoUrl'],
      employeeId: json['employeeId'],
      department: json['department'],
    );
  }
}


