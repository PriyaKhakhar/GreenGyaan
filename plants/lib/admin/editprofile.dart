import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class EditAdminProfilePage extends StatefulWidget {
  final String docId;
  final String name;
  final String email;
  final String number;
  final String location;

  const EditAdminProfilePage({
    super.key,
    required this.docId,
    required this.name,
    required this.email,
    required this.number,
    required this.location,
  });

  @override
  State<EditAdminProfilePage> createState() => _EditAdminProfilePageState();
}

class _EditAdminProfilePageState extends State<EditAdminProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController numberController;
  late TextEditingController locationController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    numberController = TextEditingController(text: widget.number);
    locationController = TextEditingController(text: widget.location);
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(widget.docId)
          .update({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'number': numberController.text.trim(),
        'location': locationController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Update failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    numberController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F8F1),
        appBar: AppBar(
    backgroundColor: const Color(0xFFF5F8F1),
    elevation: 0,
    title: const Text(
    "Edit Profile",
    style: TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w700,
    ),
    ),
    leading: IconButton(
    icon: const Icon(Icons.close, color: Color(0xFF14532D)),
    onPressed: () => Navigator.pop(context),
    ),
    ),
    body: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Form(
    key: _formKey,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Profile Preview Card
    Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    margin: const EdgeInsets.only(bottom: 32),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [
    Colors.green.shade50,
    Colors.green.shade100,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 20,
    offset: const Offset(0, 8),
    ),
    ],
    ),
    child: Column(
    children: [
    Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
    gradient: const RadialGradient(
    colors: [Color(0xFF16A34A), Color(0xFF14532D)],
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 12,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    child: const Icon(
    Icons.admin_panel_settings,
    color: Colors.white,
    size: 40,
    ),
    ),
    const SizedBox(height: 16),
    Text(
    nameController.text.isEmpty
    ? "Admin"
        : nameController.text,
    style: GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF14532D),
    ),
    ),
    const SizedBox(height: 4),
    Text(
    emailController.text,
    style: GoogleFonts.poppins(
    fontSize: 14,
    color: const Color(0xFF6B7280),
    ),
    ),
    ],
    ),
    ),

    // Name Field
    _field(
    label: "Full Name",
    controller: nameController,
    icon: Icons.person_outline,
    validator: (v) => v == null || v.trim().isEmpty
    ? "Name is required"
        : (v.trim().length < 2 ? "Name too short" : null),
    onChanged: (_) => setState(() {}),
    ),

    // Email Field
    _field(
    label: "Email",
    controller: emailController,
    icon: Icons.email_outlined,
    keyboard: TextInputType.emailAddress,
    validator: (v) {
    if (v == null || v.trim().isEmpty) {
    return "Email is required";
    }
    final valid = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    ).hasMatch(v.trim());
    return !valid ? "Enter valid email" : null;
    },
    onChanged: (_) => setState(() {}),
    ),

    // Phone Field
    _field(
    label: "Phone Number",
    controller: numberController,
    icon: Icons.phone_outlined,
    keyboard: TextInputType.phone,
    validator: (v) => v == null || v.trim().isEmpty
    ? "Phone number is required"
        : (v.trim().length < 10
    ? "Enter valid phone number"
        : null),
    ),

    // Location Field
    _field(
    label: "Location",
    controller: locationController,
    icon: Icons.location_on_outlined,
    validator: (v) => v == null || v.trim().isEmpty
    ? "Location is required"
        : null,
    ),

    const SizedBox(height: 32),

    // Save Button
    SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton.icon(
    onPressed: isLoading ? null : updateProfile,
    icon: isLoading
    ? const SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
    color: Colors.white,
    strokeWidth: 2,
    ),
    )
        : const Icon(Icons.save, size: 20),
    label: Text(
    isLoading ? "Saving..." : "Save Changes",
    style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    ),
    ),
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF16A34A),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
    elevation: 4,
    shadowColor: const Color(0xFF16A34A).withOpacity(0.3),
    ),
    ),
    ),

    const SizedBox(height: 20),

    // Reset Password Section
    Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
    color: Colors.red.shade50,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.red.shade200),
    ),
    child: Column(
    children: [
    Icon(
    Icons.security,
    color: Colors.red.shade600,
    size: 28,
    ),
    const SizedBox(height: 12),
    const Text(
    "Reset Password",
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF991B1B),
    ),
    ),
    const SizedBox(height: 8),
    Text(
    "Contact super admin or use recovery email to reset password",
    textAlign: TextAlign.center,
    style: TextStyle(
    fontSize: 13,
    color: Colors.red.shade700,
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF16A34A),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: Color(0xFF16A34A),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 16,
        ),
      ),
    );
  }
}
