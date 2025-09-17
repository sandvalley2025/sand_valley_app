import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/Admin/add_nested_fertilizer_type_section.dart';
import 'package:sand_valley/widgets/Admin/fertilizer_nested_type_card.dart';

class FertilizerNestedTypePage extends StatefulWidget {
  const FertilizerNestedTypePage({super.key});

  @override
  State<FertilizerNestedTypePage> createState() =>
      _FertilizerNestedTypePageState();
}

class _FertilizerNestedTypePageState extends State<FertilizerNestedTypePage> {
  static const _orange = Color(0xFFF7941D);

  List<Map<String, dynamic>> _nestedTypes = [];
  List<Map<String, dynamic>> _filtered = [];

  bool _showAdd = false;
  bool _loading = true;
  bool _fetched = false; // ✅ to prevent double API calls

  final _searchCtrl = TextEditingController();

  late String categoryId;
  late String typeId;
  late String parentName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      categoryId = args['categoryId'];
      typeId = args['typeId'];
      parentName = args['name'];
      _fetchNestedTypes();
      _fetched = true;
    }
  }

  Future<void> _fetchNestedTypes() async {
    setState(() => _loading = true);

    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final url = Uri.parse(
        '$baseUrl/get-fertilizer-nested-type/$categoryId/$typeId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List nested = json['data'] ?? [];

        final dataList =
            nested
                .map(
                  (item) => {
                    'id': item['_id'],
                    'name': item['name'],
                    'image': item['img']?['url'] ?? '',
                    'company': item['company'] ?? '',
                    'description': item['description'] ?? '',
                  },
                )
                .toList();

        setState(() {
          _nestedTypes = dataList;
          _filtered = dataList;
          _loading = false;
        });
      } else {
        throw Exception('حدث خطأ في تحميل الأنواع الفرعية');
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ فشل في تحميل البيانات. حاول مرة أخرى.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _handleSearch(String value) {
    final query = value.toLowerCase();
    setState(() {
      _filtered =
          _nestedTypes
              .where((item) => item['name'].toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          parentName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator(color: _orange))
              : SafeArea(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 🔍 Search Bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: _handleSearch,
                            decoration: InputDecoration(
                              hintText: 'Search nested type...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: _orange,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        // ➕ Add Button or Add Section
                        if (!_showAdd)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed:
                                    () => setState(() => _showAdd = true),
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Add',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _orange,
                                ),
                              ),
                            ),
                          )
                        else
                          AddNestedFertilizerTypeSection(
                            categoryId: categoryId,
                            parentId: typeId,
                            onCancel: () => setState(() => _showAdd = false),
                            onSave: (_) {
                              _showAdd = false;
                              _fetchNestedTypes(); // ✅ Refresh after add
                            },
                          ),

                        const SizedBox(height: 12),

                        // 📝 List
                        _filtered.isEmpty
                            ? const Padding(
                              padding: EdgeInsets.only(top: 64),
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
                            : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(16),
                              itemCount: _filtered.length,
                              itemBuilder: (context, i) {
                                final item = _filtered[i];
                                return NestedFertilizerTypeCard(
                                  data: item,
                                  categoryId: categoryId,
                                  parentId: typeId,
                                  onDelete: () async {
                                    await _fetchNestedTypes(); // ✅ Refresh after delete
                                  },
                                  onUpdate: (_) async {
                                    await _fetchNestedTypes(); // ✅ Refresh after update
                                  },
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
