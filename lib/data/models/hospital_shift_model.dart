class HospitalStaffShift {
  final String id;
  final String staffName;
  final String role; // Doctor, Nurse, Technician
  final DateTime startTime;
  final DateTime endTime;
  final String ward;

  HospitalStaffShift({
    required this.id,
    required this.staffName,
    required this.role,
    required this.startTime,
    required this.endTime,
    required this.ward,
  });

  Map<String, dynamic> toMap() {
    return {
      'staffName': staffName,
      'role': role,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'ward': ward,
    };
  }

  factory HospitalStaffShift.fromMap(Map<String, dynamic> map, String id) {
    return HospitalStaffShift(
      id: id,
      staffName: map['staffName'] ?? '',
      role: map['role'] ?? 'Staff',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      ward: map['ward'] ?? 'General',
    );
  }
}


