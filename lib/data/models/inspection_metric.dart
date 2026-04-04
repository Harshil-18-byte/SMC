import 'package:flutter/material.dart';

/// Inspection Metric Model - Admin Oversight
/// Tracks high-level infrastructure performance indicators.
class InspectionMetric {
  final String label;
  final String value;
  final double change; // Percentage change (e.g., 0.15 for +15%)
  final Color color;
  final IconData icon;

  InspectionMetric({
    required this.label,
    required this.value,
    this.change = 0.0,
    required this.color,
    required this.icon,
  });

  bool get isPositive => change >= 0;
}
