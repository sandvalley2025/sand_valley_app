import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'dart:convert';
import 'package:sand_valley/widgets/background_container.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _handleForgotPassword() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final input = _emailController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email or username.';
        _isLoading = false;
      });
      return;
    }

    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final response = await http.post(
        Uri.parse(
          '$baseUrl/forgot-password',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'input': input}),
      );

      // Debug logs
      print('🔹 Body: ${response.body}');

      final data = jsonDecode(response.body);
      final msg = data['message'] as String? ?? '';

      if (response.statusCode == 200) {
        // Success → navigate to OTP
        _emailController.clear();
        Navigator.pushNamed(context, '/otp', arguments: input);
      } else {
        // API returned error code
        setState(() {
          _errorMessage =
              msg.isNotEmpty
                  ? msg
                  : 'Something went wrong (${response.statusCode})';
        });
      }
    } catch (e) {
      // Network or parse error
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFF7941D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BackgroundContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email or Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFF7941D)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFF7941D),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFF7941D),
                        ),
                      )
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleForgotPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF7941D),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Send',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
