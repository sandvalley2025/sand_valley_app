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

class FertilizerTypeCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String categoryId;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const FertilizerTypeCard({
    super.key,
    required this.data,
    required this.categoryId,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<FertilizerTypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<FertilizerTypeCard> {
  final _secureStorage = const FlutterSecureStorage();

  bool _expanded = false, _editing = false, _loading = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _companyCtrl;
  File? _img;

  bool get hasDescOrCompany {
    final d = widget.data['description']?.toString().trim();
    final c = widget.data['company']?.toString().trim();
    return (d?.isNotEmpty == true || c?.isNotEmpty == true);
  }

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameCtrl = TextEditingController(text: widget.data['name'] ?? '');
    _descCtrl = TextEditingController(text: widget.data['description'] ?? '');
    _companyCtrl = TextEditingController(text: widget.data['company'] ?? '');
    _img = null;
  }

  void _restoreOriginalData() {
    setState(() {
      _nameCtrl.text = widget.data['name'] ?? '';
      _descCtrl.text = widget.data['description'] ?? '';
      _companyCtrl.text = widget.data['company'] ?? '';
      _img = null;
    });
  }

  Future<void> _pick() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _img = File(f.path));
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final token = await _secureStorage.read(key: 'token');

      final uri = Uri.parse('$baseUrl/update-fertilizer-type');
      final req =
          http.MultipartRequest('POST', uri)
            ..fields['name'] = _nameCtrl.text.trim()
            ..fields['description'] = _descCtrl.text.trim()
            ..fields['company'] = _companyCtrl.text.trim()
            ..fields['categoryId'] = widget.categoryId
            ..fields['typeId'] = widget.data['id'];

      req.headers.addAll({
        'Content-Type': 'multipart/form-data',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      if (_img != null) {
        final m = lookupMimeType(_img!.path)!.split('/');
        req.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _img!.path,
            contentType: MediaType(m[0], m[1]),
            filename: p.basename(_img!.path),
          ),
        );
      }

      final rsp = await req.send();
      if (rsp.statusCode == 200) {
        widget.onEdit();
        setState(() {
          _editing = false;
          _expanded = false;
          _img = null;
        });
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _del() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final token = await _secureStorage.read(key: 'token');

      final uri = Uri.parse(
        '$baseUrl/delete-fertilizer-type/${widget.categoryId}/${widget.data['id']}',
      );

      final rsp = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (rsp.statusCode == 200) {
        widget.onDelete();
      } else {
        debugPrint('❌ Failed to delete: ${rsp.statusCode} ${rsp.body}');
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _handleCardTap() {
    if (!hasDescOrCompany) {
      Navigator.pushNamed(
        context,
        '/fertilizer-nestedType',
        arguments: {
          'id': widget.data['id'],
          'name': widget.data['name'],
          'categoryId': widget.categoryId,
          'typeId': widget.data['id'],
        },
      );
    }
  }

  void _toggleExpandCollapse() {
    setState(() {
      if (_expanded) {
        _editing = false;
        _restoreOriginalData(); // <-- Revert unsaved changes
      }
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.data['name'] ?? '';
    final String desc = widget.data['description']?.toString().trim() ?? '';
    final String comp = widget.data['company']?.toString().trim() ?? '';

    return GestureDetector(
      onTap: _handleCardTap,
      child: Card(
        color: Colors.white,
        elevation: 6,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment:
                    (desc.isNotEmpty || comp.isNotEmpty)
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.data['image'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (desc.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(desc),
                          ),
                        if (comp.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(comp),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onPressed: _toggleExpandCollapse,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtrl,
                  enabled: _editing,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                if (hasDescOrCompany) ...[
                  if (_companyCtrl.text.trim().isNotEmpty) ...[
                    TextField(
                      controller: _companyCtrl,
                      enabled: _editing,
                      decoration: const InputDecoration(labelText: 'Company'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_descCtrl.text.trim().isNotEmpty) ...[
                    TextField(
                      controller: _descCtrl,
                      enabled: _editing,
                      maxLines: null, // let it expand with content
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border:
                            OutlineInputBorder(), // optional: better UI for long text
                        alignLabelWithHint: true, // keeps label aligned at top
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
                GestureDetector(
                  onTap: _editing ? _pick : null,
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child:
                        _img != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_img!, fit: BoxFit.cover),
                            )
                            : Image.network(
                              widget.data['image'],
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
                const SizedBox(height: 16),
                _loading
                    ? const CircularProgressIndicator(color: _orange)
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children:
                          _editing
                              ? [
                                ElevatedButton(
                                  onPressed: _loading ? null : _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _orange,
                                  ),
                                  child: const Text('Save'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed:
                                      _loading
                                          ? null
                                          : () {
                                            _restoreOriginalData();
                                            setState(() => _editing = false);
                                          },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ]
                              : [
                                ElevatedButton(
                                  onPressed:
                                      _loading
                                          ? null
                                          : () =>
                                              setState(() => _editing = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _orange,
                                  ),
                                  child: const Text('Edit'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _loading ? null : _del,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
