import 'package:flutter/material.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';
import 'package:google_fonts/google_fonts.dart';

/// Asset Resource / Node Monitoring Screen
/// Manages strategic sensor nodes and critical monitoring points within an infrastructure asset.
class AssetResourceScreen extends StatelessWidget {
  const AssetResourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          leading: const SMCBackButton(),
          title: Text('NODE MONITORING', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
          bottom: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: 'ZONE ALPHA'),
              Tab(text: 'ZONE BETA'),
              Tab(text: 'ZONE GAMMA'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.blue),
              onPressed: () => _refreshNodes(context),
            ),
          ],
        ),
        body: IndustrialVisuals.blueprintBackground(
          isDark: true,
          child: const TabBarView(
            children: [
              _NodeGrid(zone: 'Alpha'),
              _NodeGrid(zone: 'Beta'),
              _NodeGrid(zone: 'Gamma'),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshNodes(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Polling live sensor arrays...')));
  }
}

class _NodeGrid extends StatelessWidget {
  final String zone;

  const _NodeGrid({required this.zone});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('strategic_nodes')
          .where('zone', isEqualTo: zone)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Data Link Error', style: TextStyle(color: Colors.red)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Center(child: Text('No active nodes in $zone', style: TextStyle(color: Colors.grey)));

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _NodeCard(
              id: docs[index].id,
              nodeId: data['nodeId'] ?? 'N-${index+1}',
              status: data['status'] ?? 'Baseline',
              alertType: data['alertType'] ?? 'None',
            );
          },
        );
      },
    );
  }
}

class _NodeCard extends StatelessWidget {
  final String id;
  final String nodeId;
  final String status;
  final String alertType;

  const _NodeCard({required this.id, required this.nodeId, required this.status, required this.alertType});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case 'Critical':
      case 'Failure':
        color = Colors.red;
        icon = Icons.error_outline_rounded;
        break;
      case 'Analyzing':
      case 'Warning':
        color = Colors.orange;
        icon = Icons.analytics_rounded;
        break;
      case 'Baseline':
      default:
        color = Colors.blue;
        icon = Icons.sensors_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Detail view
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 12),
                Text(nodeId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
