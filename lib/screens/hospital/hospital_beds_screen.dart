import 'package:flutter/material.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/hospital_bed_model.dart';
import '../../data/models/hospital_admission_model.dart';

class HospitalBedsScreen extends StatelessWidget {
  const HospitalBedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: const SMCBackButton(),
          title: const Text('Bed Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'General Ward'),
              Tab(text: 'ICU'),
              Tab(text: 'Emergency'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Bed (Demo)',
              onPressed: () => _addDemoBed(context),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _BedGrid(ward: 'General'),
            _BedGrid(ward: 'ICU'),
            _BedGrid(ward: 'Emergency'),
          ],
        ),
      ),
    );
  }

  Future<void> _addDemoBed(BuildContext context) async {
    // Helper to quickly populate
    final wards = ['General', 'ICU', 'Emergency'];
    for (var ward in wards) {
      for (int i = 1; i <= 5; i++) {
        await FirebaseFirestore.instance.collection('hospital_beds').add({
          'ward': ward,
          'bedNumber': '${ward[0]}-$i',
          'status': 'Available',
          'currentPatientId': null,
          'currentPatientName': null,
        });
      }
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Demo beds added')));
    }
  }
}

class _BedGrid extends StatelessWidget {
  final String ward;

  const _BedGrid({required this.ward});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hospital_beds')
          .where('ward', isEqualTo: ward)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(child: Text('No beds in $ward'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final bed = HospitalBed.fromMap(data, docs[index].id);
            return _BedCard(bed: bed);
          },
        );
      },
    );
  }
}

class _BedCard extends StatelessWidget {
  final HospitalBed bed;

  const _BedCard({required this.bed});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String statusText = bed.status;

    switch (bed.status) {
      case 'Occupied':
        color = Colors.red.shade100;
        icon = Icons.person;
        break;
      case 'Maintenance':
        color = Colors.orange.shade100;
        icon = Icons.cleaning_services;
        break;
      case 'Available':
      default:
        color = Colors.green.shade100;
        icon = Icons.bed;
        break;
    }

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black54),
            const SizedBox(height: 8),
            Text(
              bed.bedNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              bed.status == 'Occupied'
                  ? (bed.currentPatientName ?? 'Unknown')
                  : statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (bed.status == 'Available') {
      _showAssignDialog(context);
    } else if (bed.status == 'Occupied') {
      _showDischargeDialog(context);
    } else {
      // Maintenance - make available
      FirebaseFirestore.instance
          .collection('hospital_beds')
          .doc(bed.id)
          .update({'status': 'Available'});
    }
  }

  void _showAssignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AssignPatientDialog(bed: bed),
    );
  }

  void _showDischargeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discharge Patient?'),
        content:
            Text('Discharge ${bed.currentPatientName} from ${bed.bedNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update Bed
              await FirebaseFirestore.instance
                  .collection('hospital_beds')
                  .doc(bed.id)
                  .update({
                'status': 'Maintenance', // Goes to cleaning first
                'currentPatientId': null,
                'currentPatientName': null,
              });

              // Update Patient Status if linked
              if (bed.currentPatientId != null) {
                await FirebaseFirestore.instance
                    .collection('hospital_admissions')
                    .doc(bed.currentPatientId)
                    .update({
                  'status': 'Discharged',
                  'assignedBedId': null,
                });
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Discharge'),
          ),
        ],
      ),
    );
  }
}

class _AssignPatientDialog extends StatelessWidget {
  final HospitalBed bed;

  const _AssignPatientDialog({required this.bed});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hospital_admissions')
          .where('status',
              whereIn: ['Waiting', 'Triaged']) // Only fetch waiting patients
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final patients = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return HospitalAdmission.fromMap(data, doc.id);
        }).toList();

        if (patients.isEmpty) {
          return AlertDialog(
            title: const Text('No Patients Waiting'),
            content:
                const Text('There are no patients in the queue to assign.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'))
            ],
          );
        }

        return AlertDialog(
          title: Text('Assign to ${bed.bedNumber}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return ListTile(
                  title: Text(patient.patientName),
                  subtitle: Text(patient.severity),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () async {
                    // 1. Update Bed
                    await FirebaseFirestore.instance
                        .collection('hospital_beds')
                        .doc(bed.id)
                        .update({
                      'status': 'Occupied',
                      'currentPatientId': patient.id,
                      'currentPatientName': patient.patientName,
                    });

                    // 2. Update Patient
                    await FirebaseFirestore.instance
                        .collection('hospital_admissions')
                        .doc(patient.id)
                        .update({
                      'status': 'Admitted',
                      'assignedBedId': bed.id,
                    });

                    if (context.mounted) Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
