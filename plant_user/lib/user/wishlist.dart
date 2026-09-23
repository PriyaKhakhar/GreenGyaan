import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'plantprofile.dart';
import 'wishlist_service.dart';

class WishlistPage extends StatelessWidget {
  final String userId;

  const WishlistPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final stream = WishlistService.wishlistStream(userId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F8F1),
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Color(0xFF14532D)),
        title: const Text(
          'Wishlist',
          style: TextStyle(
            color: Color(0xFF14532D),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        toolbarHeight: 65,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '1 plant saved',  // Hardcode temporarily to test
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 64,
                          color: const Color(0xFFE5E7EB),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No plants in wishlist yet',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: const Text(
                            'Tap the heart icon on any plant to save it here',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();

                    final imageUrl = (data['image'] ??
                        'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?q=80&w=400')
                        .toString();
                    final title = (data['title'] ?? 'Unknown plant').toString();
                    final description = (data['description'] ?? '').toString();
                    final tagLight = (data['light'] ?? 'Bright indirect').toString();
                    final tagWater = (data['water'] ?? 'Weekly').toString();
                    final tagDifficulty = (data['difficulty'] ?? 'Easy').toString();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,  // CRITICAL: start alignment
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(18),
                              ),
                              child: SizedBox(
                                width: 95,
                                height: double.infinity,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: const Color(0xFFE5F4EA),
                                        child: const Icon(
                                          Icons.local_florist,
                                          color: Color(0xFF166534),
                                          size: 35,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(11, 11, 11, 11),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await WishlistService.removeFromWishlist(
                                              userId: userId,
                                              plantId: data['plantId'] ?? doc.id,
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              size: 15,
                                              color: Color(0xFFDC2626),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Description
                                    Text(
                                      description.isEmpty ? 'No description' : description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // Tags - FIXED positioning
                                    SizedBox(
                                      height: 18,
                                      child: Row(
                                        children: [
                                          _tag(tagLight, 0xFFEFF6FF, 0xFF1D4ED8),
                                          const SizedBox(width: 3),
                                          _tag(tagWater, 0xFFE0F2FE, 0xFF0369A1),
                                          const SizedBox(width: 3),
                                          _tag(tagDifficulty, 0xFFE5F9ED, 0xFF15803D),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    // Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 24,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          side: const BorderSide(color: Color(0xFF16A34A)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PlantProfilePage1(
                                                userId: userId,
                                                plantId: data['plantId'] ?? doc.id,
                                                plantData: data,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'View Details',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF166534),
                                          ),
                                        ),
                                      ),
                                    ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, int bgHex, int textHex) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Color(bgHex),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 8.5,
            color: Color(textHex),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
