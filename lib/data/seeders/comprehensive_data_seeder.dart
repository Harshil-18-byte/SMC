import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smc/data/services/csv_seeder_service.dart';

/// Comprehensive Data Seeder for Bharat Infra (Pan-India)
/// Fetches macro data from CSV assets
class ComprehensiveDataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CsvSeederService _csvService = CsvSeederService();

  Future<void> seedAllData() async {
    debugPrint('🌱 Starting comprehensive Pan-India CSV seeding...');

    await clearAllData();

    // 1. National Assets
    await _csvService.seedCollectionFromCsv(
      assetPath: 'assets/data/infra_assets_national.csv',
      collectionName: 'infra_assets_national',
      idColumn: 'id',
    );

    // 2. State Projects
    await _csvService.seedCollectionFromCsv(
      assetPath: 'assets/data/infra_projects_state.csv',
      collectionName: 'infra_projects_state',
      idColumn: 'prj_id',
    );

    // 3. City Incidents
    await _csvService.seedCollectionFromCsv(
      assetPath: 'assets/data/city_incidents.csv',
      collectionName: 'city_incidents',
      idColumn: 'inc_id',
    );

    // 4. Field Inspectors
    await _csvService.seedCollectionFromCsv(
      assetPath: 'assets/data/field_inspectors.csv',
      collectionName: 'field_workers',
      idColumn: 'ins_id',
    );

    // 5. Citizen Reports
    await _csvService.seedCollectionFromCsv(
      assetPath: 'assets/data/citizen_reports.csv',
      collectionName: 'citizen_reports',
      idColumn: 'rep_id',
    );

    // Legacy Seeds (to be migrated later or kept for specific logic)
    await seedSystemUsers();
    await seedHospitalIntakeStatus();
    await seedAuditLogs();
    await seedSystemHealthMetrics();
    
    debugPrint('✅ Macro Infrastructure data seeded successfully!');
  }

  /// Seed Field Workers
  Future<void> seedFieldWorkers() async {
    debugPrint('  Seeding field workers...');

    final workers = [
      {
        'id': 'worker_1',
        'name': 'Suresh Jadhav',
        'avatarUrl': 'https://api.dicebear.com/7.x/avataaars/png?seed=Suresh',
        'currentLocation': 'Jule Bharat',
        'lastSync': DateTime.now().toIso8601String(),
        'isOnline': true,
        'sector': 'West Bharat',
      },
      {
        'id': 'worker_2',
        'name': 'Savita Pawar',
        'avatarUrl': 'https://api.dicebear.com/7.x/avataaars/png?seed=Savita',
        'currentLocation': 'Bhavani Peth',
        'lastSync': DateTime.now().toIso8601String(),
        'isOnline': true,
        'sector': 'East Bharat',
      }
    ];

    for (final worker in workers) {
      await _firestore
          .collection('field_workers')
          .doc(worker['id'] as String)
          .set(worker);
    }
  }

  /// Seed Assigned Tasks
  Future<void> seedTasks() async {
    debugPrint('  Seeding worker tasks...');

    final tasks = [
      {
        'id': 'TASK001',
        'householdId': 'HH-SOL-042',
        'title': 'Regular Screening',
        'description': 'Quarterly health survey for all family members',
        'priority': 'ROUTINE',
        'imageUrl':
            'https://images.unsplash.com/photo-1574680078891-b01b6336113b?q=80&w=400',
        'isCompleted': false,
        'assignedDate': DateTime.now().toIso8601String(),
        'notes': 'Check for elderly health concerns',
      },
      {
        'id': 'TASK002',
        'householdId': 'HH-SOL-128',
        'title': 'Fever Follow-up',
        'description': 'Monitor symptomatic patients from last week',
        'priority': 'PRIORITY',
        'imageUrl':
            'https://images.unsplash.com/photo-1584634731339-252c5aba1917?q=80&w=400',
        'isCompleted': false,
        'assignedDate': DateTime.now().toIso8601String(),
        'notes': 'Previously reported mild fever',
      }
    ];

    for (final task in tasks) {
      await _firestore.collection('tasks').doc(task['id'] as String).set(task);
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    debugPrint('🗑️ Clearing all data...');

    final collections = [
      'system_users',
      'hospital_intake_status',
      'audit_logs',
      'system_health_metrics',
      'infra_assets_national',
      'infra_projects_state',
      'city_incidents',
      'citizen_reports',
      'field_workers',
      'tasks',
    ];

    for (final collection in collections) {
      final snapshot = await _firestore.collection(collection).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint('  Cleared $collection');
    }

    debugPrint('✅ All data cleared!');
  }

  /// Seed System Users (Admins, Doctors, Field Workers)
  Future<void> seedSystemUsers() async {
    debugPrint('  Seeding localized system users...');

    final users = [
      {
        'id': 'ADM001',
        'name': 'Rahul Chavan',
        'designation': 'Executive Engineer',
        'role': 'Admin',
        'status': 'active',
        'email': 'rahul.c@infra.gov.in',
        'department': 'National Infrastructure Authority',
        'state': 'Maharashtra',
        'city': 'National HQ',
        'lastLogin': DateTime.now().toIso8601String(),
      },
      {
        'id': 'ADM002',
        'name': 'Priya Nimbalkar',
        'designation': 'Data Analyst',
        'role': 'Admin',
        'status': 'active',
        'email': 'priya.n@infra.gov.in',
        'department': 'Regional Analytics Division',
        'state': 'Karnataka',
        'city': 'Bengaluru',
        'lastLogin': DateTime.now().toIso8601String(),
      },
      {
        'id': 'DOC001',
        'name': 'Dr. Anil Patil',
        'role': 'doctor', // Changed to doctor for correct analytics tracking
        'status': 'active',
        'designation': 'Medical Officer',
        'specialization': 'General Medicine',
        'hospitalId': 'HOSP001',
        'email': 'anil.patil@smc.gov.in',
        'phone': '9111111111',
      },
      {
        'id': 'FW001',
        'name': 'Suresh Jadhav',
        'role': 'Field Worker',
        'status': 'active',
        'assignedWard': 'Ward No. 5',
        'employeeId': 'SMC-HW-1023',
        'phone': '9222222224',
        'responsibilities': [
          'Door-to-door health survey',
          'Report fever cases',
          'Vaccination follow-up'
        ],
      },
      {
        'id': 'FW002',
        'name': 'Savita Pawar',
        'role': 'Field Worker',
        'status': 'active',
        'assignedWard': 'Ward No. 14',
        'employeeId': 'SMC-ASHA-0876',
        'phone': '9333333335',
        'responsibilities': [
          'Maternal health visits',
          'Child vaccination tracking',
          'Awareness programs'
        ],
      },
    ];

    for (final user in users) {
      await _firestore
          .collection('system_users')
          .doc(user['id'] as String)
          .set(user);
    }
  }

  /// Seed Hospital Intake Status
  Future<void> seedHospitalIntakeStatus() async {
    debugPrint('  Seeding regional infrastructure...');

    final hospitals = [
      {
        'id': 'HOSP001',
        'name': 'Central Command Center - West',
        'type': 'Regional',
        'address': 'Civil Lines, Bharat, Maharashtra',
        'state': 'Maharashtra',
        'city': 'Bharat',
        'ward': 'Zone 5',
        'contact': '0217-2745001',
        'emergencyAvailable': true,
        'specialties': ["Bridge Safety", "Road Quality", "Drainage"],
        'latitude': 17.6599,
        'longitude': 75.9064,
        'status': 'stable',
        'intakeLocked': false,
      },
      {
        'id': 'HOSP002',
        'name': 'Delhi North Inspection Hub',
        'type': 'Regional',
        'address': 'Rohini, Delhi',
        'state': 'Delhi',
        'city': 'New Delhi',
        'ward': 'Zone 9',
        'contact': '011-2312345',
        'emergencyAvailable': true,
        'specialties': ["Structural", "Railway", "Public Build"],
        'latitude': 28.7041,
        'longitude': 77.1025,
        'status': 'warning',
        'intakeLocked': false,
      },
      {
        'id': 'HOSP003',
        'name': 'Mumbai Coast Infrastructure Bureau',
        'type': 'Regional',
        'address': 'Marine Drive, Mumbai',
        'state': 'Maharashtra',
        'city': 'Mumbai',
        'ward': 'South Bombay',
        'contact': '022-2456789',
        'emergencyAvailable': true,
        'specialties': ["Bridge Safety", "Marine Structure", "Coastal Roads"],
        'latitude': 18.9220,
        'longitude': 72.8347,
        'status': 'stable',
        'intakeLocked': false,
      },
    ];

    for (final hospital in hospitals) {
      await _firestore
          .collection('hospital_intake_status')
          .doc(hospital['id'] as String)
          .set(hospital);
    }
  }

  /// Seed Audit Logs
  Future<void> seedAuditLogs() async {
    debugPrint('  Seeding audit logs...');

    final logs = [
      {
        'action': 'EMERGENCY_ALERT_BROADCAST',
        'actorId': 'ADM001',
        'actorName': 'Rahul Chavan',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'metadata': {
          'severity': 'Critical',
          'scope': 'National Highway 4',
          'heading': 'Bridge Integrity Warning',
          'reason': 'Structural weakness detected by AI in pillar 42',
        },
      },
      {
        'action': 'INTAKE_LOCKED',
        'actorId': 'ADM001',
        'actorName': 'Rahul Chavan',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'metadata': {
          'hospitalId': 'HOSP002',
          'hospitalName': 'Dr. Babasaheb Ambedkar Hospital',
          'justification': 'ICU Capacity full',
        },
      },
    ];

    for (final log in logs) {
      await _firestore.collection('audit_logs').add(log);
    }
  }

  /// Seed System Health Metrics
  Future<void> seedSystemHealthMetrics() async {
    debugPrint('  Seeding system health metrics...');

    final metrics = [
      {
        'name': 'CPU Usage',
        'value': 24.5,
        'unit': '%',
        'threshold': 80.0,
        'status': 'healthy',
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'SMC Server Availability',
        'value': 99.9,
        'unit': '%',
        'threshold': 99.0,
        'status': 'healthy',
        'lastUpdated': DateTime.now().toIso8601String(),
      },
    ];

    for (final metric in metrics) {
      await _firestore.collection('system_health_metrics').add(metric);
    }
  }

  /// Seed Maintenance Tasks
  Future<void> seedMaintenanceTasks() async {
    debugPrint('  Seeding maintenance tasks...');

    final tasks = [
      {
        'title': 'Server Optimization',
        'description': 'Optimize SMC health portal servers',
        'scheduledDate':
            DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'priority': 'medium',
        'status': 'pending',
        'assignedTo': 'IT Dept',
      },
    ];

    for (final task in tasks) {
      await _firestore.collection('maintenance_tasks').add(task);
    }
  }

  /// Seed Visit Records
  Future<void> seedVisitRecords() async {
    debugPrint('  Seeding visit records...');

    final visits = [
      {
        'fieldWorkerId': 'FW001',
        'workerName': 'Suresh Jadhav',
        'householdId': 'SMC-HH-501',
        'address': 'Vijapur Road, Ward 5, Bharat',
        'latitude': 17.6599,
        'longitude': 75.9064,
        'visitDate':
            DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        'visitType': 'Door-to-door survey',
        'membersScreened': ['Mahesh Shinde'],
        'findings': {'fever': false},
        'notes': 'Mahesh Shinde screened. No symptoms.',
        'status': 'submitted',
      },
      {
        'fieldWorkerId': 'FW002',
        'workerName': 'Savita Pawar',
        'householdId': 'SMC-HH-1402',
        'address': 'Hotgi Road, Ward 14, Bharat',
        'latitude': 17.6352,
        'longitude': 75.9131,
        'visitDate':
            DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'visitType': 'Maternal health visit',
        'membersScreened': ['Lata Kendre'],
        'findings': {'stable': true},
        'notes': 'Lata Kendre (Pregnant) visited. Stable condition.',
        'status': 'submitted',
      },
    ];

    for (final visit in visits) {
      await _firestore.collection('visit_records').add(visit);
    }
  }

  /// Seed Symptom Assessments
  Future<void> seedSymptomAssessments() async {
    debugPrint('  Seeding symptom assessments...');

    final assessments = [
      {
        'memberId': 'CIT001',
        'memberName': 'Mahesh Shinde',
        'symptoms': {'Fever': false, 'Cough': false},
        'temperature': 98.4,
        'riskLevel': 'Low',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];

    for (final assessment in assessments) {
      await _firestore.collection('symptom_assessments').add(assessment);
    }
  }

  /// Seed Citizens
  Future<void> seedCitizens() async {
    debugPrint('  Seeding citizens...');

    final citizens = [
      {
        'id': 'CIT001',
        'name': 'Mahesh Shinde',
        'age': 45,
        'gender': 'Male',
        'address': 'Vijapur Road, Bharat',
        'ward': 'Ward No. 5',
        'aadhaarLast4': '4321',
        'contact': '9XXXXXXXX6',
        'healthId': 'SMC-HID-501',
        'healthConditions': ["Diabetes"],
        'bloodGroup': 'B+',
      },
      {
        'id': 'CIT002',
        'name': 'Lata Kendre',
        'age': 32,
        'gender': 'Female',
        'address': 'Hotgi Road, Bharat',
        'ward': 'Ward No. 14',
        'aadhaarLast4': '7854',
        'contact': '9XXXXXXXX7',
        'healthId': 'SMC-HID-1402',
        'healthConditions': ["Pregnant"],
        'bloodGroup': 'A+',
      },
      {
        'id': 'CIT003',
        'name': 'Rohit Patil',
        'age': 22,
        'gender': 'Male',
        'address': 'Saat Rasta, Bharat',
        'ward': 'Ward No. 9',
        'aadhaarLast4': '1198',
        'contact': '9XXXXXXXX8',
        'healthId': 'SMC-HID-903',
        'healthConditions': [],
        'bloodGroup': 'O+',
      }
    ];

    for (final citizen in citizens) {
      await _firestore
          .collection('citizens')
          .doc(citizen['id'] as String)
          .set(citizen);
    }
  }

  /// Seed Health Alerts
  Future<void> seedHealthAlerts() async {
    debugPrint('  Seeding health alerts...');

    final alerts = [
      {
        'title': 'Blood Donation Camp',
        'message':
            'SMC organizing blood donation camp at Civil Hospital tomorrow.',
        'severity': 'info',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      },
      {
        'title': 'Monsoon Health Advisory',
        'message': 'Precaution against water-borne diseases in Ward 9.',
        'severity': 'warning',
        'timestamp': DateTime.now()
            .subtract(const Duration(hours: 12))
            .toIso8601String(),
        'isRead': false,
      },
    ];

    for (final alert in alerts) {
      await _firestore.collection('health_alerts').add(alert);
    }
  }

  /// Seed Health Records
  Future<void> seedHealthRecords() async {
    debugPrint('  Seeding health records...');

    final records = [
      {
        'citizenId': 'CIT001',
        'type': 'visit',
        'title': 'Diabetes Consultation',
        'description': 'Regular sugar checkup',
        'date':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'provider': 'SMC Civil Hospital, Bharat',
        'details': {
          'Fasting Sugar': '110 mg/dL',
          'PP Sugar': '160 mg/dL',
        },
      },
    ];

    for (final record in records) {
      await _firestore.collection('health_records').add(record);
    }
  }

  /// Seed Surveillance Points for Heatmap
  Future<void> seedSurveillancePoints() async {
    debugPrint('  Seeding surveillance points...');

    final points = [
      {
        'latitude': 17.6648,
        'longitude': 75.9202,
        'intensity': 1.0,
        'disease': 'Dengue'
      },
      {
        'latitude': 17.6647,
        'longitude': 75.9201,
        'intensity': 0.8,
        'disease': 'Dengue'
      },
      {
        'latitude': 17.6649,
        'longitude': 75.9203,
        'intensity': 0.9,
        'disease': 'Dengue'
      },
      {
        'latitude': 17.6599,
        'longitude': 75.9064,
        'intensity': 1.0,
        'disease': 'Malaria'
      },
      {
        'latitude': 17.6601,
        'longitude': 75.9066,
        'intensity': 0.7,
        'disease': 'Malaria'
      },
      {
        'latitude': 17.6597,
        'longitude': 75.9062,
        'intensity': 0.6,
        'disease': 'Malaria'
      },
      {
        'latitude': 17.6352,
        'longitude': 75.9131,
        'intensity': 1.0,
        'disease': 'Viral Fever'
      },
      {
        'latitude': 17.6354,
        'longitude': 75.9133,
        'intensity': 0.5,
        'disease': 'Viral Fever'
      },
      {
        'latitude': 17.6351,
        'longitude': 75.9129,
        'intensity': 0.4,
        'disease': 'Viral Fever'
      },
      {
        'latitude': 17.6702,
        'longitude': 75.8956,
        'intensity': 0.9,
        'disease': 'Dengue'
      },
      {
        'latitude': 17.6704,
        'longitude': 75.8958,
        'intensity': 0.8,
        'disease': 'Dengue'
      },
      {
        'latitude': 17.6551,
        'longitude': 75.8998,
        'intensity': 1.0,
        'disease': 'Cholera'
      },
      {
        'latitude': 17.6553,
        'longitude': 75.9000,
        'intensity': 0.9,
        'disease': 'Cholera'
      },
    ];

    for (final point in points) {
      await _firestore.collection('surveillance_points').add({
        ...point,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Seed Field Health Reports
  Future<void> seedFieldReports() async {
    debugPrint('  Seeding field health reports...');

    final reports = [
      {
        'reportId': 'REP001',
        'reportedBy': 'FW001',
        'ward': 'Ward No. 5',
        'date': '2026-02-08',
        'casesReported': {
          'fever': 12,
          'dengueSuspected': 2,
          'covidSuspected': 0
        },
        'remarks': 'Increased fever cases near slum area'
      }
    ];

    for (final report in reports) {
      await _firestore
          .collection('field_reports')
          .doc(report['reportId'] as String)
          .set(report);
    }
  }

  /// Seed Admin Dashboard Metrics & Trends
  Future<void> seedDashboardMetrics() async {
    debugPrint('  Seeding dashboard KPIs and trends...');

    // 1. Health Metrics
    final metrics = [
      {
        'title': 'Active Cases',
        'iconName': 'medical_services',
        'value': 1240,
        'unit': 'cases',
        'percentage': 0.8,
        'changePercentage': 12.5,
        'isIncreasing': true,
        'trend': 'up',
        'severity': 'danger',
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Critical Beds',
        'iconName': 'bed',
        'value': 42,
        'unit': 'beds',
        'percentage': 0.9,
        'changePercentage': 5.0,
        'isIncreasing': false,
        'trend': 'down',
        'severity': 'warning',
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Field Workers',
        'iconName': 'people',
        'value': 285,
        'unit': 'active',
        'percentage': 0.95,
        'changePercentage': 2.0,
        'isIncreasing': true,
        'trend': 'up',
        'severity': 'normal',
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      {
        'title': 'SMC Services',
        'iconName': 'hub',
        'value': 99,
        'unit': '% uptime',
        'percentage': 0.99,
        'changePercentage': 0.1,
        'isIncreasing': true,
        'trend': 'stable',
        'severity': 'normal',
        'lastUpdated': DateTime.now().toIso8601String(),
      },
    ];

    for (final metric in metrics) {
      await _firestore.collection('health_metrics').add(metric);
    }

    // 2. Critical Alerts
    final alerts = [
      {
        'title': 'Oxygen Low at Civil Hospital',
        'description': 'Main tank below 15%. Logistics dispatched.',
        'iconName': 'warning',
        'severity': 'danger',
        'timestamp': DateTime.now()
            .subtract(const Duration(minutes: 45))
            .toIso8601String(),
        'zone': 'Ward No. 5',
        'isRead': false,
      },
      {
        'title': 'Dengue Spike in Jule Bharat',
        'description': '15 new cases reported in 24 hours.',
        'iconName': 'error',
        'severity': 'warning',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'zone': 'Jule Bharat',
        'isRead': false,
      },
    ];

    for (final alert in alerts) {
      await _firestore.collection('critical_alerts').add(alert);
    }

    // 3. Weekly Trends
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final caseValues = [120, 150, 110, 180, 200, 170, 140];
    final recoveredValues = [100, 120, 130, 140, 150, 160, 155];

    for (int i = 0; i < 7; i++) {
      await _firestore.collection('weekly_trends').add({
        'day': days[i],
        'cases': caseValues[i],
        'recovered': recoveredValues[i],
        'date':
            DateTime.now().subtract(Duration(days: 6 - i)).toIso8601String(),
      });
    }

    // 4. Command Center KPI (for AdminCommandCenterScreen)
    await _firestore.collection('command_center_kpi').doc('current').set({
      'activeCases': 1240,
      'icuCapacity': 78.5,
      'hospitalStressIndex': 62.0,
      'lastUpdated': DateTime.now().toIso8601String(),
    });

    // 5. System Alerts (for AdminCommandCenterScreen)
    final systemAlerts = [
      {
        'message':
            'Oxygen pressure dropping at SMC Civil Hospital, Main Tank Reservoir.',
        'severity': 'critical',
        'timestamp': DateTime.now()
            .subtract(const Duration(minutes: 15))
            .toIso8601String(),
        'isRead': false,
      },
      {
        'message':
            'Unexpected cluster of Influenza cases reported in Ward No. 12 (Bhavani Peth).',
        'severity': 'warning',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'isRead': false,
      },
      {
        'message':
            'Power backup successfully tested for Bharat Diagnostic Center.',
        'severity': 'info',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'isRead': true,
      },
    ];

    for (final sysAlert in systemAlerts) {
      await _firestore.collection('system_alerts').add(sysAlert);
    }
  }

  /// Seed Medicine Inventory
  Future<void> seedMedicineInventory() async {
    debugPrint('  Seeding medicine inventory...');

    final inventory = [
      {
        'name': 'Paracetamol 500mg',
        'category': 'Analgesics',
        'currentStock': 2500,
        'minimumThreshold': 1000,
        'unit': 'tabs',
        'lastRestocked':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'replenishmentPending': false,
      },
      {
        'name': 'Amoxicillin 250mg',
        'category': 'Antibiotics',
        'currentStock': 450,
        'minimumThreshold': 500,
        'unit': 'strips',
        'lastRestocked':
            DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
        'replenishmentPending': true,
      },
      {
        'name': 'Covishield Vaccine',
        'category': 'Vaccines',
        'currentStock': 120,
        'minimumThreshold': 200,
        'unit': 'vials',
        'lastRestocked':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'replenishmentPending': false,
      },
    ];

    for (final item in inventory) {
      await _firestore.collection('medicine_inventory').add(item);
    }
  }

  /// Seed Surveillance Analytics
  Future<void> seedSurveillanceAnalytics() async {
    debugPrint('  Seeding surveillance charts and heatmap data...');

    // 1. Time-series Case Data
    for (int i = 0; i < 30; i++) {
      await _firestore.collection('disease_case_data').add({
        'date':
            DateTime.now().subtract(Duration(days: 29 - i)).toIso8601String(),
        'newCases': 100 + (i * 2) + (i % 5 * 10),
        'recoveredCases': 80 + (i * 2) + (i % 3 * 5),
        'activeCases': 500 + i,
        'deaths': i % 10 == 0 ? 1 : 0,
      });
    }

    // 2. Zone Heatmap Data
    final zones = [
      {
        'name': 'Ward No. 5',
        'cases': 145,
        'lat': 17.6599,
        'lng': 75.9064,
        'sev': 'critical'
      },
      {
        'name': 'Jule Bharat',
        'cases': 98,
        'lat': 17.6750,
        'lng': 75.9250,
        'sev': 'high'
      },
      {
        'name': 'Saat Rasta',
        'cases': 56,
        'lat': 17.6648,
        'lng': 75.9202,
        'sev': 'medium'
      },
      {
        'name': 'Hotgi Road',
        'cases': 32,
        'lat': 17.6352,
        'lng': 75.9131,
        'sev': 'low'
      },
    ];

    for (final zone in zones) {
      await _firestore.collection('zone_heatmap_data').add({
        'zoneName': zone['name'],
        'caseCount': zone['cases'],
        'latitude': zone['lat'],
        'longitude': zone['lng'],
        'severity': zone['sev'],
      });
    }

    // 3. Raw Case Entries
    final casePrefixes = ['PAT-501-', 'PAT-902-', 'PAT-143-'];
    for (int i = 0; i < 20; i++) {
      await _firestore.collection('raw_case_entries').add({
        'patientId': '${casePrefixes[i % 3]}${1000 + i}',
        'zone': zones[i % zones.length]['name'],
        'reportedDate':
            DateTime.now().subtract(Duration(hours: i * 2)).toIso8601String(),
        'status': i % 5 == 0 ? 'recovered' : 'active',
        'age': 20 + (i * 2),
        'gender': i % 2 == 0 ? 'Male' : 'Female',
      });
    }
  }

  /// Seed Blood Requests
  Future<void> seedBloodRequests() async {
    debugPrint('  Seeding blood requests...');
    final requests = [
      {
        'patientName': 'Suresh Patil',
        'bloodGroup': 'O+',
        'hospital': 'SMC Civil Hospital',
        'unitsNeeded': 2,
        'urgency': 'Critical',
        'date': DateTime.now().toIso8601String(),
        'status': 'active',
      },
      {
        'patientName': 'Ramesh Shinde',
        'bloodGroup': 'B-',
        'hospital': 'Ashwini Sahakari Rugnalaya',
        'unitsNeeded': 1,
        'urgency': 'High',
        'date':
            DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'status': 'active',
      },
    ];
    for (var r in requests) {
      await _firestore.collection('blood_requests').add(r);
    }
  }

  /// Seed Volunteer Opportunities
  Future<void> seedVolunteerOpportunities() async {
    debugPrint('  Seeding volunteer opportunities...');
    final opportunities = [
      {
        'title': 'Mega Vaccination Drive',
        'date': 'Oct 24, 2026',
        'location': 'SMC Central Park',
        'needed': '20 Volunteers',
        'colorValue': 0xFF9C27B0, // Purple
        'category': 'Health',
      },
      {
        'title': 'Free Eye Checkup Camp',
        'date': 'Nov 02, 2026',
        'location': 'Zilla Parishad School',
        'needed': '08 Volunteers',
        'colorValue': 0xFFFF9800, // Orange
        'category': 'Screening',
      },
      {
        'title': 'Blood Donation Drive',
        'date': 'Nov 12, 2026',
        'location': 'Civil Hospital',
        'needed': '15 Volunteers',
        'colorValue': 0xFFF44336, // Red
        'category': 'Donation',
      },
    ];
    for (var o in opportunities) {
      await _firestore.collection('volunteer_opportunities').add(o);
    }
  }

  /// Seed Public Hygiene Reports
  Future<void> seedPublicHygieneReports() async {
    debugPrint('  Seeding hygiene reports...');
    final reports = [
      {
        'description': 'Open garbage dump near railway station.',
        'location': 'Bharat Railway Station Area',
        'status': 'pending',
        'reportedBy': 'CIT001',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'description': 'Water leakage in Shivaji Colony main road.',
        'location': 'Shivaji Colony, Bharat',
        'status': 'resolved',
        'reportedBy': 'CIT002',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
    ];
    for (var r in reports) {
      await _firestore.collection('hygiene_reports').add(r);
    }
  }

  /// Seed Citizen Vitals
  Future<void> seedCitizenVitals() async {
    debugPrint('  Seeding citizen vitals...');
    // Seed vitals for CIT001 (Mahesh Shinde)
    for (int i = 0; i < 7; i++) {
      await _firestore
          .collection('citizens')
          .doc('CIT001')
          .collection('vitals')
          .add({
        'timestamp':
            DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        'heartRate': 70 + (i % 5),
        'systolic': 120 + (i % 4),
        'diastolic': 80 + (i % 3),
        'temp': 98.6 + (i % 2),
        'oxygen': 98 + (i % 2),
      });
    }
  }

  /// Seed Citizen Medicine Inventory
  Future<void> seedCitizenMedicines() async {
    debugPrint('  Seeding citizen medicine inventory...');
    final medicines = [
      {
        'name': 'Metformin',
        'dosage': '500mg',
        'stock': 4,
        'expiry': 'Nov 2026',
        'isLow': true,
      },
      {
        'name': 'Atorvastatin',
        'dosage': '10mg',
        'stock': 28,
        'expiry': 'Jan 2027',
        'isLow': false,
      },
    ];
    for (var m in medicines) {
      await _firestore
          .collection('citizens')
          .doc('CIT001')
          .collection('medicines')
          .add(m);
    }
  }
}


