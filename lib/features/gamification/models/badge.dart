import 'package:flutter/material.dart';

enum BadgeTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  legendary,
}

enum BadgeCategory {
  dedication, // Consistency & attendance
  impact, // Lives saved, early detections
  excellence, // Quality of work
  community, // Team collaboration
  innovation, // Using new features
  mastery, // Skill development
  milestone, // Specific achievements
}

class Badge {
  final String id;
  final String name;
  final String description;
  final BadgeTier tier;
  final BadgeCategory category;
  final String iconAsset;
  final Color primaryColor;
  final Color accentColor;

  // Requirements
  final Map<String, dynamic> unlockCriteria;
  final int pointsRequired;
  final List<String>? prerequisiteBadges;

  // Rewards
  final int xpReward;
  final int coinsReward;
  final List<String> unlockedFeatures;

  // Rarity
  final double rarityScore; // 0-100
  final int? totalHoldersLimit; // null = unlimited

  // Real-world impact
  final String realImpactDescription;
  final Map<String, dynamic> impactMetrics;

  // Display
  final String congratsMessage;
  final String shareMessage;
  final String certificateTemplate;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.category,
    required this.iconAsset,
    required this.primaryColor,
    required this.accentColor,
    required this.unlockCriteria,
    required this.pointsRequired,
    this.prerequisiteBadges,
    required this.xpReward,
    required this.coinsReward,
    required this.unlockedFeatures,
    required this.rarityScore,
    this.totalHoldersLimit,
    required this.realImpactDescription,
    required this.impactMetrics,
    required this.congratsMessage,
    required this.shareMessage,
    required this.certificateTemplate,
  });
}

