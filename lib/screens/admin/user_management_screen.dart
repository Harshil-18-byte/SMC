import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/system_user_model.dart';

/// User Management Screen
/// List all users with suspend and role change actions
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  List<SystemUser> _users = [];
  String _filterRole = 'All';
  String _filterStatus = 'All';

  final List<String> _roles = ['All', 'Admin', 'Field Worker', 'Citizen'];
  final List<String> _statuses = ['All', 'Active', 'Suspended'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final usersData = await _firestoreService.getCollection(
        collection: 'system_users',
        orderBy: 'name',
      );
      _users = usersData
          .map((data) => SystemUser.fromMap(data, data['id']))
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
      }
    }
  }

  Future<void> _suspendUser(SystemUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B2733),
        title: const Text(
          'Suspend User',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to suspend ${user.name}? This will immediately revoke their session.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D),
            ),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _firestoreService.updateDocument(
        collection: 'system_users',
        docId: user.id,
        data: {'status': 'Suspended'},
      );

      // Log action
      await _firestoreService.createDocument(
        collection: 'audit_logs',
        data: {
          'action': 'USER_SUSPENDED',
          'userId': user.id,
          'userName': user.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ User suspended'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _activateUser(SystemUser user) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'system_users',
        docId: user.id,
        data: {'status': 'Active'},
      );

      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ User activated'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _changeRole(SystemUser user) {
    showDialog(
      context: context,
      builder: (context) => ChangeRoleDialog(
        user: user,
        onConfirm: (newRole) async {
          await _updateUserRole(user, newRole);
        },
      ),
    );
  }

  Future<void> _updateUserRole(SystemUser user, String newRole) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'system_users',
        docId: user.id,
        data: {'role': newRole},
      );

      // Log action
      await _firestoreService.createDocument(
        collection: 'audit_logs',
        data: {
          'action': 'ROLE_CHANGED',
          'userId': user.id,
          'userName': user.name,
          'oldRole': user.role,
          'newRole': newRole,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Role changed successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  List<SystemUser> get _filteredUsers {
    var filtered = _users;

    if (_filterRole != 'All') {
      filtered = filtered.where((user) => user.role == _filterRole).toList();
    }

    if (_filterStatus != 'All') {
      filtered =
          filtered.where((user) => user.status == _filterStatus).toList();
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
        title: const Text(
          'User Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                _buildSummary(),
                Expanded(child: _buildUsersList()),
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
            'FILTERS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _filterRole,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF101922),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      dropdownColor: const Color(0xFF1B2733),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: _roles.map((role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _filterRole = value!);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _filterStatus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF101922),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      dropdownColor: const Color(0xFF1B2733),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: _statuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _filterStatus = value!);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final totalUsers = _users.length;
    final activeUsers = _users.where((u) => u.status == 'Active').length;
    final suspendedUsers = _users.where((u) => u.status == 'Suspended').length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Users',
              totalUsers.toString(),
              Icons.people,
              const Color(0xFF137fec),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Active',
              activeUsers.toString(),
              Icons.check_circle,
              const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Suspended',
              suspendedUsers.toString(),
              Icons.block,
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

  Widget _buildUsersList() {
    final filtered = _filteredUsers;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _buildUserCard(filtered[index]);
        },
      ),
    );
  }

  Widget _buildUserCard(SystemUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D3748)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: user.roleColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: user.roleColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: user.roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.role,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: user.roleColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: user.statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: user.statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                      'Last Login',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.getLastLoginText(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                      'User ID',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.id,
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _changeRole(user),
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Change Role'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF137fec),
                    side: const BorderSide(color: Color(0xFF137fec)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: user.status == 'Active'
                      ? () => _suspendUser(user)
                      : () => _activateUser(user),
                  icon: Icon(
                    user.status == 'Active' ? Icons.block : Icons.check_circle,
                    size: 16,
                  ),
                  label: Text(user.status == 'Active' ? 'Suspend' : 'Activate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user.status == 'Active'
                        ? const Color(0xFFFF4D4D)
                        : const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Change Role Dialog
class ChangeRoleDialog extends StatefulWidget {
  final SystemUser user;
  final Function(String newRole) onConfirm;

  const ChangeRoleDialog({
    super.key,
    required this.user,
    required this.onConfirm,
  });

  @override
  State<ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends State<ChangeRoleDialog> {
  late String _selectedRole;

  final List<String> _roles = ['Admin', 'Field Worker', 'Citizen'];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1B2733),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change User Role',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.user.name,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            RadioGroup<String>(
              groupValue: _selectedRole,
              onChanged: (value) => setState(() => _selectedRole = value!),
              child: Column(
                children: _roles
                    .map(
                      (role) => RadioListTile<String>(
                        value: role,
                        title: Text(
                          role,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                        activeColor: const Color(0xFF137fec),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFAB00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFAB00)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Color(0xFFFFAB00), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This will immediately revoke the user\'s current session',
                      style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[400],
                      side: BorderSide(color: Colors.grey[700]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onConfirm(_selectedRole);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF137fec),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


