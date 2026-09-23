import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'userprofile.dart';
import 'wishlist.dart';
import 'plantprofile.dart';

// =================== USER DASHBOARD (BOTTOM NAV) ===================

class UserDashboard extends StatefulWidget {
  final String userId;
  final int initialTab; // 0 = home, 1 = wishlist

  const UserDashboard({
    super.key,
    required this.userId,
    this.initialTab = 0,
  });

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  void _onBottomTap(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfilePage(userId: widget.userId),
        ),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_selectedIndex == 0) {
      body = FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          String username = '';
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data()!;
            username = (data['username'] ?? data['name'] ?? '').toString();
          }
          return HomeScreen(
            userId: widget.userId,
            username: username,
          );
        },
      );
    } else {
      body = WishlistPage(userId: widget.userId);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F1),
      body: SafeArea(child: body),
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
              _navItem(index: 0, icon: Icons.home_rounded, label: 'Home'),
              _navItem(
                  index: 1, icon: Icons.favorite_rounded, label: 'Wishlist'),
              _navItem(
                  index: 2, icon: Icons.person_rounded, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = _selectedIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => _onBottomTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive && index != 2
              ? const Color(0xFF166534)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: (isActive && index != 2)
                  ? Colors.white
                  : const Color(0xFF6B7280),
            ),
            if (isActive && index != 2) ...[
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

// =================== HOME SCREEN ===================

class HomeScreen extends StatefulWidget {
  final String userId;
  final String username;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _plantQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    setState(() => _plantQuery = q);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final greeting = widget.username.isEmpty
        ? 'Hello Plant Lover'
        : 'Hello ${widget.username}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF14532D),
                child: Icon(
                  Icons.spa_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF14532D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // SEARCH BAR (plant name)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F1DE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Color(0xFF6B7280)),
                hintText: 'Search plants by name...',
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 6),

          if (_plantQuery.isNotEmpty) ...[
            Text(
              'Results for: "${_searchController.text}"',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
          ] else
            const SizedBox(height: 12),

          // HERO BANNER (images move, text fixed)
          _HeroBanner(
            onExplore: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllPlantsPage(userId: widget.userId),
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          // EXPLORE CATEGORIES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Explore Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF14532D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 110,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No categories found',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final title = (data['name'] ?? '').toString();

                    return _CategoryChipCard(
                      title: title,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryPlantsPage(
                              userId: widget.userId,
                              categoryId: doc.id,
                              categoryName: title,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // FEATURED PLANTS HEADER + VIEW ALL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Plants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF14532D),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllPlantsPage(userId: widget.userId),
                    ),
                  );
                },
                child: const Text(
                  'View All →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          FeaturedPlantsSection(
            userId: widget.userId,
            searchQuery: _plantQuery,
          ),
        ],
      ),
    );
  }
}

// =================== HERO BANNER: MOVING IMAGES ONLY ===================

class _HeroBanner extends StatelessWidget {
  final VoidCallback onExplore;

  const _HeroBanner({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    // Multiple Unsplash plant images
    final images = [
      'https://images.unsplash.com/photo-1658464902122-3c08e175ba38?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1700479320988-734553e7335f?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1503149779833-1de50ebe5f8a?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8bGVhdmVzfGVufDB8fDB8fHww',
      'https://plus.unsplash.com/premium_photo-1663953003855-8dc706b24154?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fHRyZWVzfGVufDB8fDB8fHww',
    ];

    return _HeroImageCarousel(
      images: images,
      onExplore: onExplore,
    );
  }
}

class _HeroImageCarousel extends StatefulWidget {
  final List<String> images;
  final VoidCallback onExplore;

  const _HeroImageCarousel({
    required this.images,
    required this.onExplore,
  });

  @override
  State<_HeroImageCarousel> createState() => _HeroImageCarouselState();
}

class _HeroImageCarouselState extends State<_HeroImageCarousel> {
  final PageController _pageController = PageController();
  int _current = 0;

