/// Critical Alert Model
/// Represents urgent alerts in the command center
class CriticalAlert {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String severity; // 'danger', 'warning', 'info'
  final DateTime timestamp;
  final String zone;
  final bool isRead;

  CriticalAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.severity,
    required this.timestamp,
    required this.zone,
    this.isRead = false,
  });

  // Create from Firestore document
  factory CriticalAlert.fromMap(Map<String, dynamic> map, String id) {
    return CriticalAlert(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      iconName: map['iconName'] ?? 'warning',
      severity: map['severity'] ?? 'info',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      zone: map['zone'] ?? '',
      isRead: map['isRead'] ?? false,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'iconName': iconName,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'zone': zone,
      'isRead': isRead,
    };
  }

  // Get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}