// Badge definitions
class BadgeLibrary {
  static List<Badge> getFieldWorkerBadges() {
    return [
      // DEDICATION CATEGORY
      const Badge(
        id: 'first_day',
        name: 'First Day Hero',
        description: 'Complete your first day of field work',
        tier: BadgeTier.bronze,
        category: BadgeCategory.dedication,
        iconAsset: 'assets/badges/first_day.svg',
        primaryColor: Color(0xFF8B4513),
        accentColor: Color(0xFFCD853F),
        unlockCriteria: {'days_worked': 1},
        pointsRequired: 0,
        xpReward: 50,
        coinsReward: 10,
        unlockedFeatures: ['daily_tips'],
        rarityScore: 5.0,
        realImpactDescription: 'Monitored health of your first families',
        impactMetrics: {'families_helped': 1},
        congratsMessage:
            'Welcome to the team! Every journey starts with a single step.',
        shareMessage:
            'I just started my journey as a health field worker with SMC!',
        certificateTemplate: 'first_day_certificate',
      ),

      const Badge(
        id: 'week_warrior',
        name: 'Week Warrior',
        description: 'Work for 7 consecutive days',
        tier: BadgeTier.silver,
        category: BadgeCategory.dedication,
        iconAsset: 'assets/badges/week_warrior.svg',
        primaryColor: Color(0xFFC0C0C0),
        accentColor: Color(0xFFE8E8E8),
        unlockCriteria: {'consecutive_days': 7},
        pointsRequired: 100,
        prerequisiteBadges: ['first_day'],
        xpReward: 200,
        coinsReward: 50,
        unlockedFeatures: ['advanced_analytics'],
        rarityScore: 15.0,
        realImpactDescription:
            'Provided consistent health monitoring for a full week',
        impactMetrics: {'families_monitored': 50},
        congratsMessage: 'Your dedication is making Bharat healthier!',
        shareMessage: 'One week of making a difference in my community! 💪',
        certificateTemplate: 'weekly_dedication',
      ),

      const Badge(
        id: 'month_master',
        name: 'Month Master',
        description: 'Complete 30 days of field work',
        tier: BadgeTier.gold,
        category: BadgeCategory.dedication,
        iconAsset: 'assets/badges/month_master.svg',
        primaryColor: Color(0xFFFFD700),
        accentColor: Color(0xFFFFA500),
        unlockCriteria: {'total_days': 30},
        pointsRequired: 500,
        prerequisiteBadges: ['week_warrior'],
        xpReward: 1000,
        coinsReward: 250,
        unlockedFeatures: ['priority_support', 'custom_dashboard'],
        rarityScore: 30.0,
        realImpactDescription: 'Monitored 200+ families over a month',
        impactMetrics: {'families_monitored': 200},
        congratsMessage: 'You are now a pillar of community health!',
        shareMessage: 'Celebrating 30 days of keeping Bharat healthy! 🏅',
        certificateTemplate: 'monthly_excellence',
      ),

      const Badge(
        id: 'iron_will',
        name: 'Iron Will',
        description: 'Work 100 consecutive days without missing',
        tier: BadgeTier.platinum,
        category: BadgeCategory.dedication,
        iconAsset: 'assets/badges/iron_will.svg',
        primaryColor: Color(0xFFE5E4E2),
        accentColor: Color(0xFFBFC1C2),
        unlockCriteria: {'consecutive_days': 100},
        pointsRequired: 2000,
        prerequisiteBadges: ['month_master'],
        xpReward: 5000,
        coinsReward: 1000,
        unlockedFeatures: ['mentor_program', 'advanced_tools'],
        rarityScore: 60.0,
        realImpactDescription:
            'Provided uninterrupted health monitoring for over 3 months',
        impactMetrics: {'families_monitored': 700, 'streak': 100},
        congratsMessage: 'Your unwavering commitment is legendary!',
        shareMessage:
            '100 days straight of community service! Nothing can stop me! 🔥',
        certificateTemplate: 'iron_will_certificate',
      ),

      // IMPACT CATEGORY
      const Badge(
        id: 'life_saver',
        name: 'Life Saver',
        description: 'Detect your first high-risk case early',
        tier: BadgeTier.gold,
        category: BadgeCategory.impact,
        iconAsset: 'assets/badges/life_saver.svg',
        primaryColor: Color(0xFFDC143C),
        accentColor: Color(0xFFFF6347),
        unlockCriteria: {'high_risk_detections': 1},
        pointsRequired: 200,
        xpReward: 500,
        coinsReward: 100,
        unlockedFeatures: ['emergency_priority'],
        rarityScore: 25.0,
        realImpactDescription: 'Your quick action potentially saved a life',
        impactMetrics: {'lives_protected': 1},
        congratsMessage: 'You are a hero! Your vigilance saved someone.',
        shareMessage:
            'Proud to have detected a critical case early. Every life matters! ❤️',
        certificateTemplate: 'life_saver_certificate',
      ),

      const Badge(
        id: 'outbreak_preventer',
        name: 'Outbreak Preventer',
        description: 'Help identify and report a disease cluster',
        tier: BadgeTier.platinum,
        category: BadgeCategory.impact,
        iconAsset: 'assets/badges/outbreak_preventer.svg',
        primaryColor: Color(0xFF4169E1),
        accentColor: Color(0xFF6495ED),
        unlockCriteria: {'cluster_detections': 1},
        pointsRequired: 1000,
        xpReward: 3000,
        coinsReward: 500,
        unlockedFeatures: ['epidemiology_dashboard'],
        rarityScore: 50.0,
        realImpactDescription:
            'Prevented potential outbreak affecting hundreds',
        impactMetrics: {'potential_cases_prevented': 100},
        congratsMessage:
            'You stopped an outbreak! You are a guardian of public health!',
        shareMessage: 'Helped prevent a disease outbreak in my community! 🛡️',
        certificateTemplate: 'outbreak_preventer_certificate',
      ),

      const Badge(
        id: 'guardian_angel',
        name: 'Guardian Angel',
        description: 'Save 10 lives through early detection',
        tier: BadgeTier.diamond,
        category: BadgeCategory.impact,
        iconAsset: 'assets/badges/guardian_angel.svg',
        primaryColor: Color(0xFFB9F2FF),
        accentColor: Color(0xFF87CEEB),
        unlockCriteria: {'high_risk_detections': 10},
        pointsRequired: 5000,
        prerequisiteBadges: ['life_saver'],
        xpReward: 10000,
        coinsReward: 2000,
        unlockedFeatures: ['hall_of_fame_entry'],
        rarityScore: 80.0,
        totalHoldersLimit: 100, // Only 100 people can have this
        realImpactDescription:
            'Protected 10 families from severe health complications',
        impactMetrics: {'lives_protected': 10},
        congratsMessage:
            'You are truly an angel! 10 lives protected because of you!',
        shareMessage: 'Honored to have protected 10 lives in my community! 👼',
        certificateTemplate: 'guardian_angel_certificate',
      ),

      // EXCELLENCE CATEGORY
      const Badge(
        id: 'quality_champion',
        name: 'Quality Champion',
        description: 'Maintain 95%+ data accuracy for 30 days',
        tier: BadgeTier.gold,
        category: BadgeCategory.excellence,
        iconAsset: 'assets/badges/quality_champion.svg',
        primaryColor: Color(0xFF32CD32),
        accentColor: Color(0xFF90EE90),
        unlockCriteria: {'accuracy_score': 95, 'days': 30},
        pointsRequired: 800,
        xpReward: 2000,
        coinsReward: 400,
        unlockedFeatures: ['data_validator_role'],
        rarityScore: 40.0,
        realImpactDescription:
            'Provided highly accurate data for AI predictions',
        impactMetrics: {'accurate_reports': 200},
        congratsMessage: 'Excellence is your standard! Your data saves lives!',
        shareMessage:
            'Maintaining 95%+ accuracy in health monitoring! Quality matters! ✨',
        certificateTemplate: 'quality_excellence',
      ),

      const Badge(
        id: 'speed_demon',
        name: 'Speed Demon',
        description: 'Complete 20 visits in a single day',
        tier: BadgeTier.silver,
        category: BadgeCategory.excellence,
        iconAsset: 'assets/badges/speed_demon.svg',
        primaryColor: Color(0xFFFF4500),
        accentColor: Color(0xFFFF6347),
        unlockCriteria: {'visits_per_day': 20},
        pointsRequired: 300,
        xpReward: 400,
        coinsReward: 80,
        unlockedFeatures: ['efficiency_tracking'],
        rarityScore: 20.0,
        realImpactDescription: 'Efficiently monitored 20 families in one day',
        impactMetrics: {'families_monitored_daily': 20},
        congratsMessage: 'Lightning fast! Your efficiency is incredible!',
        shareMessage: '20 households in one day! Speed + care = impact! ⚡',
        certificateTemplate: 'efficiency_award',
      ),

      // COMMUNITY CATEGORY
      const Badge(
        id: 'team_player',
        name: 'Team Player',
        description: 'Help a colleague complete their visits',
        tier: BadgeTier.bronze,
        category: BadgeCategory.community,
        iconAsset: 'assets/badges/team_player.svg',
        primaryColor: Color(0xFF9370DB),
        accentColor: Color(0xFFBA55D3),
        unlockCriteria: {'assisted_colleagues': 1},
        pointsRequired: 50,
        xpReward: 150,
        coinsReward: 30,
        unlockedFeatures: ['team_chat'],
        rarityScore: 10.0,
        realImpactDescription: 'Supported team efficiency and coverage',
        impactMetrics: {'team_assists': 1},
        congratsMessage: 'Together we are stronger! Thank you for helping!',
        shareMessage:
            'Teamwork makes the dream work! Helped a colleague today! 🤝',
        certificateTemplate: 'team_spirit',
      ),

      const Badge(
        id: 'mentor',
        name: 'Mentor',
        description: 'Train and guide 5 new field workers',
        tier: BadgeTier.platinum,
        category: BadgeCategory.community,
        iconAsset: 'assets/badges/mentor.svg',
        primaryColor: Color(0xFF8A2BE2),
        accentColor: Color(0xFF9370DB),
        unlockCriteria: {'mentees_trained': 5},
        pointsRequired: 3000,
        prerequisiteBadges: ['month_master', 'quality_champion'],
        xpReward: 5000,
        coinsReward: 1000,
        unlockedFeatures: ['trainer_certification', 'mentor_dashboard'],
        rarityScore: 70.0,
        realImpactDescription: 'Multiplied your impact by training others',
        impactMetrics: {'workers_trained': 5},
        congratsMessage:
            'You are building the future! 5 workers trained by you!',
        shareMessage:
            'Proud to mentor the next generation of health workers! 📚',
        certificateTemplate: 'mentor_certification',
      ),

      // MILESTONE CATEGORY
      const Badge(
        id: 'century_club',
        name: 'Century Club',
        description: 'Complete 100 household visits',
        tier: BadgeTier.gold,
        category: BadgeCategory.milestone,
        iconAsset: 'assets/badges/century_club.svg',
        primaryColor: Color(0xFFFFD700),
        accentColor: Color(0xFFFFA500),
        unlockCriteria: {'total_visits': 100},
        pointsRequired: 500,
        xpReward: 1500,
        coinsReward: 300,
        unlockedFeatures: ['milestone_tracker'],
        rarityScore: 35.0,
        realImpactDescription: 'Monitored health of 100 families',
        impactMetrics: {'families_monitored': 100},
        congratsMessage: '100 visits! You are making history!',
        shareMessage: 'Just hit 100 households! Century club member! 💯',
        certificateTemplate: 'century_certificate',
      ),

      const Badge(
        id: 'thousand_hero',
        name: 'Thousand Hero',
        description: 'Complete 1000 household visits',
        tier: BadgeTier.legendary,
        category: BadgeCategory.milestone,
        iconAsset: 'assets/badges/thousand_hero.svg',
        primaryColor: Color(0xFFFF1493),
        accentColor: Color(0xFFFF69B4),
        unlockCriteria: {'total_visits': 1000},
        pointsRequired: 10000,
        prerequisiteBadges: ['century_club'],
        xpReward: 50000,
        coinsReward: 10000,
        unlockedFeatures: ['legendary_status', 'custom_profile_theme'],
        rarityScore: 95.0,
        totalHoldersLimit: 50,
        realImpactDescription: 'Became a legend by monitoring 1000+ families',
        impactMetrics: {'families_monitored': 1000},
        congratsMessage: 'LEGENDARY! You are in the top 1% of field workers!',
        shareMessage: '1000 households! I am officially a legend! 👑',
        certificateTemplate: 'legendary_certificate',
      ),
    ];
  }

