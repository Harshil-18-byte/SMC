import 'package:flutter/material.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/hospital_admission_model.dart';

class HospitalPatientsScreen extends StatelessWidget {
  const HospitalPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SMCBackButton(),
        title: const Text('Patient Queue Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {}, // Refresh logic if needed
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hospital_admissions')
            .orderBy('admissionTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_alt_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No patients in the queue'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _addMockPatient(context),
                    child: const Text('Add Demo Patient'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final admission = HospitalAdmission.fromMap(data, docs[index].id);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getSeverityColor(admission.severity),
                    child: Text(
                      admission.severity[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(admission.patientName),
                  subtitle: Text(
                    '${admission.age}y • ${admission.gender} • ${admission.status}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) =>
                        _updateStatus(context, admission.id, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'Waiting', child: Text('Waiting')),
                      const PopupMenuItem(
                          value: 'Triaged', child: Text('Triaged')),
                      const PopupMenuItem(
                          value: 'Admitted', child: Text('Admitted')),
                      const PopupMenuItem(
                          value: 'Discharged', child: Text('Discharged')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPatientDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _addMockPatient(BuildContext context) async {
    final patient = HospitalAdmission(
      id: '', // Firestore will generate ID
      patientName: 'John Doe',
      age: 45,
      gender: 'Male',
      severity: 'Medium',
      status: 'Waiting',
      admissionTime: DateTime.now(),
      assignedBedId: null,
      symptoms: ['Fever', 'Cough'],
      doctorId: null,
    );
    await FirebaseFirestore.instance
        .collection('hospital_admissions')
        .add(patient.toMap());
  }

  Future<void> _updateStatus(
      BuildContext context, String id, String status) async {
    await FirebaseFirestore.instance
        .collection('hospital_admissions')
        .doc(id)
        .update({'status': status});
  }

  void _showAddPatientDialog(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String severity = 'Low';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('New Admission'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Patient Name'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                // Simple Dropdown for Severity
                DropdownButtonFormField<String>(
                  initialValue: severity,
                  items: ['Low', 'Medium', 'Critical']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() =>
                      severity = val!), // Use setState from StatefulBuilder
                  decoration: const InputDecoration(labelText: 'Severity'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newAdmission = HospitalAdmission(
                    id: '',
                    patientName: nameController.text,
                    age: int.tryParse(ageController.text) ?? 0,
                    gender: 'Unknown', // Simplified for demo
                    severity: severity,
                    status: 'Waiting',
                    admissionTime: DateTime.now(),
                    assignedBedId: null,
                    symptoms: [],
                    doctorId: null,
                  );
                  FirebaseFirestore.instance
                      .collection('hospital_admissions')
                      .add(newAdmission.toMap());
                  Navigator.pop(context);
                },
                child: const Text('Admit'),
              ),
            ],
          );
        },
      ),
    );
  }
}
