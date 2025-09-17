import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class NestedFertilizerTypeCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String parentId;
  final String categoryId;
  final VoidCallback onDelete;
  final Function(Map<String, dynamic>) onUpdate;

  const NestedFertilizerTypeCard({
    super.key,
    required this.data,
    required this.parentId,
    required this.categoryId,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<NestedFertilizerTypeCard> createState() =>
      _NestedFertilizerTypeCardState();
}

class _NestedFertilizerTypeCardState extends State<NestedFertilizerTypeCard> {
  final _secureStorage = const FlutterSecureStorage();

  bool _expanded = false;
  bool _editMode = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _descCtrl;

  File? _imageFile;
  String? _originalImage;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameCtrl = TextEditingController(text: widget.data['name']);
    _companyCtrl = TextEditingController(text: widget.data['company']);
    _descCtrl = TextEditingController(text: widget.data['description']);
    _originalImage = widget.data['image'];
    _imageFile = null;
  }

  void _resetFields() {
    _nameCtrl.text = widget.data['name'];
    _companyCtrl.text = widget.data['company'];
    _descCtrl.text = widget.data['description'];
    _imageFile = null;
    _originalImage = widget.data['image'];
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final token = await _secureStorage.read(key: 'token');

      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final url = Uri.parse('$baseUrl/update-fertilizer-nested-type');
      final request = http.MultipartRequest('POST', url);

      request.fields['categoryId'] = widget.categoryId;
      request.fields['typeId'] = widget.parentId;
      request.fields['nestedTypeId'] = widget.data['id'];
      request.fields['name'] = _nameCtrl.text;
      request.fields['company'] = _companyCtrl.text;
      request.fields['description'] = _descCtrl.text;
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _imageFile!.path),
        );
      }

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      setState(() => _isSaving = false);

      if (response.statusCode == 200) {
        final updatedData = {
          ...widget.data,
          'name': _nameCtrl.text,
          'company': _companyCtrl.text,
          'description': _descCtrl.text,
          'image': _imageFile != null ? '' : widget.data['image'],
        };
        widget.onUpdate(updatedData);
        setState(() {
          _editMode = false;
          _expanded = false;
        });
      } else {
        _showSnackBar('❌ Failed to update: ${_extractMessage(resBody)}');
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showSnackBar('❌ Error: ${e.toString()}');
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
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

    setState(() => _isDeleting = true);
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final token = await _secureStorage.read(key: 'token');

      final url = Uri.parse(
        '$baseUrl/delete-fertilizer-nested-type/${widget.categoryId}/${widget.parentId}/${widget.data['id']}',
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      setState(() => _isDeleting = false);

      if (response.statusCode == 200) {
        widget.onDelete();
      } else {
        _showSnackBar('❌ Delete failed: ${_extractMessage(response.body)}');
      }
    } catch (e) {
      setState(() => _isDeleting = false);
      _showSnackBar('❌ Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _extractMessage(String responseBody) {
    try {
      final jsonData = jsonDecode(responseBody);
      return jsonData['message'] ?? responseBody;
    } catch (_) {
      return responseBody;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgWidget =
        _imageFile != null
            ? Image.file(_imageFile!, width: 70, height: 70, fit: BoxFit.cover)
            : (_originalImage != null && _originalImage!.isNotEmpty
                ? Image.network(
                  _originalImage!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                )
                : const Icon(Icons.image, size: 48));

    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imgWidget,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (widget.data['description'].toString().isNotEmpty)
                        Text(widget.data['description']),
                      if (widget.data['company'].toString().isNotEmpty)
                        Text("Company: ${widget.data['company']}"),
                    ],
                  ),
                ),
                IconButton(
                  icon: AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: _expanded ? 0.5 : 0,
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                      if (!_expanded && _editMode) {
                        _resetFields();
                        _editMode = false;
                      }
                    });
                  },
                ),
              ],
            ),
            if (_expanded) const SizedBox(height: 10),
            if (_expanded)
              Column(
                children: [
                  if (_editMode) _buildField(_nameCtrl, 'Name'),
                  if (_editMode) _buildField(_descCtrl, 'Description'),
                  if (_editMode) _buildField(_companyCtrl, 'Company'),
                  if (_editMode)
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:
                        _editMode
                            ? [
                              _isSaving
                                  ? const CircularProgressIndicator(
                                    color: Colors.orange,
                                  )
                                  : ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _editMode = false;
                                        _resetFields();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _handleSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text('Save'),
                              ),
                            ]
                            : [
                              ElevatedButton(
                                onPressed:
                                    () => setState(() => _editMode = true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text('Edit'),
                              ),
                              const SizedBox(width: 8),
                              _isDeleting
                                  ? const CircularProgressIndicator(
                                    color: Colors.red,
                                  )
                                  : ElevatedButton(
                                    onPressed: _handleDelete,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
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

  Widget _buildField(TextEditingController controller, String label) {
    final isDescription = label.toLowerCase() == 'description';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        enabled: _editMode,
        maxLines: isDescription ? null : 1, // unlimited lines for description
        keyboardType:
            isDescription ? TextInputType.multiline : TextInputType.text,
        textInputAction:
            isDescription ? TextInputAction.newline : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          alignLabelWithHint:
              isDescription, // keep label aligned top for multiline
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