  static List<Badge> getCitizenBadges() {
    return [
      const Badge(
        id: 'health_conscious',
        name: 'Health Conscious',
        description: 'Complete your first health check-in',
        tier: BadgeTier.bronze,
        category: BadgeCategory.milestone,
        iconAsset: 'assets/badges/health_conscious.svg',
        primaryColor: Color(0xFF20B2AA),
        accentColor: Color(0xFF48D1CC),
        unlockCriteria: {'check_ins': 1},
        pointsRequired: 0,
        xpReward: 20,
        coinsReward: 5,
        unlockedFeatures: ['health_tracking'],
        rarityScore: 5.0,
        realImpactDescription: 'Started your health monitoring journey',
        impactMetrics: {'self_care_actions': 1},
        congratsMessage: 'Great start! Your health is your wealth!',
        shareMessage: 'Taking charge of my health with SMC! 💚',
        certificateTemplate: 'health_start',
      ),
      const Badge(
        id: 'vaccination_champion',
        name: 'Vaccination Champion',
        description: 'Get fully vaccinated and upload proof',
        tier: BadgeTier.silver,
        category: BadgeCategory.impact,
        iconAsset: 'assets/badges/vaccination_champion.svg',
        primaryColor: Color(0xFF00CED1),
        accentColor: Color(0xFF40E0D0),
        unlockCriteria: {'vaccinations_complete': true},
        pointsRequired: 100,
        xpReward: 300,
        coinsReward: 50,
        unlockedFeatures: ['vaccine_passport'],
        rarityScore: 15.0,
        realImpactDescription: 'Protected yourself and your community',
        impactMetrics: {'community_safety_contribution': 1},
        congratsMessage: 'You are protecting yourself and others! Hero!',
        shareMessage: 'Fully vaccinated and proud! Doing my part! 💉',
        certificateTemplate: 'vaccination_certificate',
      ),
      const Badge(
        id: 'family_guardian',
        name: 'Family Guardian',
        description: 'Add and monitor health of 5 family members',
        tier: BadgeTier.gold,
        category: BadgeCategory.community,
        iconAsset: 'assets/badges/family_guardian.svg',
        primaryColor: Color(0xFFFF69B4),
        accentColor: Color(0xFFFFB6C1),
        unlockCriteria: {'family_members_added': 5},
        pointsRequired: 200,
        xpReward: 500,
        coinsReward: 100,
        unlockedFeatures: ['family_dashboard'],
        rarityScore: 25.0,
        realImpactDescription: 'Keeping your entire family healthy',
        impactMetrics: {'family_members_monitored': 5},
        congratsMessage: 'You are keeping your family safe! Amazing!',
        shareMessage:
            'Monitoring health of my entire family! Family first! 👨👩👧👦',
        certificateTemplate: 'family_care',
      ),
    ];
  }
}


