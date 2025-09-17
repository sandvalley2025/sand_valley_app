import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';

class CommunicationCard extends StatefulWidget {
  final String id;
  final String name;
  final bool isExpanded;
  final bool isEditing;
  final bool isLoading;
  final TextEditingController nameController;
  final VoidCallback onToggleExpand;
  final VoidCallback onTapNavigate;
  final Function(String) onNameUpdated;
  final VoidCallback onRemoved;
  final VoidCallback onStartEdit;
  final VoidCallback onCancelEdit;

  const CommunicationCard({
    super.key,
    required this.id,
    required this.name,
    required this.isExpanded,
    required this.isEditing,
    required this.isLoading,
    required this.nameController,
    required this.onToggleExpand,
    required this.onTapNavigate,
    required this.onNameUpdated,
    required this.onRemoved,
    required this.onStartEdit,
    required this.onCancelEdit,
  });

  @override
  State<CommunicationCard> createState() => _CommunicationCardState();
}

class _CommunicationCardState extends State<CommunicationCard> {
  final _secureStorage = const FlutterSecureStorage();

  bool localLoading = false;

  Future<void> _handleSave() async {
    setState(() => localLoading = true);
    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    final token = await _secureStorage.read(key: 'token');

    final url = Uri.parse('$baseUrl/update-communication-data');

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'id': widget.id,
          'name': widget.nameController.text,
        }),
      );

      if (res.statusCode == 200) {
        widget.onNameUpdated(widget.nameController.text);
      } else {
        debugPrint('Failed to update: ${res.body}');
      }
    } catch (e) {
      debugPrint('Error updating name: $e');
    } finally {
      setState(() => localLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text(
              'Are you sure you want to delete this communication?',
            ),
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

    setState(() => localLoading = true);

    final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
    final token = await _secureStorage.read(key: 'token');
    final url = Uri.parse('$baseUrl/delete-communication-data/${widget.id}');

    try {
      final res = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        widget.onRemoved();
      } else {
        debugPrint('❌ Failed to delete: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      debugPrint('❌ Error deleting: $e');
    } finally {
      setState(() => localLoading = false);
    }
  }

  void _handleToggleExpand() {
    if (widget.isEditing) {
      widget.nameController.text = widget.name;
      widget.onCancelEdit();
    }
    widget.onToggleExpand();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 5,
      child: Column(
        children: [
          InkWell(
            onTap: widget.onTapNavigate,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: ListTile(
              leading: const Icon(Icons.location_pin, color: Color(0xFFF7941D)),
              title: Text(
                widget.nameController.text,
                style: const TextStyle(color: Color(0xFFF7941D)),
              ),
              trailing: IconButton(
                icon: Icon(
                  widget.isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFFF7941D),
                ),
                onPressed: _handleToggleExpand,
              ),
            ),
          ),
          if (widget.isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: widget.nameController,
                    enabled: widget.isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Color(0xFFF7941D)),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:
                        widget.isEditing
                            ? [
                              ElevatedButton(
                                onPressed: localLoading ? null : _handleSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF7941D),
                                ),
                                child:
                                    localLoading
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
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
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  widget.nameController.text = widget.name;
                                  widget.onCancelEdit();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ]
                            : [
                              ElevatedButton(
                                onPressed: localLoading ? null : _handleDelete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child:
                                    localLoading
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white),
                                        ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: widget.onStartEdit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF7941D),
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
