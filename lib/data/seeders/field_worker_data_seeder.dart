import 'package:flutter/foundation.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/task.dart';
import 'package:smc/data/models/field_worker.dart';

/// Field Worker Data Seeder
/// Seeds sample data for field worker home screen
class FieldWorkerDataSeeder {
  final FirestoreService _firestoreService = FirestoreService();

  /// Seed all field worker data
  Future<void> seedAllData() async {
    await seedFieldWorker();
    await seedTasks();
  }

  /// Seed field worker profile
  Future<void> seedFieldWorker() async {
    final worker = FieldWorker(
      id: 'worker_1',
      name: 'Sarah Jenkins',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC2UMsdklOWDG60EhB6vs031SQn9b4am5EhZ2AbgoQd2tIZ1FyoTr-JpSlbNxBIZQnICx2z8krae3W-BF6vW2ZCd_mDK4gVU3rZ0Nz70AsfbFBJUWNGGNWNQuxaNZd_Ttx_sXl0wf2fT5Am68VHO6tIR3r_mp8m-b_ZX4KosocQDBrHlAlN0nMB11R72CYPJTFlJdSTIGv98QGWfUrDw0ZxhhgD5a4QtwyiDW97yMJLTa6P1HRpvXaSYLBHT_nmSXgxJZG1bW09IC4',
      currentLocation: 'Sector 4, Village A',
      lastSync: DateTime.now().subtract(const Duration(minutes: 2)),
      isOnline: true,
      sector: 'Sector 4',
    );

    await _firestoreService.createDocument(
      collection: 'field_workers',
      docId: worker.id,
      data: worker.toMap(),
    );

    debugPrint('✅ Field worker profile seeded');
  }

  /// Seed tasks
  Future<void> seedTasks() async {
    final tasks = [
      Task(
        id: 'task_1',
        householdId: 'Household #104',
        title: 'Vaccination Follow-up',
        description: 'Vaccination Follow-up • Child (2yo)',
        priority: 'PRIORITY',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAw7F2gkeTteIdfZ4OOx-9oW8lsU5Ijk7evJIZMVRseFmOQWWF5RLEdgFNvEs_9Xwqfvjv3f9v8D4wMmuNMsOQoqu23nvP5sn-1uoURiptlUC8OfjsnGM2SH_pBAK307LAPdF2F_l9ASxT8P8mOlKEVDiINIP1JSpjlxi6S2J7kzzFxp3kBmttTTPnsj55PUSgDuJY2ulNMRfeaoZ61Pi3TRTKmKchBqrDgHjVX3VCOYwLo5bt2bu-mFxzClGzomyLAAaH5rjfkpgU',
        isCompleted: false,
        assignedDate: DateTime.now(),
        notes: 'Follow up on measles vaccination for 2-year-old child',
      ),
      Task(
        id: 'task_2',
        householdId: 'Household #108',
        title: 'Prenatal Checkup',
        description: 'Prenatal Checkup • Trimester 3',
        priority: 'ROUTINE',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBrnkd9f8rezDuVLYD-d4daDxQPzLvI0MemkFXjkDxPcG4UtaeS1IKHDA22ZWhHnsW04RNIbHmbEdsgSWkuOBqkjsYMZRtuDrXVjO1ojp0_e44SZDFXhMfa-95_vjceDPwhhXLNTtibuLAbW1kZh5gxmmc61BSDxyuCmYz16NJgD8mPzGIYZ2q2Yot5JY05iJXCfBqlkbJ1l6ywdnI2t7fpNU-aQRLmZ0C-KhtHV2mqhZaPr_wKVmkwL9pHVU5R-3aTGBlEqF2WgBU',
        isCompleted: false,
        assignedDate: DateTime.now(),
        notes: 'Third trimester prenatal checkup',
      ),
      Task(
        id: 'task_3',
        householdId: 'Household #112',
        title: 'General Health Survey',
        description: 'General Health Survey • Family of 5',
        priority: 'SURVEY',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC702EWW4KB7lIvFk7U8ZIWemtQE6x1LK2wwTq-S5rMo4GHGCaTULvrKHuWujFh1kQq2bGInbELScGpm5Sd8RxZKOwfG6jlDv-qjR8Iwuz6iuh3DCLiM6q3hFX8zlfgrhcLfgYgHNcLs_bMtjOVocVzm9kyoLU18J33q2wsqZixEQzWbri6D5ZPfAePyrck5hTkOK6hT0KqeWpgHQLubN0fBy_SIHyjUETcbGoL-Nj286oEtokgCK6pwtFR91ZOQFgbmyZzdQOqXA4',
        isCompleted: false,
        assignedDate: DateTime.now(),
        notes: 'Conduct general health survey for family of 5',
      ),
    ];

    for (final task in tasks) {
      await _firestoreService.createDocument(
        collection: 'tasks',
        docId: task.id,
        data: task.toMap(),
      );
    }

    debugPrint('✅ Tasks seeded');
  }

  /// Clear all field worker data
  Future<void> clearAllData() async {
    // Delete field worker
    try {
      await _firestoreService.deleteDocument(
        collection: 'field_workers',
        docId: 'worker_1',
      );
    } catch (e) {
      debugPrint('Note: Field worker not found or already deleted');
    }

    // Delete all tasks
    final tasks = await _firestoreService.getCollection(collection: 'tasks');
    for (final task in tasks) {
      await _firestoreService.deleteDocument(
        collection: 'tasks',
        docId: task['id'],
      );
    }

    debugPrint('✅ All field worker data cleared');
  }
}



