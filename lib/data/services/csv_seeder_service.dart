import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Legacy CSV parsing was causing naming resolution issues.
/// This service now uses a robust, built-in line-splitting approach for first-pass seeding.
class CsvSeederService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Load and Seed a collection from CSV using a robust split-based parser
  Future<void> seedCollectionFromCsv({
    required String assetPath,
    required String collectionName,
    required String idColumn,
    Map<String, dynamic> Function(Map<String, dynamic> row)? transform,
  }) async {
    try {
      debugPrint('📖 Loading CSV from $assetPath...');
      final rawData = await rootBundle.loadString(assetPath);
      
      final lines = rawData.split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (lines.isEmpty) return;

      // Extract Headers
      final headers = lines[0].split(',').map((e) => e.trim()).toList();
      debugPrint('  Found headers: $headers');

      // Process Data Rows
      final batch = _firestore.batch();
      int count = 0;

      for (int i = 1; i < lines.length; i++) {
        final rowValues = lines[i].split(',').map((e) => e.trim()).toList();
        final Map<String, dynamic> rowMap = {};
        
        for (int j = 0; j < headers.length; j++) {
          if (j < rowValues.length) {
            var val = rowValues[j];
            // Simple type inference
            var parsedVal = double.tryParse(val) ?? (val.toLowerCase() == 'true' ? true : (val.toLowerCase() == 'false' ? false : val));
            rowMap[headers[j]] = parsedVal;
          }
        }

        // Apply transformations if any
        var finalData = transform != null ? transform(rowMap) : rowMap;
        
        final docId = finalData[idColumn]?.toString() ?? 'AUTO_${DateTime.now().millisecondsSinceEpoch}_$count';
        final docRef = _firestore.collection(collectionName).doc(docId);
        
        batch.set(docRef, {
          ...finalData,
          'seededAt': FieldValue.serverTimestamp(),
          'source': 'LIVE_CSV_SEED',
        });
        
        count++;
        // Batches have a limit of 500
        if (count >= 450) break; 
      }

      await batch.commit();
      debugPrint('✅ Seeded $count records into $collectionName from CSV.');
    } catch (e) {
      debugPrint('❌ Failed to seed $collectionName from CSV: $e');
      rethrow;
    }
  }
}
