import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadPlantsFromJson() async {
  final String jsonString =
  await rootBundle.loadString('assets/plants.json');

  final List plants = json.decode(jsonString);

  final collection = FirebaseFirestore.instance.collection('plants');

  for (var plant in plants) {
    await collection.add({
      'title': plant['title'],
      'description': plant['description'],
      'region': plant['region'],
      'climate': plant['climate'],
      'type': plant['type'], // Indoor / Outdoor
      'categoryName': plant['categoryName'],
      'image': plant['image'], // already a URL
      'scientificName': plant['scientificName'],
      'lightRequirements': plant['lightRequirements'],
      'waterFrequency': plant['waterFrequency'],
      'difficultyLevel': plant['difficultyLevel'],
      'soilType': plant['soilType'],
      'careInstructions': plant['careInstructions'],
      'heightRange': plant['heightRange'],
      'spreadRange': plant['spreadRange'],
      'date': DateTime.now().toString().substring(0, 10),
    });
  }

  print("JSON upload completed");
}
