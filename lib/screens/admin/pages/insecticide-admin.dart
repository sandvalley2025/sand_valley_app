import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/Admin/add_insecticide_section.dart';
import 'package:sand_valley/widgets/Admin/cart_insecticide_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InsecticideAdmin extends StatefulWidget {
  const InsecticideAdmin({super.key});

  @override
  State<InsecticideAdmin> createState() => _InsecticideAdminState();
}

class _InsecticideAdminState extends State<InsecticideAdmin> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _insecticides = [];
  bool _showAddSection = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInsecticides();
  }

  Future<void> _fetchInsecticides() async {
    setState(() => _isLoading = true);
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final response = await http.get(
        Uri.parse('$baseUrl/get-insecticide-data'),
      );
      final data = json.decode(response.body);
      final List fetched = data['data']['data'] ?? [];

      setState(() {
        _insecticides =
            fetched
                .map<Map<String, dynamic>>(
                  (item) => {
                    'id': item['_id'],
                    'name': item['name'],
                    'image': item['img']['url'],
                  },
                )
                .toList();
      });
    } catch (e) {
      debugPrint('Error fetching: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredInsecticides {
    final search = _searchController.text.toLowerCase();
    return _insecticides
        .where((e) => e['name'].toLowerCase().contains(search))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Insecticide',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7941D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    // Search
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFFF7941D),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    if (!_showAddSection)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed:
                                () => setState(() => _showAddSection = true),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF7941D),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (_showAddSection)
                      AddInsecticideSection(
                        onDataAdded: () async {
                          setState(() => _showAddSection = false);
                          await _fetchInsecticides();
                        },
                        onCancel: () => setState(() => _showAddSection = false),
                      ),

                    const SizedBox(height: 10),

                    // Insecticide list
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: CircularProgressIndicator(
                            color: Color(0xFFF7941D),
                          ),
                        ),
                      )
                    else if (_filteredInsecticides.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bug_report_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No insecticide found',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredInsecticides.length,
                        itemBuilder: (context, index) {
                          final item = _filteredInsecticides[index];
                          return CartInsecticideItem(
                            id: item['id'],
                            name: item['name'],
                            imageUrl: item['image'],
                            onRefresh: _fetchInsecticides,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
