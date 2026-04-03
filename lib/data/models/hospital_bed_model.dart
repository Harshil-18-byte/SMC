class HospitalBed {
  final String id;
  final String ward;
  final String bedNumber;
  final String status; // Available, Occupied, Maintenance
  final String? currentPatientId;
  final String? currentPatientName;

  HospitalBed({
    required this.id,
    required this.ward,
    required this.bedNumber,
    required this.status,
    this.currentPatientId,
    this.currentPatientName,
  });

  Map<String, dynamic> toMap() {
    return {
      'ward': ward,
      'bedNumber': bedNumber,
      'status': status,
      'currentPatientId': currentPatientId,
      'currentPatientName': currentPatientName,
    };
  }

  factory HospitalBed.fromMap(Map<String, dynamic> map, String id) {
    return HospitalBed(
      id: id,
      ward: map['ward'] ?? 'General',
      bedNumber: map['bedNumber'] ?? '',
      status: map['status'] ?? 'Available',
      currentPatientId: map['currentPatientId'],
      currentPatientName: map['currentPatientName'],
    );
  }
}


