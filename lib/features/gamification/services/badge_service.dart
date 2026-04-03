import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'package:smc/features/gamification/models/badge.dart';
import 'package:smc/features/gamification/models/user_data.dart';

class AnalyticsService {
  static Future<void> logAchievement(String badgeId) async {
    if (kDebugMode) {
      debugPrint('Analytics: Achievement Unlocked - $badgeId');
    }
    // Real implementation would log to Firebase Analytics
  }
}

class CertificateGenerator {
  static Future<Uint8List> generate({
    required String template,
    required String recipientName,
    required String badgeName,
    required DateTime dateAchieved,
    required String achievementDetails,
    required String verificationCode,
  }) async {
    // Placeholder: In a real app, this would use pdf/image generation package
    // to create a certificate. For now returning empty bytes.
    return Uint8List(0);
  }
}

class BadgeService {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  // Check for new badge unlocks
  static Future<List<Badge>> checkUnlocks(String userId) async {
    final user = await _getUserData(userId);
    final currentBadges = await _getUserBadges(userId);
    final allBadges = BadgeLibrary.getFieldWorkerBadges();

    List<Badge> newlyUnlocked = [];

    for (final badge in allBadges) {
      // Skip if already has this badge
      if (currentBadges.any((b) => b.id == badge.id)) continue;

      // Check prerequisites
      if (badge.prerequisiteBadges != null) {
        final hasPrereqs = badge.prerequisiteBadges!
            .every((reqId) => currentBadges.any((b) => b.id == reqId));
        if (!hasPrereqs) continue;
      }

      // Check unlock criteria
      if (_meetsUnlockCriteria(badge, user)) {
        newlyUnlocked.add(badge);
        await _awardBadge(userId, badge);
      }
    }

    return newlyUnlocked;
  }

  static bool _meetsUnlockCriteria(Badge badge, UserData user) {
    for (final entry in badge.unlockCriteria.entries) {
      switch (entry.key) {
        case 'days_worked':
          if (user.daysWorked < entry.value) return false;
          break;
        case 'consecutive_days':
          if (user.currentStreak < entry.value) return false;
          break;
        case 'total_days':
          if (user.totalDaysWorked < entry.value) return false;
          break;
        case 'total_visits':
          if (user.totalVisits < entry.value) return false;
          break;
        case 'visits_per_day':
          if (user.maxVisitsInDay < entry.value) return false;
          break;
        case 'high_risk_detections':
          if (user.highRiskDetections < entry.value) return false;
          break;
        case 'accuracy_score':
          if (user.averageAccuracy < entry.value) return false;
          break;
        case 'cluster_detections':
          if (user.clusterDetections < entry.value) return false;
          break;
        case 'assisted_colleagues':
          if (user.teamAssists < entry.value) return false;
          break;
        case 'mentees_trained':
          if (user.menteesTrained < entry.value) return false;
          break;
        // Citizen criteria
        case 'check_ins':
          return true; // Simplified for now
        case 'vaccinations_complete':
          return true; // Simplified
        case 'family_members_added':
          return true; // Simplified
        default:
          return false;
      }
    }
    return true;
  }

  static Future<void> _awardBadge(String userId, Badge badge) async {
    // Save to database
    await _firestore.collection('user_badges').add({
      'user_id': userId,
      'badge_id': badge.id,
      'unlocked_at': FieldValue.serverTimestamp(),
      'tier': badge.tier.toString(),
      'category': badge.category.toString(),
    });

    // Award XP and coins
    await _awardRewards(userId, badge.xpReward, badge.coinsReward);

    // Unlock features
    await _unlockFeatures(userId, badge.unlockedFeatures);

    // Generate certificate
    await _generateCertificate(userId, badge);

    // Send notification
    await _sendBadgeNotification(userId, badge);

    // Show unlock animation
    _showBadgeUnlockAnimation(badge);

    // Log achievement
    await AnalyticsService.logAchievement(badge.id);
  }

  static Future<void> _generateCertificate(String userId, Badge badge) async {
    final user = await _getUserData(userId);

    // Create certificate image
    final certificateImage = await CertificateGenerator.generate(
      template: badge.certificateTemplate,
      recipientName: user.name,
      badgeName: badge.name,
      dateAchieved: DateTime.now(),
      achievementDetails: badge.description,
      verificationCode: _generateVerificationCode(userId, badge.id),
    );

    // Upload to cloud storage
    try {
      final ref = _storage.ref().child('certificates/$userId/${badge.id}.png');
      await ref.putData(certificateImage);

      // Save certificate URL to user profile
      await _firestore.collection('users').doc(userId).update({
        'certificates.${badge.id}': {
          'url': await ref.getDownloadURL(),
          'date': FieldValue.serverTimestamp(),
          'badge_name': badge.name,
        },
      });
    } catch (e) {
      debugPrint('Error uploading certificate: $e');
    }
  }

  // Helper Methods

  static Future<UserData> _getUserData(String userId) async {
    // Fetch from Firestore
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserData.fromMap(doc.data()!, userId);
      }
    } catch (e) {
      debugPrint('Error getting user data: $e');
    }
    // Return default/empty if not found
    return UserData(id: userId, name: 'Unknown');
  }

  static Future<List<Badge>> _getUserBadges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_badges')
          .where('user_id', isEqualTo: userId)
          .get();

      final unlockedIds = snapshot.docs
          .map((doc) => doc.data()['badge_id'] as String?)
          .where((id) => id != null)
          .toSet();

      final allBadges = [
        ...BadgeLibrary.getFieldWorkerBadges(),
        ...BadgeLibrary.getCitizenBadges()
      ];

      return allBadges.where((b) => unlockedIds.contains(b.id)).toList();
    } catch (e) {
      debugPrint('Error getting user badges: $e');
      return [];
    }
  }

  static Future<void> _awardRewards(String userId, int xp, int coins) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'gamification.xp': FieldValue.increment(xp),
        'gamification.coins': FieldValue.increment(coins),
      });
    } catch (e) {
      debugPrint('Error awarding rewards: $e');
    }
  }

  static Future<void> _unlockFeatures(
      String userId, List<String> features) async {
    if (features.isEmpty) return;
    try {
      await _firestore.collection('users').doc(userId).update({
        'unlocked_features': FieldValue.arrayUnion(features),
      });
    } catch (e) {
      debugPrint('Error unlocking features: $e');
    }
  }

  static Future<void> _sendBadgeNotification(String userId, Badge badge) async {
    // Mock notification
    debugPrint('NOTIFICATION to $userId: Unlocked ${badge.name}!');
  }

  static void _showBadgeUnlockAnimation(Badge badge) {
    // Logic to trigger UI overlay/animation would go here
    // For now we just log it
    debugPrint('ANIMATION: Badge Unlock - ${badge.name}');
  }

  static String _generateVerificationCode(String userId, String badgeId) {
    return '${userId.substring(0, math.min(4, userId.length))}-${badgeId.substring(0, math.min(3, badgeId.length))}-${DateTime.now().millisecondsSinceEpoch}';
  }
}


