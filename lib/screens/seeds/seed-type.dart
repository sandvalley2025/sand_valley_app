import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/background_container.dart';
import 'package:sand_valley/widgets/customButton.dart';
import 'package:sand_valley/widgets/customWidget2.dart';
import 'package:sand_valley/widgets/customWidget2Reversed.dart';
import 'package:sand_valley/widgets/roundedImageContainer.dart';
import 'package:sand_valley/widgets/roundedtextContainer.dart';

class SeedType extends StatefulWidget {
  const SeedType({super.key});

  @override
  State<SeedType> createState() => _SeedTypeState();
}

class _SeedTypeState extends State<SeedType> {
  final ScrollController _scrollController = ScrollController();
  bool _showTopContainer = true;

  String? seedId;
  String? seedName;
  String? seedImage;

  List<dynamic> seedTypes = [];
  bool isLoading = true;
  String? error;

  Future<void>? _fetchFuture;

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
    if (args != null && seedId == null) {
      seedId = args['id'];
      seedName = args['name'];
      seedImage = args['image'];
      _fetchFuture = _fetchSeedTypeData(seedId!);
    }
  }

  Future<void> _fetchSeedTypeData(String id) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final uri = Uri.parse('$baseUrl/get-seeds-type/$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          seedTypes = data['data']['Type'] ?? [];
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() => error = data['message'] ?? 'فشل تحميل الأنواع');
      }
    } catch (e) {
      setState(() => error = 'حدث خطأ: $e');
    } finally {
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
        backgroundColor: const Color(0xFFF7941D),
        toolbarHeight: 5,
      ),
      body: BackgroundContainer(
        child: SafeArea(
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: _showTopContainer ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _showTopContainer ? 150 : 0,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 40,
                        left: -30,
                        child: Roundedtextcontainer(
                          text: seedName ?? 'اسم غير معروف',
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: CustomButton(
                          buttonColor: const Color(0xFFF7941D),
                          routeName: '/seed-main',
                          icon: Image.asset(
                            'assets/images/arrow.png',
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: -30,
                        child: roundedImageContainer(
                          seedImage ?? "assets/images/seeds-img.png",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child:
                    _fetchFuture == null
                        ? const Center(child: CircularProgressIndicator())
                        : FutureBuilder<void>(
                          future: _fetchFuture,
                          builder: (context, snapshot) {
                            if (isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFF7941D),
                                ),
                              );
                            }

                            if (error != null) {
                              return Center(
                                child: Text(
                                  error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            if (seedTypes.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_florist,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'لا توجد أنواع لهذا القسم',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return RawScrollbar(
                              controller: _scrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              minThumbLength: 48,
                              radius: const Radius.circular(20),
                              thickness: 8,
                              thumbColor: const Color(0xFF3B970C),
                              trackColor: Colors.grey.withOpacity(0.2),
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                itemCount: seedTypes.length,
                                itemBuilder: (context, index) {
                                  final item = seedTypes[index];
                                  final isEven = index % 2 == 0;

                                  final widget =
                                      isEven
                                          ? CustomWidget2(
                                            customColor: const Color(
                                              0xFFF7941D,
                                            ),
                                            customBorderColor: const Color(
                                              0xff00793F,
                                            ),
                                            text: item['name'] ?? 'بدون اسم',
                                            image:
                                                item['img']?['url'] ??
                                                'assets/images/seeds-img.png',
                                            routeName: '/seed-description',
                                            arguments: {
                                              'typeName':
                                                  item['name'] ??
                                                  '',
                                              'company':
                                                  item['description']?['company'] ??
                                                  '',
                                              'description':
                                                  item['description']?['description'] ??
                                                  '',
                                              'parentImage':
                                                  item['img']?['url'],
                                            },
                                          )
                                          : CustomWidget2Reversed(
                                            customColor: const Color(
                                              0xFFF7941D,
                                            ),
                                            customBorderColor: const Color(
                                              0xff00793F,
                                            ),
                                            text: item['name'] ?? 'بدون اسم',
                                            image:
                                                item['img']?['url'] ??
                                                'assets/images/seeds-img.png',
                                            routeName: '/seed-description',
                                            arguments: {
                                              'typeName':
                                                  item['name'] ??
                                                  '',
                                              'company':
                                                  item['description']?['company'] ??
                                                  '',
                                              'description':
                                                  item['description']?['description'] ??
                                                  '',
                                              'parentImage':
                                                  item['img']?['url'],
                                            },
                                          );

                                  return Column(
                                    children: [
                                      widget,
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                },
                              ),
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
