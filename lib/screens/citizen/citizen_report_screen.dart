import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/core/visuals/infra_visuals.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/widgets/universal_drawer.dart';

class CitizenReportScreen extends StatefulWidget {
  const CitizenReportScreen({super.key});

  @override
  State<CitizenReportScreen> createState() => _CitizenReportScreenState();
}

class _CitizenReportScreenState extends State<CitizenReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Road/Pavement';
  final List<String> _categories = [
    'Road/Pavement',
    'Water/Sanitation',
    'Electricity/Lighting',
    'Public Building',
    'Bridges/Flyover',
    'Park/Greenery'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveLayout(
      compactBody: _buildBody(context, isDark),
      mediumBody: _buildBody(context, isDark),
      expandedBody: _buildBody(context, isDark),
      largeBody: _buildBody(context, isDark),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    return Scaffold(
      drawer: const UniversalDrawer(),
      appBar: AppBar(
        title: Text(
          "REPORT INFRASTRUCTURE ISSUE",
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: InfraGridBackground(
        isDark: isDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("EVIDENCE CAPTURE", Icons.camera_alt_rounded),
                const SizedBox(height: 16),
                _buildImagePickerPlaceholder(isDark),
                const SizedBox(height: 32),
                _buildSectionHeader("ISSUE DETAILS", Icons.edit_note_rounded),
                const SizedBox(height: 16),
                _buildCategoryDropdown(isDark),
                const SizedBox(height: 16),
                _buildDescriptionField(isDark),
                const SizedBox(height: 32),
                _buildSectionHeader("LOCATION DATA", Icons.location_on_rounded),
                const SizedBox(height: 16),
                _buildLocationPicker(isDark),
                const SizedBox(height: 40),
                IndustrialActionButton(
                  width: double.infinity,
                  height: 56,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: _submitReport,
                  child: Text(
                    "SUBMIT OFFICIAL COMPLAINT",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerPlaceholder(bool isDark) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_rounded, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            "TAP TO ATTACH PHOTO/VIDEO",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
          items: _categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.outfit(fontSize: 14)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return TextFormField(
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Describe the infrastructure defect in detail...",
        hintStyle: GoogleFonts.outfit(fontSize: 14),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
    );
  }

  Widget _buildLocationPicker(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Icon(Icons.my_location_rounded, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AUTO-DETECTED LOCATION",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  "Sector 4, MG Road, Central Hub",
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text("EDIT", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _submitReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("OFFICIAL COMPLAINT REGISTERED SUCCESSFULLY"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}
