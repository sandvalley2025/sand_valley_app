import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/Admin/seeds_descreption_cart.dart';

class SeedDescriptionAdminPage extends StatefulWidget {
  const SeedDescriptionAdminPage({super.key});

  @override
  State<SeedDescriptionAdminPage> createState() =>
      _SeedDescriptionAdminPageState();
}

class _SeedDescriptionAdminPageState extends State<SeedDescriptionAdminPage> {
  final _secureStorage = const FlutterSecureStorage();

  late String _typeId;
  late String _typeName;
  String? _typeImage;

  bool _isLoading = true;
  String? _error;
  Map<String, String>? _desc;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _typeId = args['id'] as String;
        _typeName = args['name'] as String;
        _typeImage = args['image'] as String?;

        _fetchDescription();
        _initialized = true;
      }
    }
  }

  Future<void> _fetchDescription() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _secureStorage.read(key: 'token');
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final uri = Uri.parse('$baseUrl/get-seeds-description/$_typeId');
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'] as Map<String, dynamic>;
        final desc = data['description'] as Map<String, dynamic>? ?? {};

        setState(() {
          _desc = {
            'id': data['_id'] as String,
            'name': data['name'] as String,
            'company': desc['company'] as String? ?? '',
            'description': desc['description'] as String? ?? '',
          };
        });
      } else {
        final body = jsonDecode(res.body);
        setState(() {
          _error = body['message'] ?? 'Failed to load (${res.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Delete this description?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (ok != true) return;

    try {
      final token = await _secureStorage.read(key: 'token');
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final uri = Uri.parse(
        '$baseUrl/delete-seeds-description/${_desc!['id']}',
      );
      final res = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        Navigator.pop(context);
      } else {
        final body = jsonDecode(res.body);
        _showError(body['message'] ?? 'Delete failed');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ $msg'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _typeName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF7941D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFF7941D),
        onRefresh: _fetchDescription,
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF7941D)),
                )
                : _error != null
                ? ListView(
                  children: [
                    const SizedBox(height: 200),
                    Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                )
                : _desc == null
                ? ListView(
                  children: [
                    const SizedBox(height: 200),
                    Center(
                      child: Text(
                        'No description found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                )
                : ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    SeedsDescriptionCard(
                      id: _desc!['id']!,
                      name: _desc!['name']!,
                      company: _desc!['company']!,
                      description: _desc!['description']!,
                      onDelete: _delete,
                      onUpdate: _fetchDescription,
                    ),
                  ],
                ),
      ),
    );
  }
}
