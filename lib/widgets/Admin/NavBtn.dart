import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class EditableNavItem extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String routeName;
  final VoidCallback onImageUpdated;

  const EditableNavItem({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.routeName,
    required this.onImageUpdated,
  });

  @override
  State<EditableNavItem> createState() => _EditableNavItemState();
}

class _EditableNavItemState extends State<EditableNavItem> {
  final _secureStorage = const FlutterSecureStorage();

  bool _isExpanded = false;
  bool _isEditing = false;
  bool _isUploading = false;
  String? _message;
  Color _messageColor = Colors.green;

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _message = null;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedImage == null) return;

    setState(() {
      _isUploading = true;
      _message = null;
    });

    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    final token = await _secureStorage.read(key: 'token');

    final uri = Uri.parse('$baseUrl/update-main-categories');
    final request = http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['section'] = widget.title;

    final mimeType = _pickedImage!.path.endsWith('.png') ? 'png' : 'jpeg';
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        _pickedImage!.path,
        contentType: MediaType('image', mimeType),
      ),
    );

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
          _pickedImage = null;
          _message = '✅ Image uploaded successfully';
          _messageColor = Colors.green;
        });
        widget.onImageUpdated();
      } else {
        setState(() {
          _message =
              '❌ Upload failed: ${response.statusCode}\n${responseBody.body}';
          _messageColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _message = '❌ Error: $e';
        _messageColor = Colors.red;
      });
    } finally {
      setState(() {
        _isUploading = false;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _message = null);
        }
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _pickedImage = null;
      _message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (!_isEditing) {
                Navigator.pushNamed(context, widget.routeName);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        widget.imageUrl.isNotEmpty
                            ? Image.network(
                              widget.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => _defaultPlaceholder(),
                            )
                            : _defaultPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                        if (!_isExpanded && _isEditing) {
                          _cancelEdit(); // Exit edit mode when collapsed
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            _pickedImage != null
                                ? Image.file(
                                  _pickedImage!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                                : Image.network(
                                  widget.imageUrl,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) =>
                                          _defaultPlaceholder(height: 160),
                                ),
                      ),
                      if (_isEditing)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_message != null)
                    Text(
                      _message!,
                      style: TextStyle(
                        color: _messageColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_isEditing && !_isUploading)
                        ElevatedButton(
                          onPressed: _cancelEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Cancel'),
                        ),
                      const SizedBox(width: 8),
                      if (!_isEditing)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                              _message = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Edit'),
                        )
                      else if (_isUploading)
                        ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: _uploadImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Save'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _defaultPlaceholder({double height = 50, double width = 50}) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
      ),
    );
  }
}
