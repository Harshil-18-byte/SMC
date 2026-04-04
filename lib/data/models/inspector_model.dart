// Inspector / Field Engineer Model
class InspectorModel {
  final String id;
  final String fullName;
  final String specialization; // e.g., 'Structural Engineery', 'Geo-technical'
  final String rank; // 'J-1', 'S-1', 'L-1'
  final String profileUrl;
  final bool isAvailable;

  InspectorModel({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.rank,
    required this.profileUrl,
    this.isAvailable = true,
  });

  factory InspectorModel.fromMap(Map<String, dynamic> map, String id) {
    return InspectorModel(
      id: id,
      fullName: map['fullName'] ?? map['name'] ?? '',
      specialization: map['specialization'] ?? 'General Infrastructure',
      rank: map['rank'] ?? 'Expert',
      profileUrl: map['profileUrl'] ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=$id',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'specialization': specialization,
      'rank': rank,
      'profileUrl': profileUrl,
      'isAvailable': isAvailable,
    };
  }
}

/// Field Shift Model
class InspectorShift {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String zone;
  final String status; // 'scheduled', 'ongoing', 'completed'

  InspectorShift({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.zone,
    this.status = 'scheduled',
  });

  factory InspectorShift.fromMap(Map<String, dynamic> map, String id) {
    return InspectorShift(
      id: id,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : DateTime.now(),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : DateTime.now(),
      zone: map['zone'] ?? 'Default Zone',
      status: map['status'] ?? 'scheduled',
    );
  }
}
