import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/command_center_models.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/widgets/smc_back_button.dart';

import 'package:url_launcher/url_launcher.dart';

/// Hospital Finder Screen
/// Find nearby hospitals with real-time bed availability
class HospitalFinderScreen extends StatefulWidget {
  const HospitalFinderScreen({super.key});

  @override
  State<HospitalFinderScreen> createState() => _HospitalFinderScreenState();
}

class _HospitalFinderScreenState extends State<HospitalFinderScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  List<HospitalIntakeStatus> _hospitals = [];
  List<HospitalIntakeStatus> _filteredHospitals = [];

  String _filterType = 'All';
  final List<String> _filterTypes = ['All', 'Available', 'Limited', 'Full'];

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHospitals() async {
    setState(() => _isLoading = true);

    try {
      final hospitalsData = await _firestoreService.getCollection(
        collection: 'hospital_intake_status',
      );
      _hospitals = hospitalsData
          .map((data) => HospitalIntakeStatus.fromMap(data, data['id']))
          .toList();

      _applyFilters();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading hospitals: $e')));
      }
    }
  }

  void _applyFilters() {
    var filtered = _hospitals;

    // Filter by availability
    if (_filterType != 'All') {
      filtered = filtered.where((h) {
        final availablePercent = (h.bedAvailable / h.bedTotal * 100).round();
        if (_filterType == 'Available') return availablePercent > 30;
        if (_filterType == 'Limited') {
          return availablePercent > 0 && availablePercent <= 30;
        }
        if (_filterType == 'Full') return availablePercent == 0;
        return true;
      }).toList();
    }

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((h) {
        return h.name.toLowerCase().contains(query);
      }).toList();
    }

    setState(() => _filteredHospitals = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const SMCBackButton(),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).hospitalFinder,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          const ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadHospitals(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildFilters(),
                Expanded(child: _buildHospitalsList()),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText:
              AppLocalizations.of(context).translate('search_hospital_hint'),
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF137fec)),
          ),
        ),
        onChanged: (value) => _applyFilters(),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterTypes.map((type) {
            final isSelected = _filterType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _filterType = type);
                  _applyFilters();
                },
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                selectedColor: const Color(0xFF137fec),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF137fec)
                      : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHospitalsList() {
    if (_filteredHospitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No hospitals found',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHospitals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredHospitals.length,
        itemBuilder: (context, index) {
          return _buildHospitalCard(_filteredHospitals[index]);
        },
      ),
    );
  }

  Widget _buildHospitalCard(HospitalIntakeStatus hospital) {
    final availablePercent =
        (hospital.bedAvailable / hospital.bedTotal * 100).round();
    final statusColor = availablePercent > 30
        ? const Color(0xFF10B981)
        : availablePercent > 0
            ? const Color(0xFFFFAB00)
            : const Color(0xFFFF4D4D);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_hospital,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(
                          height: 4), // Added spacing for better density
                      Text(
                        'General Hospital', // Mock subtitle
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${availablePercent}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMetricRow(
                  'Beds Available',
                  '${hospital.bedAvailable}/${hospital.bedTotal}',
                  Icons.bed,
                  statusColor,
                ),
                const SizedBox(height: 12),
                _buildMetricRow(
                  'Oxygen Level',
                  '${hospital.oxygenLevel}%',
                  Icons.air,
                  hospital.oxygenLevel > 50
                      ? const Color(0xFF10B981)
                      : const Color(0xFFFF4D4D),
                ),
                const SizedBox(height: 12),
                _buildMetricRow(
                  'Triage Wait',
                  '${hospital.triageWaitMinutes} min',
                  Icons.timer,
                  hospital.triageWaitMinutes < 30
                      ? const Color(0xFF10B981)
                      : const Color(0xFFFFAB00),
                ),
              ],
            ),
          ),
          if (hospital.intakeLocked) ...[
            Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D4D).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, color: Color(0xFFFF4D4D), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Intake temporarily locked',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF4D4D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _launchMaps(hospital.latitude, hospital.longitude),
                      icon: const Icon(Icons.directions, size: 18),
                      label: Text(
                          AppLocalizations.of(context).translate('directions')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF137fec),
                        side: const BorderSide(color: Color(0xFF137fec)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchPhone(
                          '0217-2740330'), // Default Solapur medical emergency
                      icon: const Icon(Icons.phone, size: 18),
                      label:
                          Text(AppLocalizations.of(context).translate('call')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF137fec),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  Widget _buildMetricRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use spaceBetween
      children: [
        Row(
          // Inner row for Icon + Label
          children: [
            Icon(icon, size: 18, color: Colors.grey[500]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
