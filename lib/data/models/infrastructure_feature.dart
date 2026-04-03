import 'package:flutter/material.dart';

enum FeatureScale { national, state, city, inspector, citizen }

class InfrastructureFeature {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final FeatureScale scale;
  final List<String> tags;
  final String status; // 'Active', 'Strategic', 'Operational'

  InfrastructureFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.scale,
    this.tags = const [],
    this.status = 'Active',
  });
}
