import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admindashboard.dart';
import 'adminlogin.dart';
import 'user_management.dart';
import 'editprofile.dart';

class AdminProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String number;
  final String location;
  final String adminDocId;

  const AdminProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.number,
    required this.location,
    required this.adminDocId,
  });

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  int selectedIndex = 2;

  void onItemTapped(int index) {
    if (index == selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboard(
            adminName: widget.name,
            email: widget.email,
            number: widget.number,
            location: widget.location,
            adminDocId: widget.adminDocId,
          ),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserManagementScreen(
            adminName: widget.name,
            email: widget.email,
            number: widget.number,
            location: widget.location,
            adminDocId: widget.adminDocId,
          ),
        ),
      );
    }
    setState(() => selectedIndex = index);
  }

  // ✅ CONFIRM LOGOUT WITH PROPER SESSION CLEARING**
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 28),
            SizedBox(width: 12),
            Text(
              "Logout?",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Are you sure you want to sign out?"),
            SizedBox(height: 8),
            Text(
              "This will end your 4-hour session and return you to the login screen.",
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Stay"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

        ],
      ),
    );

    if (confirm != true) return;


    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminLoggedIn');
    await prefs.remove('adminLastLogin');
    await prefs.remove('adminName');
    await prefs.remove('adminEmail');
    await prefs.remove('adminNumber');
    await prefs.remove('adminLocation');
    await prefs.remove('adminDocId');

    if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text("Logged out successfully! 👋"),
    backgroundColor: Color(0xFFDC2626),
    duration: Duration(seconds: 2),
    ),
    );

    // ✅ FORCE LOGIN SCREEN - No auto-login anymore
    Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    (route) => false,
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F8F1),
        iconTheme: const IconThemeData(color: Color(0xFF14532D)),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF14532D),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Color(0xFF16A34A), Color(0xFF14532D)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditAdminProfilePage(
                            docId: widget.adminDocId,
                            name: widget.name,
                            email: widget.email,
                            number: widget.number,
                            location: widget.location,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Edit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account info
            const Text(
              "Account Info",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            _infoTile(Icons.email_outlined, "Email", widget.email),
            _infoTile(Icons.phone_outlined, "Phone", widget.number),
            _infoTile(Icons.location_on_outlined, "Location", widget.location),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('admins')
                  .doc(widget.adminDocId)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snap) {
                String joinedDate = "Joined recently";
                if (snap.hasData && snap.data!.exists) {
                  final data = snap.data!.data();
                  if (data != null) {
                    joinedDate =
                        data['createdAt']?.toString().substring(0, 10) ??
                            "Joined recently";
                  }
                }
                return _infoTile(
                    Icons.calendar_today_outlined, "Joined", joinedDate);
              },
            ),
            const SizedBox(height: 24),

            // More / Logout
            const Text(
              "More",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            _actionTile(
              Icons.logout_rounded,
              "Logout",
              "Sign out from this device",
              const Color(0xFFDC2626),
              _handleLogout, // ✅ Uses confirmation dialog
            ),
          ],
        ),
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
              _navItem(1, Icons.group_rounded, "Users"),
              _navItem(2, Icons.person_rounded, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F4EA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF16A34A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
      IconData icon,
      String title,
      String subtitle,
      Color iconColor,
      VoidCallback onTap,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final bool isActive = selectedIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => onItemTapped(index),
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
