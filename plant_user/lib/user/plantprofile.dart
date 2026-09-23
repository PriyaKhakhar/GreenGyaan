import 'package:flutter/material.dart';

class PlantProfilePage1 extends StatefulWidget {
  final String userId;
  final String plantId;
  final Map<String, dynamic> plantData;

  const PlantProfilePage1({
    super.key,
    required this.userId,
    required this.plantId,
    required this.plantData,
  });

  @override
  State<PlantProfilePage1> createState() => _PlantProfilePage1State();
}

class _PlantProfilePage1State extends State<PlantProfilePage1> {
  int _selectedTab = 0; // 0 info, 1 water, 2 location, 3 care

  @override
  Widget build(BuildContext context) {
    final data = widget.plantData;

    // BASIC FIELDS (match admin side names)
    final String title = data['title'] ?? 'Plant';
    final String scientific =
        data['scientific'] ?? data['scientificName'] ?? '';
    final String category =
        data['categoryName'] ?? data['category'] ?? data['type'] ?? 'Outdoor';
    final String imageUrl =
        data['image'] ?? (data['images'] is List && data['images'].isNotEmpty
            ? data['images'][0]
            : '');

    // main description / climate / type etc.
    final String description =
        data['description'] ?? data['overview'] ?? 'No description available';
    final String climate = data['climate'] ?? '';
    final String plantType = data['plantType'] ?? category;

    // WATER TAB FIELDS (admin)
    final String wateringSchedule =
        data['wateringSchedule'] ?? data['water'] ?? 'Water as needed';
    final String wateringAmount =
        data['wateringAmount'] ?? 'Keep soil slightly moist';
    final String humidity =
        data['humidity'] ?? 'Average room humidity is fine';
    final String fertilizer =
        data['fertilizer'] ?? 'Balanced fertilizer once a month';

    // LOCATION TAB FIELDS
    final String light =
        data['lightRequirements'] ?? data['light'] ?? 'Bright, indirect light';
    final String temp =
        data['temperatureRange'] ?? data['temp'] ?? '18–25°C';
    final String region = data['region'] ?? 'Temperate regions';
    final String placement =
        data['placement'] ?? 'Near a bright window, away from harsh sun';

    // CARE TAB FIELDS (like admin)
    final String soil =
        data['soilType'] ?? data['soil'] ?? 'Well-draining potting mix';
    final String careInstructions =
        data['careInstructions'] ?? 'Follow general care instructions.';
    final String pruning =
        data['pruning'] ?? 'Prune dead or yellow leaves regularly';
    final String pests =
        data['pests'] ?? 'Watch for common pests like aphids or mites';
    final String extraNotes = data['extraNotes'] ?? data['notes'] ?? '';

    final String toxicity = data['toxicity'] ?? 'Safe';
    final String careLevel =
        data['careLevel'] ?? data['difficultyLevel'] ?? 'Moderate';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F1),
      body: Column(
        children: [
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF14532D)),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF14532D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _heroSection(
                    imageUrl: imageUrl,
                    category: category,
                    title: title,
                    scientific: scientific,
                    climate: climate,
                    plantType: plantType,
                    toxicity: toxicity,
                    careLevel: careLevel,
                  ),
                  const SizedBox(height: 12),
                  _tabBar(),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildTabContent(
                      description: description,
                      climate: climate,
                      plantType: plantType,
                      wateringSchedule: wateringSchedule,
                      wateringAmount: wateringAmount,
                      humidity: humidity,
                      fertilizer: fertilizer,
                      light: light,
                      temp: temp,
                      region: region,
                      placement: placement,
                      soil: soil,
                      careInstructions: careInstructions,
                      pruning: pruning,
                      pests: pests,
                      extraNotes: extraNotes,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HERO SECTION ----------------

  Widget _heroSection({
    required String imageUrl,
    required String category,
    required String title,
    required String scientific,
    required String climate,
    required String plantType,
    required String toxicity,
    required String careLevel,
  }) {
    const fallbackImage =
        'https://images.unsplash.com/photo-1470115636492-6d2b56f9146e?auto=format&fit=crop&w=900&q=80';

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          child: SizedBox(
            height: 230,
            width: double.infinity,
            child: Image.network(
              imageUrl.isNotEmpty ? imageUrl : fallbackImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 230,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.black.withOpacity(0.15),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _chip(category),
                  const SizedBox(width: 8),
                  if (plantType.isNotEmpty) _chip(plantType),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (scientific.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  scientific,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ],
              if (climate.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Climate: $climate',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _heroInfoItem('Type', plantType),
                  _heroInfoItem('Toxicity', toxicity),
                  _heroInfoItem('Care level', careLevel),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _heroInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TAB BAR ----------------

  Widget _tabBar() {
    final tabs = [
      {'icon': Icons.menu_book_rounded, 'label': 'Info'},
      {'icon': Icons.water_drop_rounded, 'label': 'Water'},
      {'icon': Icons.place_rounded, 'label': 'Location'},
      {'icon': Icons.grass_rounded, 'label': 'Care'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(
                      tabs[index]['icon'] as IconData,
                      size: 20,
                      color: selected
                          ? const Color(0xFF166534)
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tabs[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected
                            ? const Color(0xFF166534)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------------- TAB CONTENT ----------------

  Widget _buildTabContent({
    required String description,
    required String climate,
    required String plantType,
    required String wateringSchedule,
    required String wateringAmount,
    required String humidity,
    required String fertilizer,
    required String light,
    required String temp,
    required String region,
    required String placement,
    required String soil,
    required String careInstructions,
    required String pruning,
    required String pests,
    required String extraNotes,
  }) {
    switch (_selectedTab) {
      case 0:
      // INFO TAB – like admin info
        return Column(
          children: [
            _card(
              title: 'Overview',
              body: description,
            ),
            const SizedBox(height: 10),
            _card(
              title: 'Basic details',
              body:
              'Plant type: $plantType\nClimate: ${climate.isEmpty ? 'Not specified' : climate}',
            ),
          ],
        );

      case 1:
      // WATER TAB
        return Column(
          children: [
            _card(
              title: 'Watering schedule',
              body: wateringSchedule,
            ),
            const SizedBox(height: 10),
            _card(
              title: 'How much to water',
              body: wateringAmount,
            ),
            const SizedBox(height: 10),
            _card(
              title: 'Humidity & fertilizer',
              body: 'Humidity: $humidity\n\nFertilizer: $fertilizer',
            ),
          ],
        );

      case 2:
      // LOCATION TAB
        return Column(
          children: [
            _card(
              title: 'Light requirements',
              body: light,
            ),
            const SizedBox(height: 10),
            _card(
              title: 'Temperature & region',
              body: 'Best region: $region\n\nTemperature: $temp',
            ),
            const SizedBox(height: 10),
            _card(
              title: 'Placement',
              body: placement,
            ),
          ],
        );

      case 3:
      // CARE TAB – separate cards like admin
        return Column(
          children: [
            _card(
              title: 'Soil type',
              body: soil,
            ),
            const SizedBox(height: 10),
            _card(
              title: 'Care instructions',
              body: careInstructions,
            ),
            if (pruning.isNotEmpty) ...[
              const SizedBox(height: 10),
              _card(
                title: 'Pruning',
                body: pruning,
              ),
            ],
            if (pests.isNotEmpty) ...[
              const SizedBox(height: 10),
              _card(
                title: 'Pests & diseases',
                body: pests,
              ),
            ],
            if (extraNotes.isNotEmpty) ...[
              const SizedBox(height: 10),
              _card(
                title: 'Extra notes',
                body: extraNotes,
              ),
            ],
          ],
        );

      default:
        return _card(title: 'Overview', body: description);
    }
  }

  Widget _card({required String title, required String body}) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(14),
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
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
