import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/Admin/seeds-add_type_section.dart';
import 'package:sand_valley/widgets/Admin/seeds-type-cart.dart';

class SeedTypeAdminPage extends StatefulWidget {
  const SeedTypeAdminPage({super.key});

  @override
  State<SeedTypeAdminPage> createState() => _SeedAdminPageState();
}

class _SeedAdminPageState extends State<SeedTypeAdminPage> {
  final _secureStorage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> seedList = [];
  List<Map<String, dynamic>> filteredSeeds = [];
  bool _isLoading = true;
  bool _deleting = false;
  String? _error;
  bool _showAdd = false;

  late String categoryId;
  late String categoryName;
  String? categoryImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      categoryId = args['id'];
      categoryName = args['name'];
      categoryImage = args['image'];
      _fetchSeeds();
    }
  }

  Future<void> _fetchSeeds() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await _secureStorage.read(key: 'token');
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final res = await http.get(
        Uri.parse('$baseUrl/get-seeds-type/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        final List<dynamic> data = j['data']['Type'] as List<dynamic>;

        seedList =
            data.map((e) {
              return {
                'id': e['_id'] as String,
                'name': e['name'] as String,
                'imageUrl': e['img']['url'] ?? '',
              };
            }).toList();

        filteredSeeds = List.from(seedList);
      } else {
        _error = 'Failed to load seeds (status ${res.statusCode}).';
      }
    } catch (e) {
      _error = 'Error fetching seeds: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredSeeds =
          seedList
              .where(
                (seed) =>
                    seed['name'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _deleteItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this item?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(ctx, false),
              ),
              ElevatedButton(
                child: const Text('Delete'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _deleting = true);

    final token = await _secureStorage.read(key: 'token');
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

    final url = Uri.parse('$baseUrl/delete-seeds-type/$id');

    try {
      final res = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        setState(() {
          seedList.removeWhere((item) => item['id'] == id);
          filteredSeeds.removeWhere((item) => item['id'] == id);
        });
      } else {
        _showErrorSnackBar('Failed to delete item (Status ${res.statusCode})');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _deleting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _toggleAdd() => setState(() => _showAdd = !_showAdd);

  void _onSavedCategory() {
    setState(() => _showAdd = false);
    _fetchSeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7941D),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF7941D)),
              )
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : RefreshIndicator(
                color: const Color(0xFFF7941D),
                onRefresh: _fetchSeeds,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFF7941D),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                cursorColor: const Color(0xFFF7941D),
                                decoration: const InputDecoration(
                                  hintText: "Search...",
                                  hintStyle: TextStyle(
                                    color: Color(0xFFF7941D),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            const Icon(Icons.search, color: Color(0xFFF7941D)),
                          ],
                        ),
                      ),

                      // Add Button
                      if (!_showAdd)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ElevatedButton.icon(
                              onPressed: _toggleAdd,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Add',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF7941D),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 20,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Add Category Section
                      if (_showAdd)
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: AddSeedsTypeSection(
                            onSaved: _onSavedCategory,
                            categoryId: categoryId,
                          ),
                        ),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'Seeds subCategories',
                          style: TextStyle(
                            color: Color(0xFFF7941D),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      _deleting
                          ? const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF7941D),
                              ),
                            ),
                          )
                          : filteredSeeds.isEmpty
                          ? Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Center(
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.local_florist,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'No seeds type found',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredSeeds.length,
                            itemBuilder: (context, i) {
                              final item = filteredSeeds[i];
                              return SeedsTypeCart(
                                name: item['name'],
                                id: item['id'],
                                imageUrl: item['imageUrl'],
                                onDelete: () => _deleteItem(item['id']),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/seed-description-admin',
                                    arguments: {
                                      'id': item['id'],
                                      'name': item['name'],
                                      'image': item['imageUrl'],
                                    },
                                  );
                                },
                                fallbackWidget: const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                onUpdated: _fetchSeeds,
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),
    );
  }
}
