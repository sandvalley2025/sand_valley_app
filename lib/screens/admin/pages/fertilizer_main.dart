import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/Admin/add_fertilizer_section.dart';
import 'package:sand_valley/widgets/Admin/fertilizer_card.dart';

class FertilizerAdminPage extends StatefulWidget {
  const FertilizerAdminPage({super.key});

  @override
  State<FertilizerAdminPage> createState() => _FertilizerAdminPageState();
}

class _FertilizerAdminPageState extends State<FertilizerAdminPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _fertilizers = [];
  bool _isLoading = true;
  bool _showAddSection = false;

  static const _orange = Color(0xFFF7941D);

  @override
  void initState() {
    super.initState();
    _fetchFertilizers();
  }

  Future<void> _fetchFertilizers() async {
    setState(() => _isLoading = true);
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
        
      final res = await http.get(Uri.parse('$baseUrl/get-fertilizer-data'));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final List data = body['data'] ?? [];
        _fertilizers
          ..clear()
          ..addAll(
            data.map<Map<String, dynamic>>(
              (item) => {
                'id': item['_id'],
                'name': item['name'],
                'image': item['img']['url'],
              },
            ),
          );
      }
    } catch (e) {
      debugPrint('Error fetching fertilizers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _fertilizers;
    return _fertilizers
        .where((f) => f['name'].toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _orange,
        title: const Text(
          'Fertilizer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search, color: _orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),

                    if (!_showAddSection)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                            ),
                            onPressed:
                                () => setState(() => _showAddSection = true),
                          ),
                        ),
                      ),

                    if (_showAddSection)
                      AddFertilizerSection(
                        onCancel: () => setState(() => _showAddSection = false),
                        onSave: (newItem) async {
                          setState(() => _showAddSection = false);
                          await _fetchFertilizers();
                        },
                      ),

                    const SizedBox(height: 10),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Center(
                          child: CircularProgressIndicator(color: _orange),
                        ),
                      )
                    else if (_filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.grass, size: 40, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'No fertilizers found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) {
                          final f = _filtered[i];
                          return FertilizerCard(
                            data: f,
                            onEditSuccess: _fetchFertilizers,
                            onDeleteSuccess: _fetchFertilizers,
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
