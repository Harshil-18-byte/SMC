import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class CsvDataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedFromCsvs() async {
    debugPrint('🌱 Starting CSV data seeding...');
    try {
      await _seedHospitals();
      await _seedDepartments();
      await _seedStaff();
      await _seedCitizens();
      await _seedHealthRecords();
      debugPrint('✅ CSV data seeding completed successfully!');
    } catch (e) {
      debugPrint('❌ CSV data seeding failed: $e');
    }
  }

  Future<void> _seedHospitals() async {
    debugPrint('  Seeding hospitals from CSV...');
    try {
      final String data =
          await rootBundle.loadString('assets/data/hospitals.csv');
      final List<List<dynamic>> rows = _parseCsv(data);

      if (rows.length < 2) return; // Header + 1 row minimum

      int count = 0;
      WriteBatch batch = _firestore.batch();

      // Headers: hospital_id,hospital_name,ownership,area,beds,icu_beds,ventilators,bed_occupancy_rate,contact_phone,patient_load_label
      final headers = rows[0].map((e) => e.toString().trim()).toList();

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final Map<String, dynamic> hospital = {};

        final id = row[headers.indexOf('hospital_id')].toString().trim();
        hospital['id'] = id;
        hospital['name'] = row[headers.indexOf('hospital_name')];
        hospital['type'] = row[headers.indexOf('ownership')];
        hospital['area'] = row[headers.indexOf('area')];
        hospital['address'] = '${row[headers.indexOf('area')]}, Bharat';

        final beds = int.tryParse(row[headers.indexOf('beds')].toString()) ?? 0;
        final occupancyRate = double.tryParse(
                row[headers.indexOf('bed_occupancy_rate')].toString()) ??
            0.0;
        final availableBeds = (beds * (1 - occupancyRate)).round();

        hospital['bedTotal'] = beds;
        hospital['bedAvailable'] = availableBeds;
        hospital['icuBeds'] =
            int.tryParse(row[headers.indexOf('icu_beds')].toString()) ?? 0;
        hospital['ventilators'] =
            int.tryParse(row[headers.indexOf('ventilators')].toString()) ?? 0;
        hospital['contact'] = row[headers.indexOf('contact_phone')];
        hospital['patientLoad'] = row[headers.indexOf('patient_load_label')];

        // Better randomization to avoid a line (using math.Random with a seed for consistency)
        final randomLat = math.Random(i).nextDouble();
        final randomLng = math.Random(i + 100).nextDouble();

        // Spread around Bharat center (17.6599, 75.9064) within roughly 10km
        hospital['latitude'] = 17.6599 + (randomLat - 0.5) * 0.15;
        hospital['longitude'] = 75.9064 + (randomLng - 0.5) * 0.15;

        // Add additional fields for hospital_intake_status compatibility
        hospital['oxygenLevel'] = 70 + math.Random(i + 200).nextInt(30);
        hospital['triageWaitMinutes'] = math.Random(i + 300).nextInt(60);
        hospital['intakeLocked'] = availableBeds == 0;
        hospital['ward'] = 'Ward ${math.Random(i + 400).nextInt(20) + 1}';

        final docRef = _firestore.collection('hospitals').doc(id);
        batch.set(docRef, hospital);

        // Also seed into hospital_intake_status for consistency across the app
        final intakeDocRef =
            _firestore.collection('hospital_intake_status').doc(id);
        batch.set(intakeDocRef, hospital);
        count++;

        if (count % 400 == 0) {
          await batch.commit();
          batch = _firestore.batch();
          debugPrint('    Committed batch of hospitals...');
        }
      }

      if (count % 400 != 0) await batch.commit();
      debugPrint('  ✅ Seeded $count hospitals.');
    } catch (e) {
      debugPrint('  ❌ Error seeding hospitals: $e');
    }
  }

  Future<void> _seedDepartments() async {
    debugPrint('  Seeding departments from CSV...');
    try {
      final String data =
          await rootBundle.loadString('assets/data/departments.csv');
      final List<List<dynamic>> rows = _parseCsv(data);

      if (rows.length < 2) return;

      int count = 0;
      WriteBatch batch = _firestore.batch();

      // Headers: department_id,hospital_id,department,specialty
      final headers = rows[0].map((e) => e.toString().trim()).toList();

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final Map<String, dynamic> dept = {};
        final id = row[headers.indexOf('department_id')].toString().trim();

        dept['id'] = id;
        dept['hospitalId'] =
            row[headers.indexOf('hospital_id')].toString().trim();
        dept['name'] = row[headers.indexOf('department')];
        dept['specialty'] = row[headers.indexOf('specialty')];

        final docRef = _firestore.collection('departments').doc(id);
        batch.set(docRef, dept);
        count++;

        if (count % 400 == 0) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      if (count % 400 != 0) await batch.commit();
      debugPrint('  ✅ Seeded $count departments.');
    } catch (e) {
      debugPrint('  ❌ Error seeding departments: $e');
    }
  }

  Future<void> _seedStaff() async {
    debugPrint('  Seeding staff from CSV...');
    try {
      final String data = await rootBundle.loadString('assets/data/staff.csv');
      final List<List<dynamic>> rows = _parseCsv(data);

      if (rows.length < 2) return;

      int count = 0;
      WriteBatch batch = _firestore.batch();

      // Headers: staff_id,hospital_id,name,role,join_date,phone_masked
      final headers = rows[0].map((e) => e.toString().trim()).toList();

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final Map<String, dynamic> staff = {};
        final id = row[headers.indexOf('staff_id')].toString().trim();

        staff['id'] = id;
        staff['hospitalId'] =
            row[headers.indexOf('hospital_id')].toString().trim();
        staff['name'] = row[headers.indexOf('name')];
        staff['role'] = row[headers.indexOf('role')];
        staff['joinDate'] = row[headers.indexOf('join_date')];
        staff['phone'] = row[headers.indexOf('phone_masked')];

        if (staff['role'].toString().toLowerCase().contains('doctor')) {
          staff['systemRole'] = 'doctor';
        } else if (staff['role']
            .toString()
            .toLowerCase()
            .contains('field worker')) {
          staff['systemRole'] = 'field_worker';
        } else {
          staff['systemRole'] = 'staff';
        }

        final docRef = _firestore.collection('hospital_staff').doc(id);
        batch.set(docRef, staff);
        count++;

        if (count % 400 == 0) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      if (count % 400 != 0) await batch.commit();
      debugPrint('  ✅ Seeded $count staff members.');
    } catch (e) {
      debugPrint('  ❌ Error seeding staff: $e');
    }
  }

  Future<void> _seedCitizens() async {
    debugPrint('  Seeding citizens from CSV...');
    try {
      final String data =
          await rootBundle.loadString('assets/data/citizens.csv');
      final List<List<dynamic>> rows = _parseCsv(data);

      if (rows.length < 2) return;

      int count = 0;
      WriteBatch batch = _firestore.batch();

      // Headers: citizen_id,name,age,gender,address_area,phone_masked,blood_group
      final headers = rows[0].map((e) => e.toString().trim()).toList();

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final Map<String, dynamic> citizen = {};
        final id = row[headers.indexOf('citizen_id')].toString().trim();

        citizen['id'] = id;
        citizen['name'] = row[headers.indexOf('name')];
        citizen['age'] =
            int.tryParse(row[headers.indexOf('age')].toString()) ?? 0;
        citizen['gender'] = row[headers.indexOf('gender')];
        citizen['address'] = row[headers.indexOf('address_area')];
        citizen['phone'] = row[headers.indexOf('phone_masked')];
        citizen['bloodGroup'] = row[headers.indexOf('blood_group')];
        citizen['registeredAt'] = FieldValue.serverTimestamp();

        final docRef = _firestore.collection('citizens').doc(id);
        batch.set(docRef, citizen);
        count++;

        if (count % 400 == 0) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      if (count % 400 != 0) await batch.commit();
      debugPrint('  ✅ Seeded $count citizens.');
    } catch (e) {
      debugPrint('  ❌ Error seeding citizens: $e');
    }
  }

  Future<void> _seedHealthRecords() async {
    debugPrint('  Seeding health records from CSV...');
    try {
      final String data =
          await rootBundle.loadString('assets/data/health_records.csv');
      final List<List<dynamic>> rows = _parseCsv(data);

      if (rows.length < 2) return;

      int count = 0;
      WriteBatch batch = _firestore.batch();

      // Headers: record_id,citizen_id,diagnosis,treatment,doctor_id,hospital_id,date
      final headers = rows[0].map((e) => e.toString().trim()).toList();

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final Map<String, dynamic> record = {};
        final id = row[headers.indexOf('record_id')].toString().trim();

        record['id'] = id;
        record['citizenId'] =
            row[headers.indexOf('citizen_id')].toString().trim();
        record['diagnosis'] = row[headers.indexOf('diagnosis')];
        record['treatment'] = row[headers.indexOf('treatment')];
        record['doctorId'] =
            row[headers.indexOf('doctor_id')].toString().trim();
        record['hospitalId'] =
            row[headers.indexOf('hospital_id')].toString().trim();
        record['date'] = row[headers.indexOf('date')];

        final docRef = _firestore.collection('health_records').doc(id);
        batch.set(docRef, record);
        count++;

        if (count % 400 == 0) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      if (count % 400 != 0) await batch.commit();
      debugPrint('  ✅ Seeded $count health records.');
    } catch (e) {
      debugPrint('  ❌ Error seeding health records: $e');
    }
  }

  // Helper method to parse CSV manually since the package is having issues
  List<List<dynamic>> _parseCsv(String input) {
    final List<List<dynamic>> result = [];
    // Split by newline types
    final List<String> lines = input.split(RegExp(r'\r?\n'));

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      List<dynamic> row = [];
      StringBuffer currentField = StringBuffer();
      bool inQuote = false;

      for (int i = 0; i < line.length; i++) {
        String char = line[i];

        if (inQuote) {
          if (char == '"') {
            if (i + 1 < line.length && line[i + 1] == '"') {
              currentField.write('"'); // Handle escaped quote
              i++;
            } else {
              inQuote = false;
            }
          } else {
            currentField.write(char);
          }
        } else {
          if (char == '"') {
            inQuote = true;
          } else if (char == ',') {
            row.add(_parseValue(currentField.toString()));
            currentField.clear();
          } else {
            currentField.write(char);
          }
        }
      }
      row.add(_parseValue(currentField.toString()));
      result.add(row);
    }
    return result;
  }

  dynamic _parseValue(String value) {
    if (int.tryParse(value) != null) return int.parse(value);
    if (double.tryParse(value) != null) return double.parse(value);
    return value.trim();
  }
}


