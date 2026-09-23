import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admindashboard.dart';

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
  int _selectedIndex = 1; // User Management selected

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      // Go back to admin dashboard
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
      // TODO: navigate to admin profile screen if you have one
      // Navigator.pushReplacement(...);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF5F8F1),
        elevation: 0,
        title: const Text(
          "User Management",
          style: TextStyle(
            color: Color(0xFF14532D),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFA5D6A7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No users found"));
            }

            final docs = snapshot.data!.docs;
            final int total = docs.length;
            final int blocked = docs
                .where((d) => (d.data() as Map)['blocked'] == true)
                .length;
            final int active = total - blocked;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.group, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "User Management",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Manage user access & roles",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // stat cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          active.toString(),
                          "Active",
                          Colors.green,
                          Icons.check,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          blocked.toString(),
                          "Blocked",
                          Colors.red,
                          Icons.block,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          total.toString(),
                          "Total Users",
                          Colors.blue,
                          Icons.group,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // user cards
                  ...docs.map((doc) => _buildUserCard(
                    name: (doc.data() as Map)['name'] ?? '',
                    email: (doc.data() as Map)['email'] ?? '',
                    date: ((doc.data() as Map)['createdAt'] ?? '')
                        .toString()
                        .substring(0, 10),
                    status: ((doc.data() as Map)['blocked'] ?? false)
                        ? "Blocked"
                        : "Active",
                    color: ((doc.data() as Map)['blocked'] ?? false)
                        ? Colors.red
                        : Colors.green,
                    actionText: ((doc.data() as Map)['blocked'] ?? false)
                        ? "Unblock User"
                        : "Block User",
                    actionColor: ((doc.data() as Map)['blocked'] ?? false)
                        ? Colors.green
                        : Colors.red,
                    onToggle: () async {
                      final blockedNow =
                      ((doc.data() as Map)['blocked'] ?? false) as bool;
                      await doc.reference.update({'blocked': !blockedNow});
                    },
                  )),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "User Management",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // ---------- helper widgets ----------
  Widget _buildStatCard(
      String count,
      String label,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String email,
    required String date,
    required String status,
    required Color color,
    required String actionText,
    required Color actionColor,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 5),
              Text(date),
              const SizedBox(width: 15),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                actionText,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
