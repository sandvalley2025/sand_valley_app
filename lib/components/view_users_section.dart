import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/screens/admin/user_detail_page.dart';

class ViewUsersSection extends StatefulWidget {
  const ViewUsersSection({super.key});

  @override
  ViewUsersSectionState createState() => ViewUsersSectionState();
}

class ViewUsersSectionState extends State<ViewUsersSection> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    final token = await _secureStorage.read(key: 'token');
    final url = Uri.parse('$baseUrl/get-users');

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
          _users = data['users'];
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch users. Try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error occurred: $e';
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Users List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF7941D),
          ),
        ),
        const SizedBox(height: 10),

        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFF7941D)),
          ),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),

        if (!_isLoading && _errorMessage == null)
          _users.isEmpty
              ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40),
                    Icon(Icons.person, color: Colors.grey, size: 25),
                    SizedBox(height: 10),
                    Text(
                      'No users found',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              )
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => UserDetailPage(
                                userId: user['_id'],
                                onUserDeleted: fetchUsers,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7941D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: Text(
                          user['username'] ?? 'No Username',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
