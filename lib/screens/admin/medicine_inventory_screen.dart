import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/medicine_inventory_model.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/theme/theme_switcher.dart';

/// Medicine Inventory Screen
/// Tabular view with threshold highlighting and replenishment approval
class MedicineInventoryScreen extends StatefulWidget {
  const MedicineInventoryScreen({super.key});

  @override
  State<MedicineInventoryScreen> createState() =>
      _MedicineInventoryScreenState();
}

class _MedicineInventoryScreenState extends State<MedicineInventoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  List<MedicineInventoryItem> _inventory = [];
  String _filterCategory = 'All';
  bool _showLowStockOnly = false;

  final List<String> _categories = [
    'All',
    'Antibiotics',
    'Analgesics',
    'Vaccines',
    'Emergency',
    'Chronic Care',
  ];

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);

    try {
      final inventoryData = await _firestoreService.getCollection(
        collection: 'medicine_inventory',
        orderBy: 'name',
      );
      _inventory = inventoryData
          .map((data) => MedicineInventoryItem.fromMap(data, data['id']))
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading inventory: $e')));
      }
    }
  }

  Future<void> _approveReplenishment(MedicineInventoryItem item) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'medicine_inventory',
        docId: item.id,
        data: {'replenishmentPending': true},
      );

      // Log transaction
      await _firestoreService.createDocument(
        collection: 'audit_logs',
        data: {
          'action': 'REPLENISHMENT_APPROVED',
          'medicineId': item.id,
          'medicineName': item.name,
          'currentStock': item.currentStock,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      await _loadInventory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Replenishment approved for ${item.name}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFFF4D4D),
          ),
        );
      }
    }
  }

  List<MedicineInventoryItem> get _filteredInventory {
    var filtered = _inventory;

    if (_filterCategory != 'All') {
      filtered =
          filtered.where((item) => item.category == _filterCategory).toList();
    }

    if (_showLowStockOnly) {
      filtered = filtered.where((item) => item.isBelowThreshold).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922),
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).medicineInventory,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          const ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInventory,
          ),
          if (_inventory
              .any((i) => i.isBelowThreshold && !i.replenishmentPending))
            IconButton(
              icon: const Icon(Icons.playlist_add_check_rounded,
                  color: Colors.orange),
              tooltip: 'Bulk Approve Replenishment',
              onPressed: _approveAllLowStock,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                _buildSummaryCards(),
                Expanded(child: _buildInventoryList()),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTER BY CATEGORY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _filterCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _filterCategory = category);
                    },
                    backgroundColor: const Color(0xFF101922),
                    selectedColor: const Color(0xFF137fec),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF137fec)
                          : Colors.grey[700]!,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _showLowStockOnly,
            onChanged: (value) {
              setState(() => _showLowStockOnly = value ?? false);
            },
            title: const Text(
              'Show Low Stock Only',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            activeColor: const Color(0xFFFFAB00),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalItems = _inventory.length;
    final lowStockItems =
        _inventory.where((item) => item.isBelowThreshold).length;
    final outOfStockItems =
        _inventory.where((item) => item.currentStock == 0).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Items',
              totalItems.toString(),
              Icons.inventory,
              const Color(0xFF137fec),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Low Stock',
              lowStockItems.toString(),
              Icons.warning,
              const Color(0xFFFFAB00),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Out of Stock',
              outOfStockItems.toString(),
              Icons.error,
              const Color(0xFFFF4D4D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D3748)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList() {
    final filtered = _filteredInventory;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No items found',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInventory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _buildInventoryCard(filtered[index]);
        },
      ),
    );
  }

  Widget _buildInventoryCard(MedicineInventoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isBelowThreshold
              ? item.statusColor
              : const Color(0xFF2D3748),
          width: item.isBelowThreshold ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: item.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Stock',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.currentStock} ${item.unit}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: item.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Threshold',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.minimumThreshold} ${item.unit}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Restocked',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.lastRestocked),
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.isBelowThreshold && !item.replenishmentPending) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _approveReplenishment(item),
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Approve Replenishment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF137fec),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
          if (item.replenishmentPending) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF137fec).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF137fec)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pending, color: Color(0xFF137fec), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Replenishment Pending',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF137fec),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _approveAllLowStock() async {
    final lowStockItems = _inventory
        .where((i) => i.isBelowThreshold && !i.replenishmentPending)
        .toList();

    if (lowStockItems.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      for (final item in lowStockItems) {
        await _firestoreService.updateDocument(
          collection: 'medicine_inventory',
          docId: item.id,
          data: {'replenishmentPending': true},
        );
      }
      await _loadInventory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Approved replenishment for ${lowStockItems.length} items'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error in bulk update: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}


