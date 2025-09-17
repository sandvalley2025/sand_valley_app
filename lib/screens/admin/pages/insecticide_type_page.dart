import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/Admin/add_type_section.dart';
import 'package:sand_valley/widgets/Admin/type_item_card.dart';

class InsecticideTypeAdminPage extends StatefulWidget {
  const InsecticideTypeAdminPage({super.key});

  @override
  State<InsecticideTypeAdminPage> createState() =>
      _InsecticideTypeAdminPageState();
}

class _InsecticideTypeAdminPageState extends State<InsecticideTypeAdminPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> types = [];
  bool showAddSection = false;
  bool isLoading = true;
  bool isFetched = false;

  static const orangeColor = Color(0xFFF7941D);

  String id = '';
  String name = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        id = args['id'];
        name = args['name'];
        _fetchInsecticideTypes(id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInsecticideTypes(String id) async {
    setState(() {
      isLoading = true;
    });

    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final response = await http.get(
        Uri.parse("$baseUrl/get-insecticide-type/$id"),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List data = body['data'];

        setState(() {
          types =
              data.map<Map<String, dynamic>>((item) {
                return {
                  'id': item['_id'],
                  'name': item['name'],
                  'description': item['description'],
                  'company': item['company'] ?? '',
                  'imageUrl': item['img']['url'],
                };
              }).toList();
        });
      } else {
        print("❌ Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
        isFetched = true;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredTypes {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return types;
    return types
        .where((type) => type['name'].toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          name.isNotEmpty ? name : 'Insecticide Types',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: orangeColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🔍 Search bar & Add button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search insecticide type...',
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(
                                Icons.search,
                                color: orangeColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (!showAddSection)
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed:
                                    () => setState(() => showAddSection = true),
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Add',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: orangeColor,
                                ),
                              ),
                            )
                          else
                            AddTypeSection(
                              categoryId: id,
                              onCancel:
                                  () => setState(() => showAddSection = false),
                              onSave: () async {
                                setState(() => showAddSection = false);
                                await _fetchInsecticideTypes(id);
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 🐞 List / Loading / Empty
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: CircularProgressIndicator(color: orangeColor),
                        ),
                      )
                    else if (_filteredTypes.isEmpty)
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
                                'No insecticide type found',
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
                        itemCount: _filteredTypes.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final item = _filteredTypes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TypeItemCard(
                              typeName: item['name'],
                              description: item['description'],
                              company: item['company'],
                              imageUrl: item['imageUrl'],
                              catId: id,
                              typeId: item['id'],
                              onRefresh: () => _fetchInsecticideTypes(id),
                            ),
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
