import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_register.dart';
import 'userdashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoggingIn = false;
  bool _rememberMe = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoggingIn = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      } else {
        final doc = snap.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        if (data['password'] == _passwordController.text.trim()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UserDashboard(userId: doc.id),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wrong password')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
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
          // Full-screen leaf background from Unsplash
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.network(
              'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=627&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // leaves background [web:140][web:130]
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay for contrast
          Container(
            color: Colors.black.withOpacity(0.35),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  // Glassy login card (no logo here)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Center(
                            child: Text(
                              'Login to your GreenGyan account',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Email Address',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'you@example.com',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                size: 20,
                                color: Color(0xFF166534),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                            ),
                            validator: (v) =>
                            v == null || v.isEmpty ? 'Enter email' : null,
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
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                            ),
                            validator: (v) =>
                            v == null || v.isEmpty ? 'Enter password' : null,
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (val) {
                                      setState(
                                              () => _rememberMe = val ?? false);
                                    },
                                    materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: forgot password
                                },
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoggingIn ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
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
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                                ),
                                child: Center(
                                  child: _isLoggingIn
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
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
                          const SizedBox(height: 18),

                          Row(
                            children: const [
                              Expanded(
                                child: Divider(
                                  thickness: 0.7,
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'New to GreenGyan?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Divider(
                                  thickness: 0.7,
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const RegisterScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.person_add_alt_rounded,
                                size: 18,
                                color: Color(0xFF166534),
                              ),
                              label: const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF166534),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF16A34A),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          const Text(
                            'By signing in, you agree to our Terms of Service and Privacy Policy.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black45,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
