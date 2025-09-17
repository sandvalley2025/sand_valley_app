import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class AccountSettingsSection extends StatefulWidget {
  const AccountSettingsSection({super.key});

  @override
  State<AccountSettingsSection> createState() => _AccountSettingsSectionState();
}

class _AccountSettingsSectionState extends State<AccountSettingsSection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  String _originalName = '';
  String _originalUsername = '';
  String _originalEmail = '';

  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;

  bool _isEditing = false;
  bool _isUpdating = false;
  String? _updateMessage;
  bool _updateSuccess = false;
  bool _isLoading = true; // <-- Added for initial loading

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    const storage = FlutterSecureStorage();
    final name = await storage.read(key: 'name') ?? '';
    final username = await storage.read(key: 'username') ?? '';
    final email = await storage.read(key: 'email') ?? '';

    setState(() {
      _originalName = name;
      _originalUsername = username;
      _originalEmail = email;

      _nameController.text = name;
      _usernameController.text = username;
      _emailController.text = email;
      _isLoading = false; // <-- Stop loading
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _nameController.text = _originalName;
        _usernameController.text = _originalUsername;
        _emailController.text = _originalEmail;
        _oldPasswordController.clear();
        _newPasswordController.clear();
        FocusScope.of(context).unfocus();
      }
    });
  }

  Future<void> _saveChanges() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final newUsername = _usernameController.text.trim();
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    final bool changed =
        newName != _originalName ||
        newUsername != _originalUsername ||
        newEmail != _originalEmail ||
        newPassword.isNotEmpty;

    if (!changed) {
      setState(() {
        _updateMessage = "Please change at least one field.";
        _updateSuccess = false;
      });
      _clearUpdateMessageAfterDelay();
      return;
    }

    if (newPassword.isNotEmpty && oldPassword.isEmpty) {
      setState(() {
        _updateMessage = "Enter your old password to change your password.";
        _updateSuccess = false;
      });
      _clearUpdateMessageAfterDelay();
      return;
    }

    setState(() {
      _isUpdating = true;
      _updateMessage = null;
    });

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");
      final id = await storage.read(key: "id");

      final Map<String, dynamic> payload = {};
      if (newName != _originalName) payload['name'] = newName;
      if (newUsername != _originalUsername) payload['username'] = newUsername;
      if (newEmail != _originalEmail) payload['email'] = newEmail;
      if (newPassword.isNotEmpty) {
        payload['newPassword'] = newPassword;
        payload['password'] = oldPassword;
      }
      payload['id'] = id;

      final response = await http.put(
        Uri.parse("$baseUrl/update-user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['message'] == 'User updated successfully') {
        setState(() {
          _updateMessage = "Account updated successfully!";
          _updateSuccess = true;
          _originalName = newName;
          _originalUsername = newUsername;
          _originalEmail = newEmail;
        });
        if (payload.containsKey('name'))
          await storage.write(key: "name", value: newName);
        if (payload.containsKey('username'))
          await storage.write(key: "username", value: newUsername);
        if (payload.containsKey('email'))
          await storage.write(key: "email", value: newEmail);

        _oldPasswordController.clear();
        _newPasswordController.clear();
        FocusScope.of(context).unfocus();
      } else {
        setState(() {
          _updateMessage = jsonResponse['message'] ?? "Update failed.";
          _updateSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _updateMessage = "An error occurred.";
        _updateSuccess = false;
      });
    } finally {
      setState(() {
        _isUpdating = false;
        _isEditing = false;
      });
      _clearUpdateMessageAfterDelay();
    }
  }

  void _clearUpdateMessageAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _updateMessage = null;
        });
      }
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF7941D)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Settings',
          style: TextStyle(
            color: Color(0xFFF7941D),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Name',
          controller: _nameController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Username',
          controller: _usernameController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Email',
          controller: _emailController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Old Password',
          controller: _oldPasswordController,
          enabled: _isEditing,
          obscureText: !_oldPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _oldPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _oldPasswordVisible = !_oldPasswordVisible;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'New Password',
          controller: _newPasswordController,
          enabled: _isEditing,
          obscureText: !_newPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _newPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _newPasswordVisible = !_newPasswordVisible;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        if (_updateMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _updateMessage!,
              style: TextStyle(
                color: _updateSuccess ? Colors.green : Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Row(
          children: [
            _isUpdating
                ? const SizedBox(
                  height: 40,
                  width: 120,
                  child: Center(
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFFF7941D),
                      ),
                    ),
                  ),
                )
                : ElevatedButton.icon(
                  onPressed: _toggleEdit,
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  label: Text(_isEditing ? 'Cancel' : 'Edit'),
                  style: _buttonStyle(),
                ),
            const SizedBox(width: 12),
            if (_isEditing)
              ElevatedButton.icon(
                onPressed: _isUpdating ? null : _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: _buttonStyle(),
              ),
          ],
        ),
      ],
    );
  }
}
