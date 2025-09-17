import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class SeedsDescriptionCard extends StatefulWidget {
  final String id;
  final String name;
  final String company;
  final String description;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const SeedsDescriptionCard({
    Key? key,
    required this.id,
    required this.name,
    required this.company,
    required this.description,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<SeedsDescriptionCard> createState() => _SeedsDescriptionCardState();
}

class _SeedsDescriptionCardState extends State<SeedsDescriptionCard> {
  final _secureStorage = const FlutterSecureStorage();

  bool _editing = false;
  bool _loading = false;

  late final TextEditingController _companyController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.company);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void didUpdateWidget(covariant SeedsDescriptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.company != oldWidget.company) {
      _companyController.text = widget.company;
    }
    if (widget.description != oldWidget.description) {
      _descriptionController.text = widget.description;
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _startEdit() => setState(() => _editing = true);

  void _cancelEdit() {
    if (_loading) return;
    setState(() {
      _editing = false;
      _companyController.text = widget.company;
      _descriptionController.text = widget.description;
    });
  }

  Future<void> _saveEdit() async {
    final newCompany = _companyController.text.trim();
    final newDesc = _descriptionController.text.trim();

    if (newCompany == widget.company && newDesc == widget.description) {
      _cancelEdit();
      return;
    }

    setState(() => _loading = true);

    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final token = await _secureStorage.read(key: 'token');

      final uri = Uri.parse('$baseUrl/update-seeds-description/${widget.id}');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'company': newCompany, 'description': newDesc}),
      );

      final body = jsonDecode(response.body);
      if (body['message'] == '✅ Description updated successfully') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] ?? 'Updated successfully'),
            backgroundColor: const Color(0xFFF7941D),
          ),
        );
        setState(() => _editing = false);
        widget.onUpdate();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${body['message'] ?? 'Update failed'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Exception: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name (non-editable text)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.grass, color: Color(0xFFF7941D)),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Name: ',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: widget.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24), // More space between name & company
            // Company
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.business, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child:
                      _editing
                          ? TextField(
                            controller: _companyController,
                            enabled: !_loading,
                            decoration: const InputDecoration(
                              labelText: 'Company',
                              border: OutlineInputBorder(),
                            ),
                          )
                          : RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Company: ',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.company,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ],
            ),

            const SizedBox(height: 24), // More space between company & desc
            // Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child:
                      _editing
                          ? TextField(
                            controller: _descriptionController,
                            enabled: !_loading,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          )
                          : Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 120),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Description: ',
                                        style: TextStyle(
                                          color: Colors.orange.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        text: widget.description,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Buttons or Loader
            if (_loading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFF7941D)),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  if (_editing) ...[
                    ElevatedButton.icon(
                      onPressed: _cancelEdit,
                      icon: const Icon(Icons.cancel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      label: const Text('Cancel'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _saveEdit,
                      icon: const Icon(Icons.save),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7941D),
                      ),
                      label: const Text('Save'),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: _startEdit,
                      icon: const Icon(Icons.edit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7941D),
                      ),
                      label: const Text('Edit'),
                    ),
                    ElevatedButton.icon(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      label: const Text('Delete'),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
