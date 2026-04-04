import 'package:flutter/foundation.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/command_center_models.dart';

/// Command Center Data Seeder - Infrastructure Focus
class CommandCenterDataSeeder {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> seedAllData() async {
    await seedKPI();
    await seedSystemAlerts();
    await seedAssetStatuses();
  }

  Future<void> seedKPI() async {
    final kpi = InfraKPI(
      criticalDefects: 12,
      infrastructureUptime: 99.4,
      structuralRiskIndex: 14.5,
    );

    // Keep the same collection for backward compatibility but with new field names handled by model.toMap()
    await _firestoreService.createDocument(
      collection: 'command_center_kpi',
      docId: 'current',
      data: {
        'criticalDefects': kpi.criticalDefects,
        'infrastructureUptime': kpi.infrastructureUptime,
        'structuralRiskIndex': kpi.structuralRiskIndex,
      },
    );

    debugPrint('✅ Infra Command Center KPI seeded');
  }

  Future<void> seedSystemAlerts() async {
    final alerts = [
      SystemAlert(
        id: 'alert_1',
        message: 'Critical Structural Crack detected on Bridge-04',
        severity: 'critical',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      SystemAlert(
        id: 'alert_2',
        message: 'Corrosion levels exceeding safety limits in Zone 2 Power Grid',
        severity: 'warning',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      SystemAlert(
        id: 'alert_3',
        message: 'Minor water seepage reported in Sector 9 Subway',
        severity: 'info',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    for (final alert in alerts) {
      await _firestoreService.createDocument(
        collection: 'system_alerts',
        docId: alert.id,
        data: alert.toMap(),
      );
    }

    debugPrint('✅ Industrial system alerts seeded');
  }

  Future<void> seedAssetStatuses() async {
    final assets = [
      AssetStatus(
        id: 'asset_1',
        name: 'Mumbai Trans Harbour Link',
        healthScore: 980,
        maxHealth: 1000,
        stabilityLevel: 99,
        repairBacklogDays: 0,
      ),
      AssetStatus(
        id: 'asset_2',
        name: 'Bandra-Worli Sea Link',
        healthScore: 650,
        maxHealth: 1000,
        stabilityLevel: 85,
        repairBacklogDays: 14,
        maintenanceLocked: true,
        lockReason: 'Phase 2 Resurfacing in progress',
      ),
      AssetStatus(
        id: 'asset_3',
        name: 'Delhi Metro Blue Line',
        healthScore: 420,
        maxHealth: 1000,
        stabilityLevel: 60,
        repairBacklogDays: 45,
      ),
    ];

    for (final asset in assets) {
      // Note: We use original collection name 'asset_intake_status' for service compatibility 
      // but populated with AssetStatus fields.
      await _firestoreService.createDocument(
        collection: 'asset_intake_status',
        docId: asset.id,
        data: {
          'name': asset.name,
          'healthScore': asset.healthScore,
          'maxHealth': asset.maxHealth,
          'stabilityLevel': asset.stabilityLevel,
          'repairBacklogDays': asset.repairBacklogDays,
          'maintenanceLocked': asset.maintenanceLocked,
          'lockReason': asset.lockReason,
        },
      );
    }

    debugPrint('✅ Asset statuses seeded');
  }
}
