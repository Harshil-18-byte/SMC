import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:smc/core/visuals/infra_visuals.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/core/widgets/compact_widgets.dart';

class StateDashboardScreen extends StatefulWidget {
  const StateDashboardScreen({super.key});

  @override
  State<StateDashboardScreen> createState() => _StateDashboardScreenState();
}

class _StateDashboardScreenState extends State<StateDashboardScreen> {
  String _selectedCity = "Mumbai"; // State-level selected hub

  final List<String> _cities = [
    "Mumbai", "Pune", "Nashik", "Nagpur", "Thane", "Aurangabad", "Ahmednagar", "Solapur", "Amravati", "Kolhapur"
  ];

  void _showResourceAllocationBottomSheet(String city, bool isDark) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101922) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.teal.withValues(alpha: 0.3), width: 2),
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
                    Text("STATE RESOURCE MATRIX: $city", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.teal, letterSpacing: 2)),
                    Text("Fleet Allocation", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 32),
            _buildAllocationOption("Heavy Machinery", "12 units active", Icons.settings_input_component_rounded, isDark),
            _buildAllocationOption("Service Crew Alpha", "Ready for deployment", Icons.groups_3_rounded, isDark),
            _buildAllocationOption("Mobile Audit Units", "Standby in Sector 4", Icons.radar_rounded, isDark),
            const Spacer(),
            Text("COMMAND CENTER ACTIONS", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: IndustrialActionButton(
                    height: 56,
                    color: Colors.teal[700]!,
                    onTap: () async {
                      HapticFeedback.heavyImpact();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Recalibrating Regional Fleet Hub..."), backgroundColor: Colors.teal));
                      await Future.delayed(const Duration(milliseconds: 1400));
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fleet Hub Recalibrated. GPS Vectors Synchronized."), backgroundColor: Colors.teal));
                    },
                    child: Text("SHIFT FLEET", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildAllocationOption(String title, String status, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(status, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(value: true, onChanged: (v) {}, activeThumbColor: Colors.teal),
        ],
      ),
    );
  }

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
          "STATE INFRASTRUCTURE COORDINATION",
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
              _buildRegionalUrbanRegistry(isDark),
              const SizedBox(height: 24),
              _buildRegionalStats(isDark),
              const SizedBox(height: 24),
              _buildResourceMatrix(isDark),
              const SizedBox(height: 24),
              _buildGrantTracker(isDark),
              const SizedBox(height: 24),
              _buildCoordinationFeatures(isDark),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegionalUrbanRegistry(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("STATE URBAN REGISTRY (CURRENT CLUSTER)", Icons.location_city_rounded),
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
                  selectedColor: Colors.teal[600],
                  backgroundColor: isDark ? Colors.white10 : Colors.teal.withValues(alpha: 0.05),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCity = city);
                      _showResourceAllocationBottomSheet(city, isDark);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRegionalStats(bool isDark) {
    return AdaptiveGrid(
      childAspectRatio: 1.5,
      children: [
        _buildMetricTile("State Health", "82.1", Icons.analytics_rounded, Colors.teal),
        _buildMetricTile("Projects Active", "412", Icons.engineering_rounded, Colors.blue),
        _buildMetricTile("Grants Out", "₹850Cr", Icons.payments_rounded, Colors.orange),
        _buildMetricTile("QA Lab Status", "Normal", Icons.science_rounded, Colors.green),
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

  Widget _buildResourceMatrix(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("INTER-CITY RESOURCE SHARING", Icons.swap_horiz_rounded),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Column(
            children: [
              _buildMatrixRow("Mumbai", "Bharat", "Heavy Excavator (2)"),
              const Divider(height: 24),
              _buildMatrixRow("Pune", "Nashik", "Asphalt Paver (1)"),
              const Divider(height: 24),
              _buildMatrixRow("Bharat", "Sangli", "Expert Inspector (3)"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatrixRow(String from, String to, String asset) {
    return Row(
      children: [
        Expanded(child: Text(from, style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward_rounded, size: 14)),
        Expanded(child: Text(to, style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(asset, style: GoogleFonts.outfit(fontSize: 10, color: Colors.blue))),
      ],
    );
  }

  Widget _buildGrantTracker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("GRANT ALLOCATION & AUDIT", Icons.request_quote_rounded),
        const SizedBox(height: 16),
        AdaptiveGrid(
          childAspectRatio: 2.5,
          children: [
            _buildGrantCard("Bharat Hub", "₹42 Cr", "Released", Colors.green),
            _buildGrantCard("Pune Rail", "₹115 Cr", "Pending", Colors.orange),
            _buildGrantCard("Nagpur Road", "₹89 Cr", "Audited", Colors.blue),
            _buildGrantCard("Thane Water", "₹34 Cr", "Released", Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildGrantCard(String city, String amount, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(city, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(amount, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
              Text(status.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinationFeatures(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("STATE-LEVEL TOOLS", Icons.handyman_rounded),
        const SizedBox(height: 16),
        AdaptiveGrid(
          childAspectRatio: 1.2,
          children: [
            _buildFeatureStub("QA Lab Network", "Monitor testing labs results.", Icons.biotech_rounded),
            _buildFeatureStub("Inter-city Rescue", "Coordinate emergency logistics.", Icons.medical_services_rounded),
            _buildFeatureStub("Climate Audit", "Regional environmental impact.", Icons.eco_rounded),
            _buildFeatureStub("Contractor Matrix", "State-level vendor scorecards.", Icons.assignment_ind_rounded),
            _buildFeatureStub("Maintenance 5Y", "5-year road maintenance roadmap.", Icons.update_rounded),
            _buildFeatureStub("Local Policies", "Adapt national rules per region.", Icons.room_preferences_rounded),
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
          Icon(icon, size: 24, color: Colors.teal),
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
        Icon(icon, size: 16, color: Colors.teal),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 1.2,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }
}
