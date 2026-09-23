import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admindashboard.dart';
import 'adminprofile.dart';

class UserManagementScreen extends StatefulWidget {
  final String adminName;
  final String email;
  final String number;
  final String location;
  final String adminDocId;

  const UserManagementScreen({
    super.key,
    required this.adminName,
    required this.email,
    required this.number,
    required this.location,
    required this.adminDocId,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  Future<void> _deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text("Delete User"),
          ],
        ),
        content: const Text(
          "Are you sure you want to delete this user?\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _toggleBlock(String userId, bool isBlocked) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'blocked': !isBlocked});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(!isBlocked ? "User blocked" : "User unblocked"),
        backgroundColor: !isBlocked ? Colors.orange : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8F1),
        elevation: 0,
        title: Text(
          'User Management',
          style: const TextStyle(color: Color(0xFF14532D)),
        ),
      ),
      body: Column(
        children: [
          // Search
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
              decoration: InputDecoration(
                hintText: "Search users by name or email...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                  const BorderSide(color: Color(0xFF16A34A), width: 2),
                ),
              ),
            ),
          ),
          // Stats (small)
          Container(
            padding: const EdgeInsets.fromLTRB(16,8,16,8),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Row(
                    children: const [
                      Expanded(child: SizedBox.shrink()),
                      Expanded(child: SizedBox.shrink()),
                      Expanded(child: SizedBox.shrink()),
                    ],
                  );
                }

                final docs = snapshot.data!.docs;

                final int totalUsers = docs.length;
                int blockedUsers = 0;
                int activeUsers = 0;

                for (final doc in docs) {
                  final data = doc.data();
                  final bool blocked = (data['blocked'] ?? false) == true;
                  final Timestamp? lastActiveTs = data['lastActive'] as Timestamp?;
                  final DateTime? lastActive =
                  lastActiveTs != null ? lastActiveTs.toDate() : null;

                  if (blocked) blockedUsers++;

                  if (lastActive != null) {
                    final now = DateTime.now();
                    if (now.difference(lastActive).inDays == 0 && !blocked) {
                      activeUsers++;
                    }
                  }
                }

                return Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        "Total Users",
                        totalUsers.toString(),
                        Icons.people,
                        0xFF16A34A,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statCard(
                        "Active Users",
                        activeUsers.toString(),
                        Icons.trending_up,
                        0xFF059669,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statCard(
                        "Blocked Users",
                        blockedUsers.toString(),
                        Icons.block,
                        0xFFDC2626,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF16A34A),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyState();
                }

                final filtered = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  final username =
                  (data['username'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery) ||
                      email.contains(searchQuery) ||
                      username.contains(searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return _noMatchState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data();
                    return _userCardList(doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(0, Icons.dashboard_rounded, "Dashboard"),
              _navItem(1, Icons.group_rounded, "Users", isActive: true),
              _navItem(2, Icons.person_rounded, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
      String title, String value, IconData icon, int colorHex) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Color(colorHex), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCardList(String userId, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown User';
    final email = data['email'] ?? '';
    final username = data['username'] ?? '';
    final createdAt = data['createdAt']?.toString().substring(0, 10) ?? '';
    final bool isBlocked = (data['blocked'] ?? false) == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showUserDetails(userId, data),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFF16A34A), Color(0xFF14532D)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      username.toString().isNotEmpty
                          ? "@$username"
                          : email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Joined: $createdAt",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _toggleBlock(userId, isBlocked),
                    style: TextButton.styleFrom(
                      foregroundColor:
                      isBlocked ? Colors.green : Colors.red,
                    ),
                    child: Text(isBlocked ? "Unblock" : "Block"),
                  ),
                  IconButton(
                    icon:
                    const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteUser(userId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserDetails(String userId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "User Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text("ID: $userId"),
              Text("Name: ${data['name'] ?? 'N/A'}"),
              Text("Email: ${data['email'] ?? 'N/A'}"),
              Text("Username: ${data['username'] ?? 'N/A'}"),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.people_outline,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No users found",
            style: TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _noMatchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off,
              size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            "No users match '$searchQuery'",
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label,
      {bool isActive = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboard(
                adminName: widget.adminName,
                email: widget.email,
                number: widget.number,
                location: widget.location,
                adminDocId: widget.adminDocId,
              ),
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminProfilePage(
                name: widget.adminName,
                email: widget.email,
                number: widget.number,
                location: widget.location,
                adminDocId: widget.adminDocId,
              ),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF16A34A) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? Colors.white : const Color(0xFF6B7280),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