  @override
  void initState() {
    super.initState();
    // Auto-move only images
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      _current = (_current + 1) % widget.images.length;
      _pageController.animateToPage(
        _current,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
      return true;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // MOVING IMAGES ONLY
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Image.network(
                widget.images[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
          // gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.1),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          // TOP LABEL
          Positioned(
            top: 18,
            left: 18,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Featured This Week',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // FIXED TEXT + BUTTON
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover the Beauty of\nPlants',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore our curated collection of plants and learn\nhow to care for them',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: widget.onExplore,
                    icon: const Icon(Icons.spa_rounded, size: 18),
                    label: const Text(
                      'Explore Plants',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================== CATEGORY CHIP CARD ===================

class _CategoryChipCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _CategoryChipCard({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFE5F1DE),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFD6E8CC),
              child: Icon(
                Icons.local_florist,
                color: Color(0xFF14532D),
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF14532D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== FEATURED PLANTS (SEARCH ON title) ===================

class FeaturedPlantsSection extends StatelessWidget {
  final String userId;
  final String searchQuery;

  const FeaturedPlantsSection({
    super.key,
    required this.userId,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final plantsCol = FirebaseFirestore.instance.collection('plants');

    Query<Map<String, dynamic>> baseQuery;

    if (searchQuery.isNotEmpty) {
      final q = searchQuery;

      baseQuery = plantsCol
          .orderBy('title')
          .where('title', isGreaterThanOrEqualTo: q)
          .where('title', isLessThanOrEqualTo: '$q\uf8ff');
    } else {
      baseQuery = plantsCol.orderBy('date', descending: true).limit(20);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: baseQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No plants found',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final title = data['title'] ?? '';
            final scientific = data['scientific'] ?? '';
            final category =
                data['categoryName'] ?? data['category'] ?? '';
            final imageUrl = data['image'] ?? '';

            return PlantListTile(
              userId: userId,
              plantId: doc.id,
              data: data,
              title: title,
              scientific: scientific,
              category: category,
              imageUrl: imageUrl,
            );
          },
        );
      },
    );
  }
}




class PlantListTile extends StatelessWidget {
  final String userId;
  final String plantId;
  final Map<String, dynamic> data;
  final String title;
  final String scientific;
  final String category;
  final String imageUrl;

  const PlantListTile({
    super.key,
    required this.userId,
    required this.plantId,
    required this.data,
    required this.title,
    required this.scientific,
    required this.category,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final wishRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('my_plants')
        .doc(plantId);

    final plantRef =
    FirebaseFirestore.instance.collection('plants').doc(plantId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: plantRef.snapshots(),
      builder: (context, plantSnap) {
        if (plantSnap.hasData && !plantSnap.data!.exists) {
          wishRef.get().then((w) {
            if (w.exists) {
              wishRef.delete();
            }
          });
          return const SizedBox.shrink();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: wishRef.snapshots(),
          builder: (context, wishSnap) {
            final bool isInWishlist =
                wishSnap.hasData && wishSnap.data!.exists;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlantProfilePage1(
                      userId: userId,
                      plantId: plantId,
                      plantData: data,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(18),
                      ),
                      child: SizedBox(
                        width: 110,
                        height: double.infinity,
                        child: imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Container(
                          color: const Color(0xFFE0F1E0),
                          child: const Icon(
                            Icons.local_florist,
                            color: Color(0xFF3C6B3C),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title.isEmpty
                                        ? 'Untitled plant'
                                        : title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      if (isInWishlist) {
                                        await wishRef.delete();
                                      } else {
                                        await wishRef.set({
                                          'plantId': plantId,
                                          'userId': userId,
                                          'addedAt':
                                          FieldValue.serverTimestamp(),
                                          'title': title,
                                          'image': imageUrl,
                                          'category': category,
                                        });
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                          Text('Wishlist error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Icon(
                                    isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isInWishlist
                                        ? Colors.red
                                        : const Color(0xFF9CA3AF),
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Type: $category',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            if (scientific.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                scientific,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}



// =================== CATEGORY PLANTS PAGE ===================

class CategoryPlantsPage extends StatelessWidget {
  final String userId;
  final String categoryId;
  final String categoryName;

  const CategoryPlantsPage({
    super.key,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8F1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF14532D)),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: Color(0xFF14532D),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('plants')
            .where('categoryId', isEqualTo: categoryId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No plants found in this category',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final imageUrl = data['image'] ?? '';
              final title = data['title'] ?? '';
              final subtitle = data['scientific'] ?? '';
              final category =
                  data['categoryName'] ?? data['category'] ?? categoryName;

              return PlantListTile(
                userId: userId,
                plantId: doc.id,
                data: data,
                title: title,
                scientific: subtitle,
                category: category,
                imageUrl: imageUrl,
              );
            },
          );
        },
      ),
    );
  }
}

// =================== ALL PLANTS PAGE (VIEW ALL) ===================

class AllPlantsPage extends StatelessWidget {
  final String userId;

  const AllPlantsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8F1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF14532D)),
        title: const Text(
          'All Plants',
          style: TextStyle(
            color: Color(0xFF14532D),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('plants')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No plants found',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final imageUrl = data['image'] ?? '';
              final title = data['title'] ?? '';
              final subtitle = data['scientific'] ?? '';
              final category =
                  data['categoryName'] ?? data['category'] ?? '';

              return PlantListTile(
                userId: userId,
                plantId: doc.id,
                data: data,
                title: title,
                scientific: subtitle,
                category: category,
                imageUrl: imageUrl,
              );
            },
          );
        },
      ),
    );
  }
}
