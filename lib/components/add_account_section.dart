import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class AddAccountSection extends StatefulWidget {
  final VoidCallback? onUserAdded;

  const AddAccountSection({super.key, this.onUserAdded});

  @override
  State<AddAccountSection> createState() => _AddAccountSectionState();
}

class _AddAccountSectionState extends State<AddAccountSection> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isCreating = false;
  bool _passwordVisible = false;
  String? _createUserMessage;
  bool _isSuccess = false;

  Future<void> _createUser() async {
    final username = _usernameController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    const storage = FlutterSecureStorage();

    final token = await storage.read(key: "token");

    if (username.isEmpty || name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _createUserMessage = "Please fill in all fields.";
        _isSuccess = false;
      });
      _clearMessageAfterDelay();
      return;
    }

    setState(() {
      _isCreating = true;
      _createUserMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "username": username,
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['message'] == 'Registration successful') {
        setState(() {
          _createUserMessage = "User created successfully!";
          _isSuccess = true;
        });

        _usernameController.clear();
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();

        // 🔁 Refresh user list in parent
        widget.onUserAdded?.call();
      } else {
        setState(() {
          _createUserMessage =
              jsonResponse['message'] ?? "Failed to create user.";
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _createUserMessage = "Error occurred while creating user.";
        _isSuccess = false;
      });
    } finally {
      setState(() => _isCreating = false);
      _clearMessageAfterDelay();
    }
  }

  void _clearMessageAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _createUserMessage = null;
        });
      }
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF7941D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF7941D), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF7941D), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF7941D), width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF7941D),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create New User',
          style: TextStyle(
            color: Color(0xFFF7941D),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Username', controller: _usernameController),
        const SizedBox(height: 12),
        _buildTextField(label: 'Name', controller: _nameController),
        const SizedBox(height: 12),
        _buildTextField(label: 'Email', controller: _emailController),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Password',
          controller: _passwordController,
          obscureText: !_passwordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        if (_createUserMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _createUserMessage!,
              style: TextStyle(
                color: _isSuccess ? Colors.green : Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isCreating ? null : _createUser,
            style: _buttonStyle(),
            child:
                _isCreating
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Create User',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 14,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
