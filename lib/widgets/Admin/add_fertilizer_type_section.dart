import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

const _orange = Color(0xFFF7941D);

class AddFertilizerTypeSection extends StatefulWidget {
  final String categoryId;
  final bool viewDesc;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const AddFertilizerTypeSection({
    super.key,
    required this.categoryId,
    required this.viewDesc,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<AddFertilizerTypeSection> createState() =>
      _AddFertilizerTypeSectionState();
}

class _AddFertilizerTypeSectionState extends State<AddFertilizerTypeSection> {
  final _secureStorage = const FlutterSecureStorage();

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  File? _img;
  bool _loading = false;

  Future<void> _pick() async {
    if (_loading) return;
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _img = File(f.path));
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final description = _descCtrl.text.trim();
    final company = _companyCtrl.text.trim();

    if (name.isEmpty || _img == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Image are required')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final token = await _secureStorage.read(key: 'token');

      final uri = Uri.parse('$baseUrl/add-fertilizer-type');
      final req =
          http.MultipartRequest('POST', uri)
            ..fields['id'] = widget.categoryId
            ..fields['name'] = name
            ..fields['description'] = widget.viewDesc ? description : ''
            ..fields['company'] = widget.viewDesc ? company : '';
      req.headers.addAll({
        'Content-Type': 'multipart/form-data',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      final mime = lookupMimeType(_img!.path)!.split('/');
      req.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _img!.path,
          contentType: MediaType(mime[0], mime[1]),
          filename: p.basename(_img!.path),
        ),
      );

      final res = await req.send();
      if (res.statusCode == 200) widget.onSave();
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add type')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _orange,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              enabled: !_loading,
              decoration: const InputDecoration(labelText: 'Type Name'),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _loading ? null : _pick,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child:
                    _img == null
                        ? const Center(
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_img!, fit: BoxFit.cover),
                        ),
              ),
            ),
            if (widget.viewDesc) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _companyCtrl,
                enabled: !_loading,
                decoration: const InputDecoration(labelText: 'Company'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                enabled: !_loading,
                maxLines: null, // unlimited lines, expands as user types
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border:
                      OutlineInputBorder(), // makes it clearer for longer text
                  alignLabelWithHint:
                      true, // keeps label aligned top for multiline
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children:
                  _loading
                      ? const [CircularProgressIndicator(color: _orange)]
                      : [
                        ElevatedButton(
                          onPressed: _loading ? null : widget.onCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _orange,
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
      ),
    );
  }
}
