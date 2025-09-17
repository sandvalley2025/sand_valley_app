import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/background_container.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String? _errorMessage;
  bool _isLoading = false;
  late String input;

  Timer? _resendTimer;
  int _remainingSeconds = 0;
  bool _isResending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args == null || args is! String) {
      setState(() {
        _errorMessage = 'Missing user identifier (email or username).';
      });
      return;
    }
    input = args;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _isOtpComplete =>
      _controllers.every((c) => c.text.trim().length == 1);

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    if (!_isOtpComplete) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'input': input, 'otp': _otp}),
      );

      final data = jsonDecode(response.body);
      final message = data['message'] ?? '';

      if (response.statusCode == 200 &&
          message == 'OTP verified successfully') {
        Navigator.pushNamed(
          context,
          '/reset-password',
          arguments: {'input': input, 'otp': _otp},
        );
      } else {
        setState(() {
          _errorMessage = message.isNotEmpty ? message : 'Incorrect OTP';
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Incorrect OTP';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.length == 1 && index == 5) {
      FocusScope.of(context).unfocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _startTimer() {
    setState(() => _remainingSeconds = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    try {
      final response = await http.post(
        Uri.parse(
          'https://sand-valey-flutter-app-backend-node.vercel.app/api/auth/forgot-password',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'input': input}),
      );

      if (response.statusCode == 200) {
        _startTimer();
        _showSnackBar('OTP resent successfully.');
      } else {
        _showSnackBar('Failed to resend OTP.');
      }
    } catch (_) {
      _showSnackBar('Network error.');
    } finally {
      setState(() => _isResending = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFF7941D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFF7941D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BackgroundContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter the 6‑digit OTP sent to your email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF7941D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFF7941D),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFF7941D),
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) => _onChanged(value, index),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  if (_remainingSeconds == 0)
                    TextButton(
                      onPressed: _isResending ? null : _resendOtp,
                      child:
                          _isResending
                              ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFF7941D),
                                  ),
                                ),
                              )
                              : const Text(
                                'Resend Code?',
                                style: TextStyle(
                                  color: Color(0xFFF7941D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    )
                  else
                    Text(
                      'Resend available in $_remainingSeconds sec',
                      style: const TextStyle(
                        color: Color(0xFFF7941D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFFF7941D)),
                      )
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isOtpComplete ? _verifyOtp : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isOtpComplete
                                    ? const Color(0xFFF7941D)
                                    : const Color.fromARGB(255, 197, 112, 0),
                            disabledBackgroundColor: const Color.fromARGB(
                              255,
                              197,
                              112,
                              0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Verify',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
