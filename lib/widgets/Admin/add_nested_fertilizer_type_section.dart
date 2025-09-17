import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class AddNestedFertilizerTypeSection extends StatefulWidget {
  final String parentId; // this is typeId
  final String categoryId;
  final VoidCallback onCancel;
  final Function(Map<String, dynamic>) onSave;

  const AddNestedFertilizerTypeSection({
    super.key,
    required this.parentId,
    required this.categoryId,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<AddNestedFertilizerTypeSection> createState() =>
      _AddNestedFertilizerTypeSectionState();
}

class _AddNestedFertilizerTypeSectionState
    extends State<AddNestedFertilizerTypeSection> {
  final _secureStorage = const FlutterSecureStorage();

  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  File? _pickedImage;
  bool _loading = false;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_pickedImage == null ||
        _nameCtrl.text.trim().isEmpty ||
        _companyCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty) {
      _showSnackbar("⚠️ All fields and image are required");
      return;
    }

    try {
      setState(() => _loading = true);
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final token = await _secureStorage.read(key: 'token');

      final uri = Uri.parse('$baseUrl/add-fertilizer-nested-type');

      final request =
          http.MultipartRequest('POST', uri)
            ..fields['categoryId'] = widget.categoryId
            ..fields['typeId'] = widget.parentId
            ..fields['name'] = _nameCtrl.text.trim()
            ..fields['company'] = _companyCtrl.text.trim()
            ..fields['description'] = _descCtrl.text.trim()
            ..files.add(
              await http.MultipartFile.fromPath('image', _pickedImage!.path),
            );

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(body);
        final List nestedList = decoded['data'];
        final lastItem = nestedList.last;

        final newItem = {
          'id': lastItem['_id'] ?? '',
          'name': lastItem['name'] ?? '',
          'company': lastItem['company'] ?? '',
          'description': lastItem['description'] ?? '',
          'image': lastItem['img']?['url'] ?? '',
        };

        widget.onSave(newItem);
      } else {
        final error = jsonDecode(body);
        _showSnackbar("❌ ${error['message'] ?? 'Failed to save'}");
      }
    } catch (e) {
      _showSnackbar("❌ Upload error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInput(_nameCtrl, 'Name'),
          _buildInput(_companyCtrl, 'Company'),
          _buildInput(_descCtrl, 'Description'),

          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child:
                  _pickedImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_pickedImage!, fit: BoxFit.cover),
                      )
                      : const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _loading ? null : widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child:
                    _loading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines:
            label == 'Description' ? null : 1, // unlimited for description
        keyboardType:
            label == 'Description'
                ? TextInputType.multiline
                : TextInputType.text,
        textInputAction:
            label == 'Description'
                ? TextInputAction.newline
                : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          alignLabelWithHint: label == 'Description',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}
