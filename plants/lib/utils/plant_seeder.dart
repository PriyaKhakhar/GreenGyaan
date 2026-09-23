import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlantSeeder {
  static bool _hasRun = false; // prevents re-run in same session

  static Future<void> seedIfEmpty() async {
    if (_hasRun) return;
    _hasRun = true;

    final plantsRef = FirebaseFirestore.instance.collection('plants');

    // Check if plants already exist
    final snapshot = await plantsRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      print('🌱 Plants already exist. Seeder skipped.');
      return;
    }

    print('🌱 Seeding plants from JSON...');

    final jsonString =
    await rootBundle.loadString('assets/plants.json');

    final List plants = json.decode(jsonString);

    final batch = FirebaseFirestore.instance.batch();

    for (final plant in plants) {
      final doc = plantsRef.doc();
      batch.set(doc, {
        'title': plant['title'],
        'description': plant['description'],
        'region': plant['region'],
        'climate': plant['climate'],
        'type': plant['type'],
        'categoryName': plant['categoryName'],
        'image': plant['image'],
        'scientificName': plant['scientificName'],
        'lightRequirements': plant['lightRequirements'],
        'waterFrequency': plant['waterFrequency'],
        'difficultyLevel': plant['difficultyLevel'],
        'soilType': plant['soilType'],
        'careInstructions': plant['careInstructions'],
        'heightRange': plant['heightRange'],
        'spreadRange': plant['spreadRange'],
        'date': DateTime.now().toString().substring(0, 10),
        'seeded': true,
      });
    }

    await batch.commit();
    print('✅ Plant JSON seeding completed.');
  }
}
