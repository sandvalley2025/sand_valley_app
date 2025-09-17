import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class AddTypeSection extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String categoryId; // passed from main page

  const AddTypeSection({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.categoryId,
  });

  @override
  State<AddTypeSection> createState() => _AddTypeSectionState();
}

class _AddTypeSectionState extends State<AddTypeSection> {
  final _secureStorage = const FlutterSecureStorage();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  File? _pickedImage;

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  static const orangeColor = Color(0xFFF7941D);

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  Future<void> _submitType() async {
    final name = _nameController.text.trim();
    final description = _descController.text.trim();
    final company = _companyController.text.trim();

    if (name.isEmpty ||
        description.isEmpty ||
        company.isEmpty ||
        _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all fields and choose an image",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFF7941D),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final token = await _secureStorage.read(key: 'token');

      final uri = Uri.parse("$baseUrl/add-insecticide-type");

      final request = http.MultipartRequest("POST", uri);
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['company'] = company;
      request.fields['id'] = widget.categoryId;

      final mimeType = lookupMimeType(_pickedImage!.path)!.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // ✅ Correct field name matching backend
          _pickedImage!.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        ),
      );
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      final response = await request.send();

      if (response.statusCode == 200) {
        widget.onSave();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "❌ Failed to add type",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFF7941D),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: null, // allow unlimited lines
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(), // optional for better UI
              alignLabelWithHint: true, // keeps label top-aligned for multiline
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _companyController,
            decoration: const InputDecoration(labelText: 'Company'),
          ),
          const SizedBox(height: 12),

          // 📸 Image Picker
          InkWell(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(
                    _pickedImage == null ? "Pick an image" : "Image selected",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),

          // 📷 Preview
          if (_pickedImage != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _pickedImage!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 🔘 Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _submitType,
                style: ElevatedButton.styleFrom(backgroundColor: orangeColor),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFF7941D),
                          ),
                        )
                        : const Text('Save'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: widget.onCancel,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
