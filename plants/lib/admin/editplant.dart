import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class EditPlantScreen extends StatefulWidget {
  final String docId;
  const EditPlantScreen({super.key, required this.docId});

  @override
  State<EditPlantScreen> createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final regionController = TextEditingController();
  final climateController = TextEditingController();
  final scientificController = TextEditingController();
  final lightController = TextEditingController();
  final waterController = TextEditingController();
  final difficultyController = TextEditingController();
  final soilController = TextEditingController();
  final careController = TextEditingController();
  final heightController = TextEditingController();
  final spreadController = TextEditingController();

  String selectedType = "Indoor";

  String? selectedCategoryId;
  String? selectedCategoryName;

  final List<String> types = ["Indoor", "Outdoor"];

  File? selectedImage;
  String existingImageUrl = "";
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;
  XFile? pickedXFile;

  @override
  void initState() {
    super.initState();
    fetchPlantData();
  }

  Future<void> fetchPlantData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('plants')
          .doc(widget.docId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        titleController.text = data['title'] ?? '';
        descController.text = data['description'] ?? '';
        regionController.text = data['region'] ?? '';
        climateController.text = data['climate'] ?? '';
        selectedType = data['type'] ?? 'Indoor';

        selectedCategoryId = data['categoryId'];
        selectedCategoryName = data['categoryName'] ?? data['category'] ?? '';

        scientificController.text = data['scientificName'] ?? '';
        lightController.text = data['lightRequirements'] ?? '';
        waterController.text = data['waterFrequency'] ?? '';
        difficultyController.text = data['difficultyLevel'] ?? '';
        soilController.text = data['soilType'] ?? '';
        careController.text = data['careInstructions'] ?? '';
        heightController.text = data['heightRange'] ?? '';
        spreadController.text = data['spreadRange'] ?? '';

        if (data['images'] is List && (data['images'] as List).isNotEmpty) {
          existingImageUrl = (data['images'] as List).first ?? '';
        } else {
          existingImageUrl = data['image'] ?? '';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading plant: $e")),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> pickImage() async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedXFile = image;
        selectedImage = File(image.path);
      });
    }
  }

  Future<String> uploadToCloudinary(XFile imageFile) async {
    const cloudinaryUrl =
        'https://api.cloudinary.com/v1_1/dsi73bv2k/image/upload';

    final bytes = await imageFile.readAsBytes();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename:
        '${DateTime.now().millisecondsSinceEpoch}_${widget.docId}.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
      'upload_preset': 'tuitions',
    });

    final response = await Dio().post(cloudinaryUrl, data: formData);
    return response.data['secure_url'];
  }

  Future<void> updatePlant() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategoryId == null || selectedCategoryName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String imageUrl = existingImageUrl;

      if (pickedXFile != null) {
        imageUrl = await uploadToCloudinary(pickedXFile!);
      }

      final data = {
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'region': regionController.text.trim(),
        'climate': climateController.text.trim(),
        'type': selectedType,
        'categoryId': selectedCategoryId,
        'categoryName': selectedCategoryName,
        'image': imageUrl,
        'scientificName': scientificController.text.trim(),
        'lightRequirements': lightController.text.trim(),
        'waterFrequency': waterController.text.trim(),
        'difficultyLevel': difficultyController.text.trim(),
        'soilType': soilController.text.trim(),
        'careInstructions': careController.text.trim(),
        'heightRange': heightController.text.trim(),
        'spreadRange': spreadController.text.trim(),
        'date': DateTime.now().toString().substring(0, 10),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('plants')
          .doc(widget.docId)
          .update(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Plant updated successfully!"),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16A34A),
        elevation: 0,
        title: const Text(
          "Edit Plant",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF16A34A)),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 140,
                child: Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.shade50,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: selectedImage != null
                            ? Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        )
                            : (existingImageUrl.isNotEmpty
                            ? Image.network(
                          existingImageUrl,
                          fit: BoxFit.cover,
                        )
                            : const Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 34,
                            color: Color(0xFF16A34A),
                          ),
                        )),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _sectionTitle("Basic Information"),
              _field("Plant Name", titleController,
                  Icons.local_florist),
              _field("Description", descController, Icons.description,
                  maxLines: 3),
              _field("Region", regionController, Icons.public),
              _field("Climate", climateController, Icons.wb_sunny),
              _dropdownStatic(
                "Plant Type",
                selectedType,
                types,
                    (v) => setState(() => selectedType = v ?? 'Indoor'),
              ),

              _categoryDropdown(),

              const SizedBox(height: 24),

              _sectionTitle("Care Information"),
              _field("Scientific Name", scientificController,
                  Icons.science),
              _field("Light Requirements", lightController,
                  Icons.lightbulb),
              _field("Water Frequency", waterController,
                  Icons.water_drop),
              _field("Difficulty Level", difficultyController,
                  Icons.trending_up),
              _field("Soil Type", soilController, Icons.layers),
              _field("Care Instructions", careController,
                  Icons.help_outline,
                  maxLines: 3),
              _field("Height Range", heightController, Icons.height),
              _field("Spread Range", spreadController,
                  Icons.aspect_ratio),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updatePlant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Update Plant",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF14532D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
      String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF16A34A),
          ),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: Color(0xFF16A34A), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (v) => v == null || v.trim().isEmpty
            ? "$label is required"
            : null,
      ),
    );
  }

  Widget _dropdownStatic(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: _dropdownDecoration(label),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return TextFormField(
              enabled: false,
              decoration: _dropdownDecoration("Category").copyWith(
                hintText: 'No categories found, add from dashboard',
              ),
            );
          }

          if (selectedCategoryId == null &&
              selectedCategoryName != null) {
            for (final d in docs) {
              final data = d.data() as Map<String, dynamic>;
              if (data['name'] == selectedCategoryName) {
                selectedCategoryId = d.id;
                break;
              }
            }
          }

          return DropdownButtonFormField<String>(
            value: selectedCategoryId,
            decoration: _dropdownDecoration("Category"),
            items: docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              final name = (data['name'] ?? '').toString();
              return DropdownMenuItem<String>(
                value: d.id,
                child: Text(name),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                selectedCategoryId = v;
                final doc = docs.firstWhere((d) => d.id == v);
                final data = doc.data() as Map<String, dynamic>;
                selectedCategoryName = data['name'] ?? '';
              });
            },
            validator: (v) =>
            v == null ? 'Category is required' : null,
          );
        },
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(
        Icons.category,
        color: Color(0xFF16A34A),
      ),
      border:
      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF16A34A), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    regionController.dispose();
    climateController.dispose();
    scientificController.dispose();
    lightController.dispose();
    waterController.dispose();
    difficultyController.dispose();
    soilController.dispose();
    careController.dispose();
    heightController.dispose();
    spreadController.dispose();
    super.dispose();
  }
}
