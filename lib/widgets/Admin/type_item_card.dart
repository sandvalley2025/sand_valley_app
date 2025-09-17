import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class TypeItemCard extends StatefulWidget {
  final String catId;
  final String typeId;
  final String typeName;
  final String description;
  final String company;
  final String imageUrl;
  final VoidCallback? onRefresh;

  const TypeItemCard({
    super.key,
    required this.catId,
    required this.typeId,
    required this.typeName,
    required this.description,
    required this.company,
    required this.imageUrl,
    this.onRefresh,
  });

  @override
  State<TypeItemCard> createState() => _TypeItemCardState();
}

class _TypeItemCardState extends State<TypeItemCard> {
  final _secureStorage = const FlutterSecureStorage();

  bool isExpanded = false;
  bool isEditing = false;
  bool isLoading = false;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController companyController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.typeName);
    descriptionController = TextEditingController(text: widget.description);
    companyController = TextEditingController(text: widget.company);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    companyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _saveChanges() async {
    setState(() => isLoading = true);
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final token = await _secureStorage.read(key: 'token');

      final uri = Uri.parse(
        '$baseUrl/update-insecticide-type/${widget.catId}/${widget.typeId}',
      );

      final request =
          http.MultipartRequest('POST', uri)
            ..fields['name'] = nameController.text
            ..fields['description'] = descriptionController.text
            ..fields['company'] = companyController.text;

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Type updated successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFF7941D),
          ),
        );
        setState(() {
          isEditing = false;
          _selectedImage = null;
        });
        widget.onRefresh?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Failed to update. Code: ${response.statusCode}',
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
            '❌ Error: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFF7941D),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteType() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text("Are you sure you want to delete this type?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(ctx, false),
              ),
              TextButton(
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final token = await _secureStorage.read(key: 'token');

      final uri = Uri.parse(
        '$baseUrl/delete-insecticide-type/${widget.catId}/${widget.typeId}',
      );

      final response = await http.delete(
        uri,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Type deleted successfully')),
        );
        widget.onRefresh?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to delete. Code: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toggleExpandCollapse() {
    setState(() {
      isExpanded = !isExpanded;

      if (!isExpanded && isEditing) {
        isEditing = false;
        _selectedImage = null;
        nameController.text = widget.typeName;
        descriptionController.text = widget.description;
        companyController.text = widget.company;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child:
          _selectedImage != null
              ? Image.file(
                _selectedImage!,
                height: 64,
                width: 64,
                fit: BoxFit.cover,
              )
              : Image.network(
                widget.imageUrl,
                height: 64,
                width: 64,
                fit: BoxFit.cover,
              ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageWidget,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.typeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.description),
                    if (widget.company.isNotEmpty)
                      Text(
                        'Company: ${widget.company}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: _toggleExpandCollapse,
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              enabled: isEditing,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              enabled: isEditing,
              maxLines: null, // allow multiple lines instead of single line
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Description',
                border:
                    OutlineInputBorder(), // optional: better UI for long text
                alignLabelWithHint:
                    true, // keeps label aligned top for multiline
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: companyController,
              enabled: isEditing,
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            const SizedBox(height: 16),
            if (isEditing)
              Column(
                children: [
                  _selectedImage != null
                      ? Image.file(_selectedImage!, height: 150)
                      : Image.network(widget.imageUrl, height: 150),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick New Image'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (isLoading)
              const CircularProgressIndicator(color: Color(0xFFF7941D))
            else if (!isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => isEditing = true),
                    child: const Text('Edit'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _deleteType,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                        _selectedImage = null;
                        nameController.text = widget.typeName;
                        descriptionController.text = widget.description;
                        companyController.text = widget.company;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
