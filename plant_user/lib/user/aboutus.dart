import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F8F1),  // Matches body background
        iconTheme: const IconThemeData(color: Color(0xFF14532D)),
        title: const Text(
          'About GreenGyaan',
          style: TextStyle(
            color: Color(0xFF14532D),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        toolbarHeight: 65,  // Optional for extra height
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'GreenGyaan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16351F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'GreenGyaan is a friendly companion for plant lovers. '
                  'Discover plants, learn how to care for them, and keep your favourites organised in one simple place.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Mission card
            _sectionCard(
              icon: Icons.spa_rounded,
              title: 'Our mission',
              text:
              'Make plant care easy and confidence‑boosting for everyone – from students decorating a desk '
                  'to plant parents designing a full balcony jungle.',
            ),
            const SizedBox(height: 16),

            // What you can do
            const Text(
              'What you can do',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _bullet('Browse plants with clear photos and quick facts.'),
            _bullet('Open detail pages for watering, light and temperature tips.'),
            _bullet('Save favourites to your wishlist so you never lose track.'),
            _bullet('Use categories to quickly find plants that fit your space.'),

            const SizedBox(height: 24),

            // Roadmap / fun section
            const Text(
              'Coming soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _bullet('Smart reminders so you water on time, not by guesswork.'),
            _bullet('Offline care guides for all your saved plants.'),
            _bullet('Community tips and curated plant collections.'),

            const SizedBox(height: 24),

            Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF16883C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Happy growing with GreenGyaan!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF16883C), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•  ',
            style: TextStyle(fontSize: 16, color: Color(0xFF16883C)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
