import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class AddInsecticideSection extends StatefulWidget {
  final VoidCallback onDataAdded;
  final VoidCallback onCancel;

  const AddInsecticideSection({
    super.key,
    required this.onDataAdded,
    required this.onCancel,
  });

  @override
  State<AddInsecticideSection> createState() => _AddInsecticideSectionState();
}

class _AddInsecticideSectionState extends State<AddInsecticideSection> {
  final _secureStorage = const FlutterSecureStorage();

  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _uploadInsecticide() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedImage == null) return;
    final token = await _secureStorage.read(key: 'token');

    setState(() => _isLoading = true);
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

    final uri = Uri.parse('$baseUrl/add-insecticide-data');
    final request =
        http.MultipartRequest('POST', uri)
          ..fields['name'] = name
          ..files.add(
            await http.MultipartFile.fromPath(
              'image',
              _selectedImage!.path,
              filename: p.basename(_selectedImage!.path),
            ),
          )
          ..headers.addAll({
            'Content-Type': 'multipart/form-data',
            if (token != null) 'Authorization': 'Bearer $token',
          });

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        widget.onDataAdded(); // Tell parent to refetch
        _nameController.clear();
        setState(() => _selectedImage = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('failed adding the insecticide')),
        );
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('server error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF7F7F7),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child:
                  _selectedImage == null
                      ? const Center(
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFF7941D)),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _uploadInsecticide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7941D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: widget.onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
