import 'package:flutter/foundation.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/command_center_models.dart';

/// Command Center Data Seeder
class CommandCenterDataSeeder {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> seedAllData() async {
    await seedKPI();
    await seedSystemAlerts();
    await seedHospitalStatuses();
  }

  Future<void> seedKPI() async {
    final kpi = CommandCenterKPI(
      activeCases: 1247,
      icuCapacity: 78.5,
      hospitalStressIndex: 72.3,
    );

    await _firestoreService.createDocument(
      collection: 'command_center_kpi',
      docId: 'current',
      data: kpi.toMap(),
    );

    debugPrint('✅ Command Center KPI seeded');
  }

  Future<void> seedSystemAlerts() async {
    final alerts = [
      SystemAlert(
        id: 'alert_1',
        message: 'City General Hospital ICU at 95% capacity',
        severity: 'critical',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      SystemAlert(
        id: 'alert_2',
        message: 'Oxygen supply low at Regional Medical Center',
        severity: 'warning',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      SystemAlert(
        id: 'alert_3',
        message: 'New case cluster detected in Zone 4',
        severity: 'warning',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      SystemAlert(
        id: 'alert_4',
        message: 'System backup completed successfully',
        severity: 'info',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    for (final alert in alerts) {
      await _firestoreService.createDocument(
        collection: 'system_alerts',
        docId: alert.id,
        data: alert.toMap(),
      );
    }

    debugPrint('✅ System alerts seeded');
  }

  Future<void> seedHospitalStatuses() async {
    final hospitals = [
      HospitalIntakeStatus(
        id: 'hospital_1',
        name: 'City General Hospital',
        bedAvailable: 12,
        bedTotal: 150,
        oxygenLevel: 45,
        triageWaitMinutes: 45,
        intakeLocked: false,
      ),
      HospitalIntakeStatus(
        id: 'hospital_2',
        name: 'Regional Medical Center',
        bedAvailable: 5,
        bedTotal: 100,
        oxygenLevel: 25,
        triageWaitMinutes: 60,
        intakeLocked: true,
        lockReason: 'Staff Shortage - Emergency personnel only',
      ),
      HospitalIntakeStatus(
        id: 'hospital_3',
        name: 'Community Health Center',
        bedAvailable: 28,
        bedTotal: 80,
        oxygenLevel: 85,
        triageWaitMinutes: 15,
        intakeLocked: false,
      ),
      HospitalIntakeStatus(
        id: 'hospital_4',
        name: 'District Hospital',
        bedAvailable: 8,
        bedTotal: 120,
        oxygenLevel: 60,
        triageWaitMinutes: 30,
        intakeLocked: false,
      ),
    ];

    for (final hospital in hospitals) {
      await _firestoreService.createDocument(
        collection: 'hospital_intake_status',
        docId: hospital.id,
        data: hospital.toMap(),
      );
    }

    debugPrint('✅ Hospital statuses seeded');
  }

  Future<void> clearAllData() async {
    // Clear KPI
    try {
      await _firestoreService.deleteDocument(
        collection: 'command_center_kpi',
        docId: 'current',
      );
    } catch (e) {
      debugPrint('Note: KPI not found');
    }

    // Clear alerts
    final alerts = await _firestoreService.getCollection(
      collection: 'system_alerts',
    );
    for (final alert in alerts) {
      await _firestoreService.deleteDocument(
        collection: 'system_alerts',
        docId: alert['id'],
      );
    }

    // Clear hospitals
    final hospitals = await _firestoreService.getCollection(
      collection: 'hospital_intake_status',
    );
    for (final hospital in hospitals) {
      await _firestoreService.deleteDocument(
        collection: 'hospital_intake_status',
        docId: hospital['id'],
      );
    }

    debugPrint('✅ Command center data cleared');
  }
}



