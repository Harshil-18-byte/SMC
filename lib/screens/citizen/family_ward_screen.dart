import 'package:flutter/material.dart';
import 'package:smc/core/theme/universal_theme.dart';
import 'package:smc/core/widgets/dashboard_back_handler.dart';
import 'package:smc/data/models/citizen_model.dart';
import 'package:smc/core/ui/imperfect_shapes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/data/services/firestore_service.dart';

class FamilyWardScreen extends StatefulWidget {
  const FamilyWardScreen({super.key});

  @override
  State<FamilyWardScreen> createState() => _FamilyWardScreenState();
}

class _FamilyWardScreenState extends State<FamilyWardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _citizenId = 'citizen_1'; // Demo ID

  List<FamilyMember> _familyMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final doc = await _firestoreService.readDocument(
        collection: 'citizens',
        docId: _citizenId,
      );

      if (doc != null) {
        final citizen = Citizen.fromMap(doc, _citizenId);
        if (mounted) {
          setState(() {
            _familyMembers = citizen.familyMembers;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading family members: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addFamilyMember(FamilyMember newMember) async {
    setState(() => _isLoading = true);
    try {
      // 1. Get current list (to ensure we have latest)
      final doc = await _firestoreService.readDocument(
        collection: 'citizens',
        docId: _citizenId,
      );

      List<FamilyMember> currentMembers = [];
      if (doc != null) {
        final citizen = Citizen.fromMap(doc, _citizenId);
        currentMembers = List.from(citizen.familyMembers);
      }

      // 2. Add new member
      currentMembers.add(newMember);

      // 3. Update Firestore
      await _firestoreService.updateDocument(
        collection: 'citizens',
        docId: _citizenId,
        data: {
          'familyMembers': currentMembers.map((m) => m.toMap()).toList(),
        },
      );

      // 4. Update UI
      if (mounted) {
        setState(() {
          _familyMembers = currentMembers;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family member added successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error adding family member: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding member: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DashboardBackHandler(
      dashboardName: 'Family Ward',
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
        appBar: AppBar(
          title: Text(
            'Virtual Family Ward',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _showAddMemberDialog,
              tooltip: 'Add Family Member',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _familyMembers.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: EdgeInsets.all(
                        UniversalTheme.getSpacing(context, SpacingSize.md)),
                    itemCount: _familyMembers.length,
                    itemBuilder: (context, index) {
                      final member = _familyMembers[index];
                      return _buildMemberCard(member, isDark);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom,
              size: 80, color: isDark ? Colors.grey[700] : Colors.grey[300]),
          SizedBox(height: UniversalTheme.getSpacing(context, SpacingSize.md)),
          Text(
            'No family members added yet',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: UniversalTheme.getSpacing(context, SpacingSize.lg)),
          ElevatedButton.icon(
            onPressed: _showAddMemberDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Family Member'),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(FamilyMember member, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C242D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to member details (placeholder for now)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Viewing records for ${member.name}')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: ShapeDecoration(
                    shape: ImperfectCircleBorder(
                      side: BorderSide(
                        color: _getRelationColor(member.relation),
                        width: 2,
                      ),
                    ),
                    color: _getRelationColor(member.relation)
                        .withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      member.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getRelationColor(member.relation),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF111418),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getRelationColor(member.relation)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              member.relation,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getRelationColor(member.relation),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${member.age} yrs • ${member.gender}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (member.relation == 'Parent' || member.age > 60) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniVital(Icons.favorite_rounded,
                                  "78", "bpm", Colors.red),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMiniVital(Icons.bloodtype_rounded,
                                  "128/84", "mmHg", Colors.orange),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Inspection ID Badge
                if (member.chronicConditions.isNotEmpty)
                  Tooltip(
                    message: 'Has Chronic Conditions',
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: Colors.red[400],
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRelationColor(String relation) {
    switch (relation.toLowerCase()) {
      case 'spouse':
        return Colors.pinkAccent;
      case 'child':
        return Theme.of(context).primaryColor;
      case 'parent':
        return Colors.orangeAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  Widget _buildMiniVital(
      IconData icon, String value, String unit, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          unit,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
          maxLines: 1,
        ),
      ],
    );
  }

  void _showAddMemberDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => _AddMemberDialog(
        onAdd: _addFamilyMember,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }
}

class _AddMemberDialog extends StatefulWidget {
  final Function(FamilyMember) onAdd;

  const _AddMemberDialog({required this.onAdd});

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _relation = 'Spouse';
  String _gender = 'Female';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C242D) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Family Member',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a member to your virtual ward for inspection monitoring.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLabel("Full Name"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        _inputDecoration("Enter name", Icons.person_outline),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Relation"),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _relation,
                              decoration: _inputDecoration("", null),
                              items: [
                                'Spouse',
                                'Child',
                                'Parent',
                                'Sibling',
                                'Other'
                              ]
                                  .map((r) => DropdownMenuItem(
                                      value: r, child: Text(r)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _relation = val!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Age"),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _ageController,
                              decoration: _inputDecoration("Yrs", null),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter age' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Gender"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: _inputDecoration("", null),
                    items: ['Female', 'Male', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => setState(() => _gender = val!),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text('Cancel',
                              style: TextStyle(color: Colors.grey[600])),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final newMember = FamilyMember(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                name: _nameController.text,
                                relation: _relation,
                                age: int.parse(_ageController.text),
                                gender: _gender,
                                inspectionId: 'SMC-NEW-${DateTime.now().second}',
                              );
                              widget.onAdd(newMember);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Add Member',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3B82F6),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData? icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      prefixIcon:
          icon != null ? Icon(icon, size: 20, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)) : null,
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}


