import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlantProfileScreen extends StatelessWidget {
  final String plantId;

  const PlantProfileScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7ED),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('plants')
            .doc(plantId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF16A34A)),
            );
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text("Plant not found"));
          }

          final data = snap.data!.data()!;

          final title = data['title'] ?? '';
          final type = data['type'] ?? '';
          final category = data['category'] ?? '';
          final region = data['region'] ?? '';
          final climate = data['climate'] ?? '';
          final description = data['description'] ?? '';
          final image = data['images'] is List && (data['images'] as List).isNotEmpty
              ? (data['images'] as List)[0]
              : (data['image'] ?? '');

          final scientific = data['scientificName'] ?? '';
          final light = data['lightRequirements'] ?? '';
          final water = data['waterFrequency'] ?? '';
          final difficulty = data['difficultyLevel'] ?? '';
          final soil = data['soilType'] ?? '';
          final care = data['careInstructions'] ?? '';
          final height = data['heightRange'] ?? '';
          final spread = data['spreadRange'] ?? '';

          return DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 260,
                  backgroundColor: const Color(0xFF16A34A),
                  iconTheme: const IconThemeData(color: Colors.white),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        image.toString().isNotEmpty
                            ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.green.shade200,
                            child: const Icon(
                              Icons.local_florist,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        )
                            : Container(
                          color: Colors.green.shade200,
                          child: const Icon(
                            Icons.local_florist,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  _chip(type.toString(), Colors.white),
                                  const SizedBox(width: 8),
                                  _chip(category.toString(), Colors.white70),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                region,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Climate: $climate",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarHeaderDelegate(
                    TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: const [
                        Tab(icon: Icon(Icons.info_outline), text: "Info"),
                        Tab(icon: Icon(Icons.water_drop_outlined), text: "Water"),
                        Tab(icon: Icon(Icons.place_outlined), text: "Location"),
                        Tab(icon: Icon(Icons.grass_outlined), text: "Care"),
                      ],
                    ),
                  ),
                ),
              ],
              body: Container(
                color: const Color(0xFFF3F7ED),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: TabBarView(
                  children: [
                    // INFO TAB
                    ListView(
                      children: [
                        _sectionCard(
                          "About this plant",
                          description.isEmpty
                              ? "No description available."
                              : description,
                        ),
                        _infoRow("Scientific name", scientific),
                        _infoRow("Height range", height),
                        _infoRow("Spread range", spread),
                      ],
                    ),
                    // WATER TAB
                    ListView(
                      children: [
                        _sectionCard(
                          "Watering",
                          water.isEmpty ? "Not specified" : water,
                        ),
                        _infoRow("Difficulty level", difficulty),
                      ],
                    ),
                    // LOCATION TAB
                    ListView(
                      children: [
                        _sectionCard(
                          "Region",
                          region.isEmpty ? "Not specified" : region,
                        ),
                        _sectionCard(
                          "Preferred light",
                          light.isEmpty ? "Not specified" : light,
                        ),
                        _infoRow("Climate", climate),
                      ],
                    ),
                    // CARE TAB
                    ListView(
                      children: [
                        _sectionCard(
                          "Soil type",
                          soil.isEmpty ? "Not specified" : soil,
                        ),
                        _sectionCard(
                          "Care instructions",
                          care.isEmpty ? "No detailed instructions." : care,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chip(String text, Color color) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionCard(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF14532D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content.isEmpty ? "-" : content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return _sectionCard(label, value.isEmpty ? "Not specified" : value);
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarHeaderDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF16A34A),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) => false;
}
