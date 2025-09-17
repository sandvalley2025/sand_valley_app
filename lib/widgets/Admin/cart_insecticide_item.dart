import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class CartInsecticideItem extends StatefulWidget {
  final String id;
  final String name;
  final String imageUrl;
  final VoidCallback onRefresh;

  const CartInsecticideItem({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.onRefresh,
  });

  @override
  State<CartInsecticideItem> createState() => _CartInsecticideItemState();
}

class _CartInsecticideItemState extends State<CartInsecticideItem> {
  final _secureStorage = const FlutterSecureStorage();

  bool isExpanded = false;
  bool isEditing = false;
  bool isLoading = false;

  late TextEditingController _nameController;
  File? _pickedImage;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.name);
    super.initState();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  void _toggleExpanded() {
    if (isExpanded && isEditing) _cancelEdit();
    setState(() => isExpanded = !isExpanded);
  }

  void _startEdit() => setState(() => isEditing = true);

  void _cancelEdit() {
    setState(() {
      isEditing = false;
      _nameController.text = widget.name;
      _pickedImage = null;
    });
  }

  Future<void> _saveEdit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => isLoading = true);
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    final token = await _secureStorage.read(key: 'token');
    final uri = Uri.parse('$baseUrl/update-insecticide-data');

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['id'] = widget.id
          ..fields['name'] = name
          ..headers.addAll({
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          });

    if (_pickedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _pickedImage!.path,
          filename: p.basename(_pickedImage!.path),
        ),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        setState(() {
          isEditing = false;
          isExpanded = false;
          isLoading = false;
          _pickedImage = null;
        });
        widget.onRefresh();
      } else {
        _showSnackBar(
          'Failed to update: ${response.reasonPhrase ?? 'Unknown error'}',
        );
        print('❌ Error Response: $responseBody');
      }
    } catch (e) {
      _showSnackBar('An error occurred while communicating with the server.');
      print('❌ Exception: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteItem() async {
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    final token = await _secureStorage.read(key: 'token');
    final uri = Uri.parse('$baseUrl/delete-insecticide-data/${widget.id}');

    setState(() => isLoading = true);

    try {
      final response = await http.delete(
        uri,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        widget.onRefresh();
      } else {
        _showSnackBar('Failed to delete. Please try again.');
      }
    } catch (e) {
      _showSnackBar('An error occurred while communicating with the server.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _navigateToTypePage() {
    Navigator.pushNamed(
      context,
      '/insecticide-type-admin',
      arguments: {'id': widget.id, 'name': widget.name},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _navigateToTypePage,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
              title: Text(
                widget.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: _toggleExpanded,
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child:
                  isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF7941D),
                        ),
                      )
                      : Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            enabled: isEditing,
                            decoration: InputDecoration(
                              labelText: 'Insecticide Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: isEditing ? _pickImage : null,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child:
                                  _pickedImage != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _pickedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : Image.network(
                                        widget.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) =>
                                                const Icon(Icons.broken_image),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children:
                                isEditing
                                    ? [
                                      ElevatedButton(
                                        onPressed: _saveEdit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                        child: const Text('Save'),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton(
                                        onPressed: _cancelEdit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ]
                                    : [
                                      ElevatedButton(
                                        onPressed: _startEdit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                        child: const Text('Edit'),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton(
                                        onPressed: _deleteItem,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                          ),
                        ],
                      ),
            ),
        ],
      ),
    );
  }
}
