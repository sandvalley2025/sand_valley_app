import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _login() async {
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        _errorMessage = null;
      });

      final url = Uri.parse('$baseUrl/login');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
          }),
        );

        final data = jsonDecode(response.body);

        if (data['message'] == 'Login successful') {
          final user = data['user'];
          final role = user['role'];

          // Store login details securely
          await _secureStorage.write(key: 'token', value: user['token']);
          await _secureStorage.write(key: 'name', value: user['name']);
          await _secureStorage.write(key: 'username', value: user['username']);
          await _secureStorage.write(key: 'email', value: user['email']);
          await _secureStorage.write(key: 'id', value: user['id']);
          await _secureStorage.write(key: 'role', value: role);

          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin-master');
          } else if (role == 'user') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            setState(() {
              _errorMessage = 'Unknown role: $role';
            });
            _clearErrorAfterDelay();
          }
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Login failed';
          });
          _clearErrorAfterDelay();
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
        _clearErrorAfterDelay();
      }

      setState(() => isLoading = false);
    }
  }

  void _clearErrorAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7941D),
        title: const Text(
          'ADMIN LOGIN',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg-main-screen.png', fit: BoxFit.cover),
          Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF7941D),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Email Input
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.black),
                            decoration: _inputDecoration('Email'),
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Enter your email' : null,
                          ),
                          const SizedBox(height: 20),

                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.black),
                            decoration: _inputDecoration('Password').copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Enter your password'
                                        : null,
                          ),
                          const SizedBox(height: 10),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/admin-forgot-password',
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFFF7941D),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          // Error Message
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],

                          const SizedBox(height: 30),

                          // Login Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF7941D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 8,
                              ),
                              elevation: 0,
                              splashFactory: NoSplash.splashFactory,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: isLoading ? null : _login,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: isLoading ? 0 : 1,
                                  child: const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isLoading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Copyright
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '© FM Software 2025',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFF7941D)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFF7941D), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
