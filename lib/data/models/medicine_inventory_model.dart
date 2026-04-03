import 'package:flutter/material.dart';

/// Medicine Inventory Item Model
class MedicineInventoryItem {
  final String id;
  final String name;
  final String category;
  final int currentStock;
  final int minimumThreshold;
  final String unit;
  final DateTime lastRestocked;
  final bool replenishmentPending;

  MedicineInventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minimumThreshold,
    required this.unit,
    required this.lastRestocked,
    this.replenishmentPending = false,
  });

  factory MedicineInventoryItem.fromMap(Map<String, dynamic> map, String id) {
    return MedicineInventoryItem(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      currentStock: map['currentStock'] ?? 0,
      minimumThreshold: map['minimumThreshold'] ?? 0,
      unit: map['unit'] ?? 'units',
      lastRestocked: map['lastRestocked'] != null
          ? DateTime.parse(map['lastRestocked'])
          : DateTime.now(),
      replenishmentPending: map['replenishmentPending'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'currentStock': currentStock,
      'minimumThreshold': minimumThreshold,
      'unit': unit,
      'lastRestocked': lastRestocked.toIso8601String(),
      'replenishmentPending': replenishmentPending,
    };
  }

  bool get isBelowThreshold => currentStock < minimumThreshold;

  Color get statusColor {
    if (currentStock == 0) return const Color(0xFFFF4D4D);
    if (isBelowThreshold) return const Color(0xFFFFAB00);
    return const Color(0xFF10B981);
  }

  String get statusText {
    if (currentStock == 0) return 'OUT OF STOCK';
    if (isBelowThreshold) return 'LOW STOCK';
    return 'IN STOCK';
  }

  double get stockPercentage {
    if (minimumThreshold == 0) return 100;
    return (currentStock / minimumThreshold) * 100;
  }
}


