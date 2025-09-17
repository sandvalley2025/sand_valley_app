import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/Admin/CommunicationCard.dart';
import 'package:sand_valley/widgets/Admin/add_communication_section.dart';

class CommunicationAdminPage extends StatefulWidget {
  const CommunicationAdminPage({super.key});

  @override
  State<CommunicationAdminPage> createState() => _CommunicationAdminPageState();
}

class _CommunicationAdminPageState extends State<CommunicationAdminPage> {
  final _secureStorage = const FlutterSecureStorage();

  final Map<String, bool> expandedMap = {};
  final Map<String, bool> editingMap = {};
  final Map<String, bool> loadingMap = {};
  final Map<String, TextEditingController> nameControllers = {};

  final List<Map<String, dynamic>> communicationList = [];
  List<Map<String, dynamic>> filteredList = [];

  bool _showAdd = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    final token = await _secureStorage.read(key: 'token');
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    final url = Uri.parse('$baseUrl/get-communication-data');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> fetchedData = decoded['data']['data'];

        communicationList.clear();
        for (var item in fetchedData) {
          communicationList.add({'id': item['_id'], 'name': item['name']});
        }

        _syncStateWithList();
      } else {
        print('❌ Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching communication data: $e');
    }

    setState(() => _isLoading = false);
  }

  void _syncStateWithList() {
    filteredList = List.from(communicationList);

    for (var item in communicationList) {
      final id = item['id'];
      nameControllers[id] ??= TextEditingController(text: item['name']);
      expandedMap[id] ??= false;
      editingMap[id] ??= false;
      loadingMap[id] ??= false;
    }
    setState(() {});
  }

  void _toggleAdd() => setState(() => _showAdd = !_showAdd);

  void _handleAfterSave() async {
    setState(() => _showAdd = false);
    await _loadInitialData();
  }

  void _saveEdit(String id) async {
    setState(() => loadingMap[id] = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate API call

    final updatedName = nameControllers[id]?.text ?? '';
    final index = communicationList.indexWhere(
      (element) => element['id'] == id,
    );
    if (index != -1) {
      communicationList[index]['name'] = updatedName;
    }

    setState(() {
      editingMap[id] = false;
      loadingMap[id] = false;
    });
  }

  void _deleteItem(String id) async {
    setState(() => loadingMap[id] = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate API call

    communicationList.removeWhere((item) => item['id'] == id);
    nameControllers.remove(id);
    expandedMap.remove(id);
    editingMap.remove(id);
    loadingMap.remove(id);
    filteredList = List.from(communicationList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Communication',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFFF7941D),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

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
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              if (_showAdd)
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AddCommunicationSection(
                    onSaved: _handleAfterSave,
                    onCancel: _toggleAdd,
                  ),
                ),

              const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Communication Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF7941D),
                    ),
                  ),
                ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFF7941D)),
                  ),
                )
              else if (filteredList.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.location_pin, size: 40, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No location found',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  itemBuilder: (context, i) {
                    final item = filteredList[i];
                    final id = item['id'];
                    return CommunicationCard(
                      id: item['id'],
                      name: item['name'],
                      isExpanded: expandedMap[id] ?? false,
                      isEditing: editingMap[id] ?? false,
                      isLoading: loadingMap[id] ?? false,
                      nameController: nameControllers[id]!,
                      onToggleExpand:
                          () => setState(
                            () => expandedMap[id] = !(expandedMap[id] ?? false),
                          ),
                      onTapNavigate: () {
                        Navigator.pushNamed(
                          context,
                          '/communicate-eng-admin',
                          arguments: {'id': id, 'name': item['name']},
                        );
                      },
                      onStartEdit: () => setState(() => editingMap[id] = true),
                      onCancelEdit: () {
                        setState(() => editingMap[id] = false);
                        nameControllers[id]?.text = item['name'];
                      },
                      onRemoved: () {
                        _deleteItem(id);
                      },
                      onNameUpdated: (newName) {
                        final index = communicationList.indexWhere(
                          (e) => e['id'] == id,
                        );
                        if (index != -1) {
                          communicationList[index]['name'] = newName;
                        }
                        setState(() => editingMap[id] = false);
                      },
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
