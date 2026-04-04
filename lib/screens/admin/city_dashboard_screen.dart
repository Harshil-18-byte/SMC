import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/core/visuals/infra_visuals.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/core/widgets/compact_widgets.dart';
import 'package:smc/widgets/smc_map.dart';
import 'package:flutter/services.dart';

class CityDashboardScreen extends StatefulWidget {
  const CityDashboardScreen({super.key});

  @override
  State<CityDashboardScreen> createState() => _CityDashboardScreenState();
}

class _CityDashboardScreenState extends State<CityDashboardScreen> {
  String _selectedCity = "Mumbai"; // Default to a major hub

  final List<String> _cities = [
    "Mumbai", "Delhi", "Bengaluru", "Hyderabad", "Ahmedabad", "Chennai", "Kolkata", 
    "Surat", "Pune", "Jaipur", "Lucknow", "Nagpur", "Indore", "Bhopal", "Visakhapatnam",
    "Patna", "Vadodara", "Ludhiana", "Agra", "Nashik", "Faridabad", "Meerut", "Rajkot", 
    "Kochi", "Gurugram", "Guwahati", "Panaji"
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveLayout(
      compactBody: _buildDashboardBody(context, isDark),
      mediumBody: _buildDashboardBody(context, isDark),
      expandedBody: _buildDashboardBody(context, isDark),
      largeBody: _buildDashboardBody(context, isDark),
    );
  }

  Widget _buildDashboardBody(BuildContext context, bool isDark) {
    return Scaffold(
      drawer: const UniversalDrawer(),
      appBar: AppBar(
        title: Text(
          "CITY INFRASTRUCTURE OPERATIONS",
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: InfraGridBackground(
        isDark: isDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUrbanRegistry(isDark),
              const SizedBox(height: 24),
              _buildCityStats(isDark),
              const SizedBox(height: 24),
              _buildLiveAssetMap(isDark),
              const SizedBox(height: 16),
              _buildQuickActions(isDark),
              const SizedBox(height: 24),
              _buildWorkOrderFeed(isDark),
              const SizedBox(height: 24),
              _buildPublicDemandHub(isDark),
              const SizedBox(height: 24),
              _buildTacticalFeatures(isDark),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrbanRegistry(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("NATIONAL URBAN REGISTRY", Icons.location_city_rounded),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              final city = _cities[index];
              final isSelected = _selectedCity == city;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(city, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87))),
                  selected: isSelected,
                  selectedColor: Colors.blue[600],
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCity = city);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCityStats(bool isDark) {
    return AdaptiveGrid(
      childAspectRatio: 1.5,
      children: [
        _buildMetricTile("Local Inspection", "76.4", Icons.location_city_rounded, Colors.blue),
        _buildMetricTile("Open Alerts", "12", Icons.warning_amber_rounded, Colors.red),
        _buildMetricTile("Crews Active", "8", Icons.people_outline_rounded, Colors.orange),
        _buildMetricTile("Compliance", "84%", Icons.fact_check_rounded, Colors.green),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: color),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveAssetMap(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("CITY ASSET SURVEILLANCE", Icons.map_rounded),
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const SMCMap(showMarkers: true),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: IndustrialActionButton(
            height: 48,
            color: Colors.blue[600]!,
            onTap: () {},
            child: Text("NEW WORK ORDER", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: IndustrialActionButton(
            height: 48,
            color: Colors.orange[700]!,
            onTap: () {},
            child: Text("DISPATCH CREW", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkOrderFeed(bool isDark) {
    final orders = [
      {'title': 'Pothole Filing - Sector 4', 'priority': 'Critical', 'time': '1h ago', 'color': Colors.red},
      {'title': 'Mainline Leak - MG Road', 'priority': 'High', 'time': '3h ago', 'color': Colors.orange},
      {'title': 'Light Repair - Central Park', 'priority': 'Normal', 'time': '5h ago', 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("ACTIVE WORK ORDERS", Icons.assignment_turned_in_rounded),
        const SizedBox(height: 12),
        ...orders.map((order) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: order['color'] as Color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Text(order['title'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13))),
              Text(order['priority'] as String, style: GoogleFonts.outfit(fontSize: 10, color: order['color'] as Color, fontWeight: FontWeight.w800)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildPublicDemandHub(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("CITIZEN SERVICE DEMAND (HIGH-PRIORITY)", Icons.campaign_rounded),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _buildDemandItem("Request for Smart Poles", "Sector 7 Corridor", "42 Requests", isDark),
              const Divider(height: 24, color: Colors.purple),
              _buildDemandItem("Pavement Leveling Request", "Industrial Area B", "28 Requests", isDark),
              const Divider(height: 24, color: Colors.purple),
              _buildDemandItem("Waste Segregation Bin", "Old City Hub", "15 Requests", isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDemandItem(String title, String loc, String count, bool isDark) {
    return InkWell(
      onTap: () => _showDemandDetails(title, loc, count, isDark),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.forum_rounded, color: Colors.purple, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(loc, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(count, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.purple)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  void _showDemandDetails(String title, String loc, String count, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F22) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.purple.withValues(alpha: 0.3), width: 2),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PUBLIC DEMAND ANALYSIS", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.purple, letterSpacing: 2)),
                    Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 24),
            _buildTacticalDetailRow("Location Context", loc, Icons.map_rounded),
            _buildTacticalDetailRow("Citizen Volume", count, Icons.people_rounded),
            _buildTacticalDetailRow("Priority Status", "HIGH (Automated Tier 1)", Icons.priority_high_rounded),
            const Spacer(),
            Text("ADMINISTRATIVE AUTHORIZATION", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: IndustrialActionButton(
                    height: 56,
                    color: Colors.blue[700]!,
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resource Provisioning Initialized..."), backgroundColor: Colors.blue));
                      await Future.delayed(const Duration(milliseconds: 1200));
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Heavy Equipment Dispatched to Site."), backgroundColor: Colors.blue));
                    },
                    child: Text("PROVISION RESOURCES", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: IndustrialActionButton(
                    height: 56,
                    color: Colors.purple[700]!,
                    onTap: () async {
                      HapticFeedback.heavyImpact();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Authorization Sequence Started..."), backgroundColor: Colors.purple));
                      await Future.delayed(const Duration(milliseconds: 1500));
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Regional Inspector Assigned for Site Audit."), backgroundColor: Colors.purple));
                    },
                    child: Text("AUTHORIZE INSPECTOR", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTacticalDetailRow(String label, String val, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
              Text(val, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTacticalFeatures(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("CITY TACTICAL TOOLS", Icons.settings_applications_rounded),
        const SizedBox(height: 16),
        AdaptiveGrid(
          childAspectRatio: 1.2,
          children: [
            _buildFeatureStub("Public Grievance", "Live feed of citizen reports.", Icons.record_voice_over_rounded),
            _buildFeatureStub("Fleet Tracking", "GPS monitor for field inspectors.", Icons.local_shipping_rounded),
            _buildFeatureStub("Local Budgeting", "Real-time spend vs. allocation.", Icons.account_balance_wallet_rounded),
            _buildFeatureStub("Street Scheduler", "City-wide maintenance calendar.", Icons.calendar_month_rounded),
            _buildFeatureStub("Safety Alerts", "Push structural risks to citizens.", Icons.notification_important_rounded),
            _buildFeatureStub("Trees Inventory", "Urban forestry & infra integration.", Icons.forest_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureStub(String title, String desc, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 1.2,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
