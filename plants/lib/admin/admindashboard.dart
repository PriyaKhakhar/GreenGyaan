import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plants/utils//plant_seeder.dart';

import 'add_plant.dart';
import 'plantprofile.dart';
import 'user_management.dart';
import 'adminprofile.dart';
import 'editplant.dart';
import 'add_category_page.dart';

class AdminDashboard extends StatefulWidget {
  final String adminName;
  final String email;
  final String number;
  final String location;
  final String adminDocId;

  const AdminDashboard({
    super.key,
    required this.adminName,
    required this.email,
    required this.number,
    required this.location,
    required this.adminDocId,
  });

  @override


  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    PlantSeeder.seedIfEmpty(); // 🔥 automatic JSON import
  }
  int _selectedIndex = 0;
  String selectedCategory = "All";
  String searchText = '';

  void _navigateTo(int index) {
    if (index == _selectedIndex) return;

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserManagementScreen(
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
    setState(() => _selectedIndex = index);
  }

  Future<void> _deletePlant(String id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete plant"),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('plants').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Plant deleted"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openAddCategory() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddCategoryPage()),
    );
    if (result == true || mounted) {
      setState(() {}); // Refresh categories
    }
  }

  // ✅ NEW: Toggle "All" category behavior - works for ALL categories including "All"
  void _onCategoryTap(String categoryName) {
    setState(() {
      if (selectedCategory == categoryName) {
        // If already selected, reset to show ALL plants
        selectedCategory = "All";
      } else {
        // Select new category
        selectedCategory = categoryName;
      }
      // Clear search when changing category
      searchText = '';
    });
  }

  Widget _categoryCard({
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5F5EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_florist,
                        color: Color(0xFF166534),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF14532D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.close, size: 16, color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, bool isActive) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => _navigateTo(index),
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
            if (isActive)
              ...[
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE7F7EB),
      appBar: AppBar(
        backgroundColor: const Color(0xffE7F7EB),
        elevation: 0,
        title: Text(
          'Hello, ${widget.adminName}',
          style: const TextStyle(
            color: Color(0xFF14532D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search plants',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => searchText = val.trim()),
            ),
          ),
          const SizedBox(height: 16),
          // TITLE ROW + ADD BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Explore Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF14532D),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _openAddCategory,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF166534),
                  ),
                  tooltip: 'Add category',
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // CATEGORY LIST
          SizedBox(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  final totalCount = docs.length + 1;
                  if (totalCount == 1) {
                    return const Center(
                      child: Text(
                        'Add a category to get started',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: totalCount,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = selectedCategory == "All";
                        return _categoryCard(
                          name: 'All',
                          isSelected: isSelected,
                          onTap: () => _onCategoryTap('All'), // ✅ Uses toggle logic
                          onDelete: null,
                        );
                      }
                      final doc = docs[index - 1];
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '').toString();
                      final isSelected = selectedCategory == name;
                      return _categoryCard(
                        name: name,
                        isSelected: isSelected,
                        onTap: () => _onCategoryTap(name), // ✅ Uses toggle logic
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete category?'),
                              content: Text('Delete "$name" permanently?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await FirebaseFirestore.instance
                                .collection('categories')
                                .doc(doc.id)
                                .delete();
                            if (selectedCategory == name) {
                              setState(() => selectedCategory = 'All');
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // FILTER LABEL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco_outlined, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Text(
                    selectedCategory == "All"
                        ? 'All Plants'
                        : 'Plants · $selectedCategory',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // PLANTS LIST
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('plants')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  }
                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_florist_outlined,
                              size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text(
                            'No plants added yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final allDocs = snap.data!.docs;
                  final filtered = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final categoryName =
                    (data['category'] ?? data['categoryName'] ?? '')
                        .toString();
                    final title =
                    (data['title'] ?? 'Untitled Plant').toString();
                    final matchesCategory =
                    selectedCategory == "All" ? true : categoryName == selectedCategory;
                    final matchesSearch = searchText.isEmpty
                        ? true
                        : title.toLowerCase().contains(searchText.toLowerCase());
                    return matchesCategory && matchesSearch;
                  }).toList();
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No plants match your filters',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'Untitled Plant';
                      final desc = data['description'] ?? '';
                      final region = data['region'] ?? '';
                      final climate = data['climate'] ?? '';
                      final type = data['type'] ?? '';
                      final date = data['date'] ?? '';
                      final image = data['image'] ?? '';
                      final category =
                          data['category'] ?? data['categoryName'] ?? '';
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PlantProfileScreen(plantId: doc.id),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: image.toString().isNotEmpty
                                      ? Image.network(
                                    image,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error,
                                        stackTrace) =>
                                        Container(
                                          width: double.infinity,
                                          color: Colors.green.shade100,
                                          child: const Center(
                                            child: Icon(
                                              Icons.local_florist,
                                              size: 50,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                  )
                                      : Container(
                                    width: double.infinity,
                                    color: Colors.green.shade100,
                                    child: const Center(
                                      child: Icon(
                                        Icons.local_florist,
                                        size: 50,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.fromLTRB(14, 10, 14, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius:
                                            BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            type,
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (category.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                              BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              category,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      desc,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.public,
                                            size: 18, color: Colors.green),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            region,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.wb_sunny,
                                            size: 18, color: Colors.orange),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            climate,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Added $date',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PlantProfileScreen(
                                            plantId: doc.id,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: 18,
                                      ),
                                      label: const Text("View"),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF16A34A),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: "Edit plant",
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  EditPlantScreen(docId: doc.id),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: "Delete plant",
                                          onPressed: () =>
                                              _deletePlant(doc.id, title),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff16A34A),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPlantScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
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
              _navItem(0, Icons.dashboard_rounded, "Dashboard",
                  _selectedIndex == 0),
              _navItem(1, Icons.group_rounded, "Users", _selectedIndex == 1),
              _navItem(2, Icons.person_rounded, "Profile", _selectedIndex == 2),
            ],
          ),
        ),
      ),
    );
  }
}
