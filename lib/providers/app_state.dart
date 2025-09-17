// lib/providers/app_state.dart
import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  // Base API URL
  // String _baseUrl = 'https://sand-valey-flutter-app-backend-node.vercel.app/api/auth';
  String _baseUrl = 'https://sand-valley-flutter-app-backend.onrender.com/api/auth';

  // Getter
  String get baseUrl => _baseUrl;

  // Optional: If you want to update the URL dynamically in the future
  void setBaseUrl(String url) {
    _baseUrl = url;
    notifyListeners();
  }
}
