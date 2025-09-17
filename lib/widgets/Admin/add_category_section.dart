import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class AddCategorySection extends StatefulWidget {
  final VoidCallback onSaved;
  const AddCategorySection({super.key, required this.onSaved});

  @override
  State<AddCategorySection> createState() => _AddCategorySectionState();
}

class _AddCategorySectionState extends State<AddCategorySection> {
  final _secureStorage = const FlutterSecureStorage();

  final TextEditingController _nameController = TextEditingController();
  File? _pickedImage;
  bool _isLoading = false;
  String? _error;

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _pickedImage = File(img.path));
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final token = await _secureStorage.read(key: 'token');

    if (name.isEmpty || _pickedImage == null) {
      setState(() => _error = 'Name and image are required.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final req = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/add-seeds-categories'),
      );

      req.headers.addAll({
        'Content-Type': 'multipart/form-data',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      req.fields['name'] = name;

      req.files.add(
        await http.MultipartFile.fromPath('image', _pickedImage!.path),
      );

      final res = await req.send();

      final resBody = await res.stream.bytesToString();

      if (res.statusCode == 200) {
        widget.onSaved();
      } else {
        setState(() {
          _error = '❌ Failed (${res.statusCode}): $resBody';
        });
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _cancel() {
    _nameController.clear();
    setState(() {
      _pickedImage = null;
      _error = null;
    });
    widget.onSaved(); // Hide section
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          const Text(
            'Add New Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF7941D),
            ),
          ),
          const SizedBox(height: 12),

          // Text Field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              labelStyle: const TextStyle(color: Color(0xFFF7941D)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFF7941D)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFF7941D),
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Image Picker
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              child:
                  _pickedImage == null
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.photo_library,
                            color: Colors.grey,
                            size: 36,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Tap to pick an image",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _pickedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
            ),
          ),

          const SizedBox(height: 12),

          // Error
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),

          const SizedBox(height: 12),

          // Buttons
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFF7941D)),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _cancel,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFFF7941D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7941D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
