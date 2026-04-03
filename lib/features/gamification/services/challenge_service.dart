import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smc/features/gamification/models/challenge.dart';
import 'package:smc/features/gamification/services/user_data_service.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate Daily Challenges for User
  Future<List<Challenge>> generateDailyChallenges(String userId) async {
    // In a real backend, this would likely be a Cloud Function triggered daily.
    // For client-side simulation or specific user-triggered generation:

    // Check if challenges exist for today
    final today = DateTime.now().toIso8601String().split('T')[0];
    final existingRef = _firestore
        .collection('user_challenges')
        .doc(userId)
        .collection('daily')
        .doc(today);

    final snapshot = await existingRef.get();

    if (snapshot.exists) {
      // Retrieve existing
      // Need to parse from subcollection or map
      // Simplified: Assume separate documents for each challenge or a list in doc
      // This part is tricky without a specific schema. Let's assume a sub-collection 'items'
      final items = await existingRef.collection('items').get();
      return items.docs
          .map((doc) => Challenge.fromMap(doc.data(), doc.id))
          .toList();
    } else {
      // Create new ones based on user level/history
      final newChallenges = _createRandomChallenges();

      // Save them
      for (var challenge in newChallenges) {
        await existingRef.collection('items').add({
          'title': challenge.title,
          'description': challenge.description,
          'icon': challenge.icon,
          'type': challenge.type.toString().split('.').last,
          'difficulty': challenge.difficulty.toString().split('.').last,
          'xp_reward': challenge.xpReward,
          'coins_reward': challenge.coinsReward,
          'target_value': challenge.targetValue,
          'current_value': 0,
          'status': 'active',
          'expires_at': DateTime.now().add(const Duration(hours: 24)),
        });
      }

      return newChallenges;
    }
  }

  // Update Challenge Progress
  Future<void> updateProgress(
      String userId, ChallengeType type, int amount) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final challengesRef = _firestore
        .collection('user_challenges')
        .doc(userId)
        .collection('daily')
        .doc(today)
        .collection('items');

    final snapshot = await challengesRef
        .where('type', isEqualTo: type.toString().split('.').last)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['status'] == 'completed') continue;

      int current = data['current_value'] ?? 0;
      int target = data['target_value'] ?? 1;
      int newCurrent = current + amount;

      if (newCurrent >= target) {
        newCurrent = target;
        await doc.reference.update({
          'current_value': newCurrent,
          'status': 'completed',
          'completed_at': FieldValue.serverTimestamp(),
        });
        // Trigger Reward
        await UserDataService.awardXp(userId, data['xp_reward']);
      } else {
        await doc.reference.update({'current_value': newCurrent});
      }
    }
  }

  List<Challenge> _createRandomChallenges() {
    // Logic to pick 3 random challenges
    return [
      Challenge(
        id: '1',
        title: 'Morning Rounds',
        description: 'Complete 5 visits before noon',
        icon: 'assets/icons/morning.svg',
        type: ChallengeType.visit,
        difficulty: ChallengeDifficulty.easy,
        xpReward: 50,
        coinsReward: 10,
        targetValue: 5,
        currentValue: 0,
        progressPercent: 0.0,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        status: ChallengeStatus.active,
      ),
      Challenge(
        id: '2',
        title: 'Precision Master',
        description: 'Maintain 100% data accuracy today',
        icon: 'assets/icons/precision.svg',
        type: ChallengeType.accuracy,
        difficulty: ChallengeDifficulty.hard,
        xpReward: 150,
        coinsReward: 30,
        targetValue: 1, // boolean logic handled as 0/1
        currentValue: 0,
        progressPercent: 0.0,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        status: ChallengeStatus.active,
      ),
      Challenge(
        id: '3',
        title: 'Team Spirit',
        description: 'Help 1 colleague with a visit',
        icon: 'assets/icons/help.svg',
        type: ChallengeType.social,
        difficulty: ChallengeDifficulty.medium,
        xpReward: 100,
        coinsReward: 20,
        targetValue: 1,
        currentValue: 0,
        progressPercent: 0.0,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        status: ChallengeStatus.active,
      ),
    ];
  }
}


