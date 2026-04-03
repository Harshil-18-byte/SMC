import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> awardXp(String userId, int amount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'gamification.xp': FieldValue.increment(amount),
      });
      debugPrint('Awarded $amount XP to $userId');
    } catch (e) {
      debugPrint('Error awarding XP: $e');
    }
  }

  static Future<void> awardCoins(String userId, int amount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'gamification.coins': FieldValue.increment(amount),
      });
      debugPrint('Awarded $amount Coins to $userId');
    } catch (e) {
      debugPrint('Error awarding Coins: $e');
    }
  }
}


