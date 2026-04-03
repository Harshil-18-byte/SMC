/// Field Worker Profile Model
/// Represents the logged-in field worker's information
class FieldWorker {
  final String id;
  final String name;
  final String avatarUrl;
  final String currentLocation;
  final DateTime lastSync;
  final bool isOnline;
  final String sector;

  FieldWorker({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.currentLocation,
    required this.lastSync,
    this.isOnline = true,
    required this.sector,
  });

  // Create from Firestore document
  factory FieldWorker.fromMap(Map<String, dynamic> map, String id) {
    return FieldWorker(
      id: id,
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      currentLocation: map['currentLocation'] ?? '',
      lastSync: map['lastSync'] != null
          ? DateTime.parse(map['lastSync'])
          : DateTime.now(),
      isOnline: map['isOnline'] ?? true,
      sector: map['sector'] ?? '',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'currentLocation': currentLocation,
      'lastSync': lastSync.toIso8601String(),
      'isOnline': isOnline,
      'sector': sector,
    };
  }

  // Get time since last sync
  String getLastSyncText() {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}


