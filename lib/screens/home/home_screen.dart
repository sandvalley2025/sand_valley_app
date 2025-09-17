import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/background_container.dart';
import 'package:sand_valley/widgets/customWidget.dart';
import 'package:sand_valley/widgets/customWidgetReversed.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Map<String, dynamic> mainCategories = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> _handleAdminTap() async {
    final role = await _secureStorage.read(key: 'role');
    if (role != null) {
      if (role == 'admin') {
        Navigator.pushNamed(context, '/admin-master');
      } else if (role == 'user') {
        Navigator.pushNamed(context, '/admin');
      } else {
        Navigator.pushNamed(context, '/admin-login');
      }
    } else {
      Navigator.pushNamed(context, '/admin-login');
    }
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B970C),
        toolbarHeight: 5,
      ),
      body: BackgroundContainer(
        child: Container(
          margin: EdgeInsets.only(top: screenHeight * 0.05),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
          width: screenWidth,
          child:
              _loading
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFF7941D)),
                  )
                  : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: customLayout(
                                  image:
                                      mainCategories["seeds"]?["img"]?["url"] ??
                                      "",
                                  text: "بذور",
                                  routeName: '/seed-main',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: customLayoutReversed(
                                  image:
                                      mainCategories["Fertilizer"]?["img"]?["url"] ??
                                      "",
                                  text: "اسمده",
                                  routeName: '/fertilizer-main',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: customLayout(
                                  image:
                                      mainCategories["Insecticide"]?["img"]?["url"] ??
                                      "",
                                  text: "مبيدات",
                                  routeName: '/insecticide-main',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: customLayoutReversed(
                                  image:
                                      mainCategories["Communication"]?["img"]?["url"] ??
                                      "",
                                  text: "تواصل معنا",
                                  routeName: '/communicate-main',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextButton(
                          onPressed: _handleAdminTap,
                          child: const Text(
                            'Admin Login',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFF7941D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
