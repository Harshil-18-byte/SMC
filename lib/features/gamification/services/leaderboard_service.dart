import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smc/features/gamification/models/leaderboard_entry.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LeaderboardEntry>> getGlobalLeaderboard(int limit) async {
    final snapshot = await _firestore
        .collection('leaderboards')
        .doc('global')
        .collection('entries')
        .orderBy('score', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => LeaderboardEntry.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<LeaderboardEntry>> getZoneLeaderboard(
      String zoneId, int limit) async {
    final snapshot = await _firestore
        .collection('leaderboards')
        .doc('zones')
        .collection(zoneId)
        .orderBy('score', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => LeaderboardEntry.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Update logic (typically server-side but client can trigger recalculation if simple)
  Future<void> updateScore(String userId, int newScore) async {
    final userRef = _firestore
        .collection('leaderboards')
        .doc('global')
        .collection('entries')
        .doc(userId);

    // Atomic increment might be better, or setting absolute score
    await userRef.set({'score': newScore}, SetOptions(merge: true));
  }
}


