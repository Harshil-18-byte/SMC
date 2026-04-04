class SiteAdmission {
  final String id;
  final String assetName;
  final int age;
  final String gender;
  final String severity; // Low, Medium, Critical
  final String status; // Waiting, Triaged, Admitted, Discharged
  final DateTime admissionTime;
  final String? assignedBedId;
  final List<String> symptoms;
  final String? doctorId;

  SiteAdmission({
    required this.id,
    required this.assetName,
    required this.age,
    required this.gender,
    required this.severity,
    required this.status,
    required this.admissionTime,
    this.assignedBedId,
    required this.symptoms,
    this.doctorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'assetName': assetName,
      'age': age,
      'gender': gender,
      'severity': severity,
      'status': status,
      'admissionTime': admissionTime.toIso8601String(),
      'assignedBedId': assignedBedId,
      'symptoms': symptoms,
      'doctorId': doctorId,
    };
  }

  factory SiteAdmission.fromMap(Map<String, dynamic> map, String id) {
    return SiteAdmission(
      id: id,
      assetName: map['assetName'] ?? '',
      age: map['age']?.toInt() ?? 0,
      gender: map['gender'] ?? '',
      severity: map['severity'] ?? 'Low',
      status: map['status'] ?? 'Waiting',
      admissionTime: DateTime.parse(map['admissionTime']),
      assignedBedId: map['assignedBedId'],
      symptoms: List<String>.from(map['symptoms'] ?? []),
      doctorId: map['doctorId'],
    );
  }
}


