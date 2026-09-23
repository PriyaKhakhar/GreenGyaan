import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  bool isSaving = false;

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);
    try {
      final name = nameController.text.trim();
      if (name.isEmpty) return;

      // Check duplicate (case-insensitive)
      final existing = await FirebaseFirestore.instance
          .collection('categories')
          .where('nameLower', isEqualTo: name.toLowerCase())
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category already exists (case-insensitive)'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        await FirebaseFirestore.instance.collection('categories').add({
          'name': name,
          'nameLower': name.toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        nameController.clear();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add category: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE7F7EB),
      appBar: AppBar(
        title: const Text(
          'Add Category',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF14532D), // ✅ Dark green text [matches dashboard]
          ),
        ),
        backgroundColor: const Color(0xffE7F7EB), // ✅ Light green background [matches screenshot]
        foregroundColor: const Color(0xFF14532D), // ✅ Dark green icons
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF14532D)), // ✅ Dark green back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Category name',
                  hintText: 'e.g. Indoor, Herbs, Succulents',
                  prefixIcon: const Icon(Icons.category, color: Color(0xFF16A34A)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter category name';
                  if (v.trim().length < 2) return 'Minimum 2 characters';
                  if (v.trim().length > 25) return 'Maximum 25 characters';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: isSaving ? null : _saveCategory,
                  child: isSaving
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Saving...'),
                    ],
                  )
                      : const Text('Save Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
