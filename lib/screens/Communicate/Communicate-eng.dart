import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/background_container.dart';
import 'package:sand_valley/widgets/customButton.dart';
import 'package:sand_valley/widgets/customWidget2.dart';
import 'package:sand_valley/widgets/customWidget2Reversed.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EngineerPage extends StatefulWidget {
  const EngineerPage({super.key});

  @override
  State<EngineerPage> createState() => _EngineerPageState();
}

class _EngineerPageState extends State<EngineerPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTopContainer = true;
  List<dynamic> engineers = [];
  bool isLoading = true;
  String? id;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && _showTopContainer) {
        setState(() => _showTopContainer = false);
      } else if (_scrollController.offset <= 50 && !_showTopContainer) {
        setState(() => _showTopContainer = true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    id ??= args?['id'];
    if (id != null && engineers.isEmpty) {
      _fetchEngineers(id!);
    }
  }

  Future<void> _fetchEngineers(String id) async {
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/get-communication-eng/$id'),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          engineers = jsonData['data']['eng'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load engineers');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff006F54),
        toolbarHeight: 5,
      ),
      body: BackgroundContainer(
        child: SafeArea(
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: _showTopContainer ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showTopContainer ? 100 : 0,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/handShake copy.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CustomButton(
                      icon: Image.asset(
                        'assets/images/arrow.png',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                      routeName: '/communicate-main',
                      buttonColor: const Color(0xff006F54),
                    ),
                  ),
                ),
              ),
              Expanded(
                child:
                    isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff006F54),
                          ),
                        )
                        : engineers.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.engineering,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'لا يوجد مهندسون حالياً',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          itemCount: engineers.length,
                          itemBuilder: (context, index) {
                            final engineer = engineers[index];
                            final name = engineer['name'] ?? 'بدون اسم';
                            final image =
                                engineer['img']['url'] ??
                                'assets/images/seeds-img.png';
                            final phone = engineer['phone'] ?? 'غير متوفر';
                            final isEven = index % 2 == 0;

                            final widget =
                                isEven
                                    ? CustomWidget2(
                                      customBorderColor: const Color(
                                        0xff006F54,
                                      ),
                                      customColor: const Color(0xff006F54),
                                      text: name,
                                      image: image,
                                      routeName: '/communicate-call',
                                      arguments: {
                                        'name': name,
                                        'image': image,
                                        'phone': phone,
                                      },
                                    )
                                    : CustomWidget2Reversed(
                                      customBorderColor: const Color(
                                        0xff006F54,
                                      ),
                                      customColor: const Color(0xff006F54),
                                      text: name,
                                      image: image,
                                      routeName: '/communicate-call',
                                      arguments: {
                                        'name': name,
                                        'image': image,
                                        'phone': phone,
                                      },
                                    );

                            return Column(
                              children: [widget, const SizedBox(height: 10)],
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
