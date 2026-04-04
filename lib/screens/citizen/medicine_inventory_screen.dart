import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/data/services/firestore_service.dart';

class CitizenMedicineInventoryScreen extends StatefulWidget {
  const CitizenMedicineInventoryScreen({super.key});

  @override
  State<CitizenMedicineInventoryScreen> createState() =>
      _CitizenMedicineInventoryScreenState();
}

class _CitizenMedicineInventoryScreenState
    extends State<CitizenMedicineInventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(l10n.translate('medicine_inventory_short')),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("QR Scanner opening...")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStockAlert(l10n, firestoreService),
            const SizedBox(height: 24),
            _buildMedicineList(l10n, isDark, firestoreService),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddMedicineDialog(context, firestoreService);
        },
        backgroundColor: const Color(0xFF137fec),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(l10n.translate('add_medicine'),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStockAlert(AppLocalizations l10n, FirestoreService firestore) {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream:
            firestore.streamCollection(collection: 'citizens/CIT001/medicines'),
        builder: (context, snapshot) {
          final medicines = snapshot.data ?? [];
          final lowStockMed =
              medicines.firstWhere((m) => m['isLow'] == true, orElse: () => {});

          if (lowStockMed.isEmpty) return const SizedBox.shrink();

          return FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('low_stock_alert'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${lowStockMed['name']} is below 5 units. Order now from nearest SMC pharmacy.",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildMedicineList(
      AppLocalizations l10n, bool isDark, FirestoreService firestore) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Current Stack",
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Map<String, dynamic>>>(
            stream: firestore.streamCollection(
                collection: 'citizens/CIT001/medicines'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final medicines = snapshot.data ?? [];
              if (medicines.isEmpty) {
                return const Center(
                    child: Text("No medicines in your inventory."));
              }

              return Column(
                children: medicines
                    .map((m) => FadeInUp(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1C242D)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: m['isLow'] == true
                                  ? Border.all(
                                      color:
                                          Colors.orange.withValues(alpha: 0.3))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (m['isLow'] == true
                                            ? Colors.orange
                                            : Theme.of(context).primaryColor)
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.medication_rounded,
                                    color: m['isLow'] == true
                                        ? Colors.orange
                                        : Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m['name'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${m['dosage']} • ${m['stock']} remaining',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        l10n.translate('expiry_date'),
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        m['expiry'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              );
            }),
      ],
    );
  }

  void _showAddMedicineDialog(
      BuildContext context, FirestoreService firestore) {
    String name = "";
    String dosage = "";
    int stock = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Medicine"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                onChanged: (v) => name = v,
                decoration: const InputDecoration(labelText: "Name")),
            TextField(
                onChanged: (v) => dosage = v,
                decoration: const InputDecoration(labelText: "Dosage")),
            TextField(
                onChanged: (v) => stock = int.tryParse(v) ?? 0,
                decoration: const InputDecoration(labelText: "Stock"),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (name.isNotEmpty) {
                await firestore.createDocument(
                    collection: 'citizens/CIT001/medicines',
                    data: {
                      'name': name,
                      'dosage': dosage,
                      'stock': stock,
                      'expiry': 'Dec 2026',
                      'isLow': stock < 5,
                    });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}


