import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/components/account_settings_section.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/Admin/NavBtn.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Map<String, dynamic> mainCategories = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> _logout(BuildContext context) async {
    await _secureStorage.deleteAll(); // Clear token, role, etc.
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> loadCategories() async {
    final cachedData = await _secureStorage.read(key: 'mainCategories');
    if (cachedData != null) {
      setState(() {
        mainCategories = jsonDecode(cachedData);
        _loading = false;
      });
    }

    final data = await fetchMainCategories();

    if (data.isNotEmpty) {
      await _secureStorage.write(
        key: 'mainCategories',
        value: jsonEncode(data),
      );
      if (mounted) {
        setState(() {
          mainCategories = data;
          _loading = false;
        });
      }
    } else {
      if (cachedData == null) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> fetchMainCategories() async {
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final response = await http.get(
        Uri.parse("$baseUrl/get-main-categories"),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return Map<String, dynamic>.from(jsonBody['data']);
      } else {
        debugPrint('❌ Failed to load categories: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7941D),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _logout(context),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg-main-screen.png', fit: BoxFit.cover),
          SafeArea(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EditableNavItem(
                              title: 'seeds',
                              imageUrl:
                                  mainCategories["seeds"]?["img"]?["url"] ?? "",
                              routeName: '/seed-main-admin',
                              onImageUpdated: loadCategories,
                            ),
                            const SizedBox(height: 12),
                            EditableNavItem(
                              title: 'Fertilizer',
                              imageUrl:
                                  mainCategories["Fertilizer"]?["img"]?["url"] ??
                                  "",
                              routeName: '/fertilizer-admin',
                              onImageUpdated: loadCategories,
                            ),
                            const SizedBox(height: 12),
                            EditableNavItem(
                              title: 'Insecticide',
                              imageUrl:
                                  mainCategories["Insecticide"]?["img"]?["url"] ??
                                  "",
                              routeName: '/insecticide-admin',
                              onImageUpdated: loadCategories,
                            ),
                            const SizedBox(height: 12),
                            EditableNavItem(
                              title: 'Communication',
                              imageUrl:
                                  mainCategories["Communication"]?["img"]?["url"] ??
                                  "",
                              routeName: '/communicate-admin',
                              onImageUpdated: loadCategories,
                            ),
                            const SizedBox(height: 30),
                            const AccountSettingsSection(),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
