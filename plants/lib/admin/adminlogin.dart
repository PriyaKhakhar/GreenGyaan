import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admindashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoggingIn = false;
  bool _obscurePass = true;

  // how long admin stays logged in
  final Duration sessionDuration = const Duration(hours: 4);

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('adminLoggedIn') ?? false;
    final lastLoginMillis = prefs.getInt('adminLastLogin');

    if (!isLoggedIn || lastLoginMillis == null) return;

    final lastLogin =
    DateTime.fromMillisecondsSinceEpoch(lastLoginMillis);
    final now = DateTime.now();
    final expired = now.difference(lastLogin) > sessionDuration;

    if (expired) {
      await _clearSession(prefs);
      return;
    }

    final adminName = prefs.getString('adminName') ?? 'Admin';
    final adminEmail = prefs.getString('adminEmail') ?? '';
    final adminNumber = prefs.getString('adminNumber') ?? '';
    final adminLocation = prefs.getString('adminLocation') ?? '';
    final adminDocId = prefs.getString('adminDocId');

    if (adminDocId == null) {
      await _clearSession(prefs);
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboard(
          adminName: adminName,
          email: adminEmail,
          number: adminNumber,
          location: adminLocation,
          adminDocId: adminDocId,
        ),
      ),
    );
  }

  Future<void> _clearSession(SharedPreferences prefs) async {
    await prefs.remove('adminLoggedIn');
    await prefs.remove('adminLastLogin');
    await prefs.remove('adminName');
    await prefs.remove('adminEmail');
    await prefs.remove('adminNumber');
    await prefs.remove('adminLocation');
    await prefs.remove('adminDocId');
  }

  Future<void> _adminLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoggingIn = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final snapshot = await FirebaseFirestore.instance
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No admin found with this email."),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        if (data['password'] == password) {
          final adminName = data['name'] ?? 'Admin';
          final adminEmail = data['email'] ?? '';
          final adminNumber = data['number'] ?? '';
          final adminLocation = data['location'] ?? '';
          final adminDocId = doc.id;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('adminLoggedIn', true);
          await prefs.setInt(
            'adminLastLogin',
            DateTime.now().millisecondsSinceEpoch,
          );
          await prefs.setString('adminName', adminName);
          await prefs.setString('adminEmail', adminEmail);
          await prefs.setString('adminNumber', adminNumber);
          await prefs.setString('adminLocation', adminLocation);
          await prefs.setString('adminDocId', adminDocId);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboard(
                adminName: adminName,
                email: adminEmail,
                number: adminNumber,
                location: adminLocation,
                adminDocId: adminDocId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Incorrect password."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => _isLoggingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // FULLSCREEN NETWORK BACKGROUND IMAGE
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.network(
              'https://plus.unsplash.com/premium_photo-1663962158789-0ab624c4f17d?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay for contrast
          Container(
            color: Colors.black.withOpacity(0.35),
          ),

          // Main content directly over image
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'GreenGyaan Admin',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black26,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Secure access to your plant dashboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Glassy login card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.shield_outlined,
                                color: Color(0xFF166534),
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Admin Sign In',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Enter your admin credentials to continue.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 22),

                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'admin@greengyan.com',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                size: 20,
                                color: Color(0xFF166534),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter admin email";
                              }
                              final valid = RegExp(
                                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                              ).hasMatch(value);
                              if (!valid) return "Enter a valid email";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePass,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: Color(0xFF166534),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: const Color(0xFF6B7280),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePass = !_obscurePass;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter admin password";
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed:
                              _isLoggingIn ? null : _adminLogin,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                              ),
                              child: Ink(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF16A34A),
                                      Color(0xFF15803D),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(18),
                                  ),
                                ),
                                child: Center(
                                  child: _isLoggingIn
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child:
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
