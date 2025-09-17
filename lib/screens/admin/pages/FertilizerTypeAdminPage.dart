import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/Admin/add_fertilizer_type_section.dart';
import 'package:sand_valley/widgets/Admin/fertilizertype_card.dart';

class FertilizerTypeAdminPage extends StatefulWidget {
  const FertilizerTypeAdminPage({super.key});

  @override
  State<FertilizerTypeAdminPage> createState() =>
      _FertilizerTypeAdminPageState();
}

class _FertilizerTypeAdminPageState extends State<FertilizerTypeAdminPage> {
  static const _orange = Color(0xFFF7941D);

  final _searchCtrl = TextEditingController();
  bool _showAdd = false, _loading = true, _fetched = false;
  bool viewDesc = true;
  late String _fertId, _fertName;
  List<Map<String, dynamic>> _types = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _fertId = args['id'];
      _fertName = args['name'];
      _fetchTypes();
      _fetched = true;
    }
  }

  Future<void> _fetchTypes() async {
    setState(() => _loading = true);
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final res = await http.get(
        Uri.parse('$baseUrl/get-fertilizer-type/$_fertId'),
      );
      if (res.statusCode == 200) {
        final body = json.decode(res.body)['data'] as Map<String, dynamic>;
        final list = (body['Type'] as List<dynamic>);
        _types =
            list.map((e) {
              final typeMap = {
                'id': e['_id'],
                'name': e['name'],
                'company': e['company'] ?? '',
                'description': e['description'] ?? '',
                'image': (e['img']?['url'] ?? ''),
              };
              if (e['Type'] != null &&
                  e['Type'] is List &&
                  (e['Type'] as List).isNotEmpty) {
                typeMap['nestedTypes'] =
                    (e['Type'] as List).map((nested) {
                      return {
                        'id': nested['_id'],
                        'name': nested['name'],
                        'company': nested['company'] ?? '',
                        'description': nested['description'] ?? '',
                        'image': (nested['img']?['url'] ?? ''),
                      };
                    }).toList();
              }
              return typeMap;
            }).toList();

        final first = _types.first;

        if ((first['description'] as String).trim().isNotEmpty &&
            (first['company'] as String).trim().isNotEmpty) {
          viewDesc = true;
        } else {
          viewDesc = false;
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching types: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return q.isEmpty
        ? _types
        : _types.where((t) => t['name'].toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _fertName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _orange,
        iconTheme: const IconThemeData(color: Colors.white),
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
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search types...',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search, color: _orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // Add button
                    if (!_showAdd)
                      Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _showAdd = true),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Add section
                    if (_showAdd)
                      AddFertilizerTypeSection(
                        categoryId: _fertId,
                        onCancel: () => setState(() => _showAdd = false),
                        viewDesc: viewDesc,
                        onSave: () async {
                          setState(() => _showAdd = false);
                          await _fetchTypes();
                        },
                      ),

                    const SizedBox(height: 10),

                    // List
                    if (_loading)
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
                              Icon(
                                Icons.grass_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No fertilizers type found',
                                style: TextStyle(
                                  color: Colors.grey,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final t = _filtered[i];
                          return FertilizerTypeCard(
                            data: t,
                            categoryId: _fertId,
                            onDelete: _fetchTypes,
                            onEdit: _fetchTypes,
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
