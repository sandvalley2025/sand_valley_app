import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  final VoidCallback? onUserDeleted;

  const UserDetailPage({super.key, required this.userId, this.onUserDeleted});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isVerifying = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  void _showSnackBar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: error ? Colors.red : const Color(0xFFF7941D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _fetchUser() async {
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    final token = await _secureStorage.read(key: 'token');
    final url = Uri.parse('$baseUrl/get-user-by-id/${widget.userId}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _user = data['user'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load user.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyUser() async {
    setState(() => _isVerifying = true);
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    final token = await _secureStorage.read(key: 'token');
    final url = Uri.parse('$baseUrl/verify-user/${widget.userId}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar("Verification email sent successfully");
        await _fetchUser(); // Refresh
      } else {
        _showSnackBar("Failed to verify user", error: true);
      }
    } catch (e) {
      _showSnackBar("Error verifying user: $e", error: true);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this user?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    final token = await _secureStorage.read(key: 'token');
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    final url = Uri.parse('$baseUrl/delete-user-by-id/${widget.userId}');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar('User deleted successfully');
        widget.onUserDeleted?.call();

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showSnackBar('Failed to delete user', error: true);
      }
    } catch (e) {
      _showSnackBar('Error occurred: $e', error: true);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7941D),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                value ?? 'N/A',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifySection() {
    final isVerified = _user?['isEmailVerified'] == true;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child:
          isVerified
              ? const Row(
                children: [
                  Icon(Icons.verified, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    "This Email Verified",
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              )
              : Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isVerifying ? null : _verifyUser,
                    icon:
                        _isVerifying
                            ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.email, color: Colors.white),
                    label:
                        _isVerifying
                            ? const Text(
                              "Verifying...",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                              ),
                            )
                            : const Text(
                              "Verify Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7941D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "This email is not verified.",
                    style: TextStyle(color: Colors.orange, fontSize: 10),
                  ),
                ],
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Detail",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF7941D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF7941D)),
              )
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : Stack(
                children: [
                  RefreshIndicator(
                    color: const Color(0xFFF7941D),
                    displacement: 80,
                    onRefresh: _fetchUser,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      child: Column(
                        children: [
                          _infoRow('ID', _user!['_id']),
                          _infoRow('Username', _user!['username']),
                          _infoRow('Name', _user!['name']),
                          _infoRow('Email', _user!['email']),
                          _verifySection(),
                          _infoRow('Role', _user!['role']),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton.icon(
                        onPressed: _isDeleting ? null : _deleteUser,
                        icon:
                            _isDeleting
                                ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.delete, color: Colors.white),
                        label:
                            _isDeleting
                                ? const Text(
                                  'Deleting...',
                                  style: TextStyle(color: Colors.red),
                                )
                                : const Text('Delete User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
