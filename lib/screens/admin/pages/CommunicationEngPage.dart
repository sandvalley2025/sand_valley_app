// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/Admin/add_engineer_section.dart';

class CommunicationEngPage extends StatefulWidget {
  const CommunicationEngPage({super.key});

  @override
  State<CommunicationEngPage> createState() => _CommunicationEngPageState();
}

class _CommunicationEngPageState extends State<CommunicationEngPage> {
  final _secureStorage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> engineers = [];
  List<Map<String, dynamic>> filtered = [];
  String? communicationId;
  String? name;
  bool _isLoading = true;
  bool _showAddSection = false;
  String? _error;
  int? _expandedIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    communicationId = args?['id'];
    name = args?['name'];
    _fetchEngineers();
  }

  Future<void> _fetchEngineers() async {
    if (communicationId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _secureStorage.read(key: 'token');
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final res = await http.get(
        Uri.parse('$baseUrl/get-communication-eng/$communicationId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        final List<dynamic> data = j['data']['eng'];
        engineers =
            data
                .map<Map<String, dynamic>>(
                  (e) => {
                    'id': e['_id'],
                    'name': e['name'],
                    'phone': e['phone'],
                    'image': e['img']['url'],
                    'isEditing': false,
                    'nameController': TextEditingController(text: e['name']),
                    'phoneController': TextEditingController(text: e['phone']),
                    'pickedImage': null,
                    'isSaving': false,
                    'isDeleting': false,
                  },
                )
                .toList();
        filtered = [...engineers];
      } else {
        _error = 'Failed to load data';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterList(String q) {
    setState(() {
      filtered =
          engineers.where((eng) {
            return eng['name'].toLowerCase().contains(q.toLowerCase()) ||
                eng['phone'].contains(q);
          }).toList();
    });
  }

  Future<void> _pickImage(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        filtered[index]['pickedImage'] = File(picked.path);
      });
    }
  }

  Future<void> _saveEdit(int index) async {
    setState(() => filtered[index]['isSaving'] = true);

    final name = filtered[index]['nameController'].text.trim();
    final phone = filtered[index]['phoneController'].text.trim();
    final imageFile = filtered[index]['pickedImage'];
    final token = await _secureStorage.read(key: 'token');
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

    final url = Uri.parse(
      '$baseUrl/update-communication-eng/$communicationId/${filtered[index]['id']}',
    );

    final request =
        http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['name'] = name
          ..fields['phone'] = phone;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        setState(() {
          filtered[index]['name'] = name;
          filtered[index]['phone'] = phone;
          filtered[index]['isEditing'] = false;
          _expandedIndex = null;
        });
      }
    } finally {
      setState(() => filtered[index]['isSaving'] = false);
    }
  }

  Future<void> _deleteEngineer(int index) async {
    setState(() => filtered[index]['isDeleting'] = true);
    final token = await _secureStorage.read(key: 'token');
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

    final url = Uri.parse(
      '$baseUrl/delete-communication-eng/$communicationId/${filtered[index]['id']}',
    );

    try {
      final res = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          engineers.removeWhere((e) => e['id'] == filtered[index]['id']);
          filtered.removeAt(index);
          _expandedIndex = null;
        });
      }
    } finally {
      setState(() => filtered[index]['isDeleting'] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name!,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7941D),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => setState(() => _showAddSection = !_showAddSection),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (_showAddSection && communicationId != null)
            AddEngineerSection(
              communicationId: communicationId!,
              onSaved: () {
                _fetchEngineers();
                setState(() => _showAddSection = false);
              },
              onCancel: () => setState(() => _showAddSection = false),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterList,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFFF7941D)),
                hintText: 'Search by name or phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF7941D),
                      ),
                    )
                    : _error != null
                    ? Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                    : filtered.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.engineering, size: 40, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No engineers found',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final item = filtered[i];
                        final isExpanded = _expandedIndex == i;
                        final picked = item['pickedImage'];

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 4,
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      picked != null
                                          ? FileImage(picked)
                                          : NetworkImage(item['image'])
                                              as ImageProvider,
                                ),
                                title: Text(
                                  item['name'],
                                  style: const TextStyle(
                                    color: Color(0xFFF7941D),
                                  ),
                                ),
                                subtitle: Text(item['phone']),
                                trailing: IconButton(
                                  icon: Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _expandedIndex = isExpanded ? null : i;
                                      item['isEditing'] = false;
                                      item['pickedImage'] = null;
                                    });
                                  },
                                ),
                              ),
                              if (isExpanded)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: item['nameController'],
                                        enabled: item['isEditing'],
                                        decoration: const InputDecoration(
                                          labelText: 'Name',
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: item['phoneController'],
                                        enabled: item['isEditing'],
                                        decoration: const InputDecoration(
                                          labelText: 'Phone',
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap:
                                                item['isEditing']
                                                    ? () => _pickImage(i)
                                                    : null,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.orange
                                                    .withOpacity(0.2),
                                              ),
                                              child: const Icon(
                                                Icons.image,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          if (picked != null)
                                            Image.file(
                                              picked,
                                              width: 80,
                                              height: 80,
                                            )
                                          else
                                            Image.network(
                                              item['image'],
                                              width: 80,
                                              height: 80,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children:
                                            item['isEditing']
                                                ? [
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        item['isEditing'] =
                                                            false;
                                                        item['nameController']
                                                                .text =
                                                            item['name'];
                                                        item['phoneController']
                                                                .text =
                                                            item['phone'];
                                                        item['pickedImage'] =
                                                            null;
                                                      });
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton(
                                                    onPressed:
                                                        item['isSaving']
                                                            ? null
                                                            : () =>
                                                                _saveEdit(i),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.orange,
                                                        ),
                                                    child:
                                                        item['isSaving']
                                                            ? const SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            )
                                                            : const Text(
                                                              'Save',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                  ),
                                                ]
                                                : [
                                                  ElevatedButton.icon(
                                                    onPressed:
                                                        () => setState(
                                                          () =>
                                                              item['isEditing'] =
                                                                  true,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: Colors.white,
                                                    ),
                                                    label: const Text(
                                                      'Edit',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.orange,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton.icon(
                                                    onPressed:
                                                        item['isDeleting']
                                                            ? null
                                                            : () =>
                                                                _deleteEngineer(
                                                                  i,
                                                                ),
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.white,
                                                    ),
                                                    label:
                                                        item['isDeleting']
                                                            ? const SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            )
                                                            : const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                  ),
                                                ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
