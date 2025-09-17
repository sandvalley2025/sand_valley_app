import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class AddFertilizerSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  const AddFertilizerSection({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AddFertilizerSection> createState() => _AddFertilizerSectionState();
}

class _AddFertilizerSectionState extends State<AddFertilizerSection> {
  final _secureStorage = const FlutterSecureStorage();

  final nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitData() async {
    final name = nameController.text.trim();

    if (name.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Name and image are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final token = await _secureStorage.read(key: 'token');

      final uri = Uri.parse('$baseUrl/add-fertilizer-data');
      final request = http.MultipartRequest('POST', uri);
      request.fields['name'] = name;
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      final mimeType = lookupMimeType(_imageFile!.path)?.split('/');
      final fileStream = await http.MultipartFile.fromPath(
        'image',
        _imageFile!.path,
        contentType:
            mimeType != null
                ? MediaType(mimeType[0], mimeType[1])
                : MediaType('image', 'jpeg'),
        filename: p.basename(_imageFile!.path),
      );

      request.files.add(fileStream);
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Fertilizer added successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFF7941D),
          ),
        );

        final newItem = {
          'name': name,
          'image': _imageFile!.path,
          'company': '',
          'description': '',
        };

        widget.onSave(newItem);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Failed to add: ${response.statusCode}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFF7941D),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Error occurred: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFF7941D),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Name input
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),

            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child:
                    _imageFile == null
                        ? const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons aligned to the right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffF7941D),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: widget.onCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _submitData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffF7941D),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
