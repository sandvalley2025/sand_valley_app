import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'dart:convert';

import 'package:sand_valley/widgets/background_container.dart';
import 'package:sand_valley/widgets/customButton.dart';
import 'package:sand_valley/widgets/customWidget2.dart';
import 'package:sand_valley/widgets/customWidget2Reversed.dart';
import 'package:sand_valley/widgets/roundedContainer.dart';

class FertilizerMainPage extends StatefulWidget {
  const FertilizerMainPage({super.key});

  @override
  State<FertilizerMainPage> createState() => _FertilizerMainPage();
}

class _FertilizerMainPage extends State<FertilizerMainPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTopContainer = true;
  bool _isLoading = true;

  List<Map<String, dynamic>> _fertilizers = [];

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

    _fetchFertilizerData();
  }

  Future<void> _fetchFertilizerData() async {
    setState(() => _isLoading = true);
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final response = await http.get(
        Uri.parse("$baseUrl/get-fertilizer-data"),
      );

      final data = json.decode(response.body);
      final List fetched = data['data'] ?? [];

      setState(() {
        _fertilizers =
            fetched
                .map<Map<String, dynamic>>(
                  (item) => {
                    'id': item['_id'],
                    'name': item['name'],
                    'image': item['img']['url'],
                  },
                )
                .toList();
      });
    } catch (e) {
      debugPrint("❌ Error fetching fertilizer data: $e");
    } finally {
      setState(() => _isLoading = false);
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
        backgroundColor: const Color(0xff7B970C),
        toolbarHeight: 5,
      ),
      body: BackgroundContainer(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              AnimatedOpacity(
                opacity: _showTopContainer ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showTopContainer ? 300 : 0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xff7B970C).withOpacity(0.69),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        child: CustomButton(
                          buttonColor: const Color(0xff7B970C),
                          routeName: '/home',
                          icon: Image.asset(
                            'assets/images/arrow.png',
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 70),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "اسمدة",
                                    style: TextStyle(
                                      fontSize: 55,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  ImageIcon(
                                    AssetImage('assets/images/page_icon.png'),
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: RoundedContainer(
                          image: 'assets/images/fertilizer.png',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fertilizer List
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff7B970C),
                          ),
                        )
                        : _fertilizers.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.grass_sharp,
                                color: Colors.grey,
                                size: 40,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'لا توجد أسمدة حالياً',
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
                          itemCount: _fertilizers.length,
                          itemBuilder: (context, index) {
                            final fertilizer = _fertilizers[index];
                            final isEven = index % 2 == 0;

                            final widget =
                                isEven
                                    ? CustomWidget2(
                                      customBorderColor: const Color(
                                        0xff7B970C,
                                      ),
                                      customColor: const Color(0xff7B970C),
                                      text: fertilizer['name'],
                                      image: fertilizer['image'],
                                      routeName: '/fertilizer-type-one',
                                      arguments: {
                                        'id': fertilizer['id'],
                                        'name': fertilizer['name'],
                                      },
                                    )
                                    : CustomWidget2Reversed(
                                      customBorderColor: const Color(
                                        0xff7B970C,
                                      ),
                                      customColor: const Color(0xff7B970C),
                                      text: fertilizer['name'],
                                      image: fertilizer['image'],
                                      routeName: '/fertilizer-type-one',
                                      arguments: {
                                        'id': fertilizer['id'],
                                        'name': fertilizer['name'],
                                      },
                                    );

                            return Column(
                              children: [widget, const SizedBox(height: 0)],
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
