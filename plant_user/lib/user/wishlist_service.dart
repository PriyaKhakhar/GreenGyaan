import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // /users/{userId}/my_plants
  static CollectionReference<Map<String, dynamic>> _userWishlistCol(
      String userId) {
    return _db.collection('users').doc(userId).collection('my_plants');
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> wishlistStream(
      String userId) {
    return _userWishlistCol(userId)
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  static Stream<bool> isInWishlistStream({
    required String userId,
    required String plantId,
  }) {
    return _userWishlistCol(userId)
        .doc(plantId)
        .snapshots()
        .map((snap) => snap.exists);
  }

  static Future<void> addToWishlist({
    required String userId,
    required String plantId,
    required Map<String, dynamic> plantData,
  }) async {
    await _userWishlistCol(userId).doc(plantId).set({
      'plantId': plantId,
      'userId': userId,
      'addedAt': FieldValue.serverTimestamp(),
      'title': plantData['title'] ?? '',
      'scientificName':
      plantData['scientific'] ?? plantData['scientificName'] ?? '',
      'description': plantData['description'] ?? '',
      'image': plantData['image'] ?? '',
      'category':
      plantData['categoryName'] ?? plantData['category'] ?? 'Unknown',
      'light': plantData['lightRequirements'] ??
          plantData['light'] ??
          'Bright indirect light',
      'water':
      plantData['waterFrequency'] ?? plantData['water'] ?? 'Weekly',
      'difficulty': plantData['difficultyLevel'] ??
          plantData['difficulty'] ??
          'Easy',
    }, SetOptions(merge: true));
  }

  static Future<void> removeFromWishlist({
    required String userId,
    required String plantId,
  }) async {
    await _userWishlistCol(userId).doc(plantId).delete();
  }
}
