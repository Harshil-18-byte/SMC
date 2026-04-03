class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String hospitalName;
  final String hospitalId;
  final double rating;
  final int experienceYears;
  final String imageUrl;
  final double consultationFee;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospitalName,
    required this.hospitalId,
    required this.rating,
    required this.experienceYears,
    required this.imageUrl,
    required this.consultationFee,
  });

  factory Doctor.fromMap(Map<String, dynamic> map, String id) {
    return Doctor(
      id: id,
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      hospitalId: map['hospitalId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      experienceYears: map['experienceYears'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      consultationFee: (map['consultationFee'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'hospitalName': hospitalName,
      'hospitalId': hospitalId,
      'rating': rating,
      'experienceYears': experienceYears,
      'imageUrl': imageUrl,
      'consultationFee': consultationFee,
    };
  }
}


