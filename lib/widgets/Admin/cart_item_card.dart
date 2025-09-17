import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class CartItemCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onDelete;
  final String id;
  final VoidCallback? onTap;
  final VoidCallback? onUpdateDone;
  const CartItemCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onDelete,
    required this.id,
    this.onTap,
    this.onUpdateDone,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  final _secureStorage = const FlutterSecureStorage();

  bool _expanded = false;
  bool _editing = false;
  bool _loading = false;
  
  TextEditingController _nameController = TextEditingController();
  File? _pickedImage;

  @override
  void initState() {
    _nameController.text = widget.name;
    super.initState();
  }

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      if (!_expanded && _editing) {
        _cancelEdit();
      }
    });
  }

  Future<void> _pickImage() async {
    if (_loading) return;
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _pickedImage = File(img.path));
    }
  }

  void _startEdit() {
    setState(() => _editing = true);
  }

  void _cancelEdit() {
    if (_loading) return;
    setState(() {
      _editing = false;
      _nameController.text = widget.name;
      _pickedImage = null;
    });
  }

  Future<void> _saveEdit() async {
    setState(() => _loading = true);

    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final token = await _secureStorage.read(key: 'token');

      final uri = Uri.parse('$baseUrl/update-seeds-categories');

      final request = http.MultipartRequest('POST', uri);

      request.fields['section'] = 'seeds';
      request.fields['id'] = widget.id;

      final newName = _nameController.text.trim();
      if (newName.isNotEmpty && newName != widget.name) {
        request.fields['name'] = newName;
      }
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      if (_pickedImage != null) {
        final mimeType = lookupMimeType(_pickedImage!.path) ?? 'image/jpeg';
        final mimeParts = mimeType.split('/');

        final imageFile = await http.MultipartFile.fromPath(
          'image',
          _pickedImage!.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
          filename: path.basename(_pickedImage!.path),
        );

        request.files.add(imageFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${body['message']}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFF7941D),
          ),
        );
        setState(() {
          _editing = false;
          _pickedImage = null;
        });
        widget.onUpdateDone?.call();
      } else {
        final errorMsg = body['message'] ?? 'Unknown error';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error: $errorMsg')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Exception: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showImage =
        _pickedImage != null
            ? Image.file(
              _pickedImage!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
            : Image.network(
              widget.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: (_editing || _loading) ? null : widget.onTap,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: showImage,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: _toggleExpand,
              ),
            ],
          ),
          if (_expanded)
            Column(
              children: [
                const SizedBox(height: 12),
                TextField(
                  enabled: _editing && !_loading,
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Edit Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _editing && !_loading ? _pickImage : null,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        _pickedImage != null
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            : Image.network(widget.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:
                      _loading
                          ? const [
                            CircularProgressIndicator(color: Color(0xFFF7941D)),
                          ]
                          : _editing
                          ? [
                            ElevatedButton(
                              onPressed: _cancelEdit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _saveEdit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF7941D),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Save"),
                            ),
                          ]
                          : [
                            ElevatedButton(
                              onPressed: _startEdit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF7941D),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Edit"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _loading ? null : widget.onDelete,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Delete"),
                            ),
                          ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
