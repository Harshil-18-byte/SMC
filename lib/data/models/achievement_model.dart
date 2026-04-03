import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int target;
  final String realImpact;
  final int progress;
  final bool isUnlocked;
  final bool isNew;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.target,
    required this.realImpact,
    this.progress = 0,
    this.isUnlocked = false,
    this.isNew = false,
  });
}


