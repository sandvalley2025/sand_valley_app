import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class AddEngineerSection extends StatefulWidget {
  final String communicationId;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const AddEngineerSection({
    super.key,
    required this.communicationId,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<AddEngineerSection> createState() => _AddEngineerSectionState();
}

class _AddEngineerSectionState extends State<AddEngineerSection> {
  final _secureStorage = const FlutterSecureStorage();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  XFile? _imageFile;
  bool _isSaving = false;
  String? _error;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = picked);
    }
  }

  Future<void> _saveEngineer() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty || _imageFile == null) {
      setState(() => _error = 'All fields are required');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final token = await _secureStorage.read(key: 'token');
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final url = Uri.parse('$baseUrl/add-eng-data');
      final request =
          http.MultipartRequest('POST', url)
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['id'] = widget.communicationId
            ..fields['name'] = name
            ..fields['phone'] = phone
            ..files.add(
              await http.MultipartFile.fromPath('image', _imageFile!.path),
            );

      final streamedRes = await request.send();
      final res = await http.Response.fromStream(streamedRes);

      if (res.statusCode == 200) {
        widget.onSaved();
      } else {
        final resBody = jsonDecode(res.body);
        setState(() => _error = resBody['message'] ?? 'Failed to add');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 12),

            // Image Picker Section
            InkWell(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image, color: Colors.orange),
                    const SizedBox(width: 10),
                    const Text(
                      'Pick an image',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_imageFile!.path),
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveEngineer,
                  icon:
                      _isSaving
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7941D),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
