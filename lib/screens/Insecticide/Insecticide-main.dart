import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/background_container.dart';
import 'package:sand_valley/widgets/customButton.dart';
import 'package:sand_valley/widgets/customWidget2.dart';
import 'package:sand_valley/widgets/customWidget2Reversed.dart';
import 'package:sand_valley/widgets/roundedContainer.dart';

class InsecticideMainPage extends StatefulWidget {
  const InsecticideMainPage({super.key});

  @override
  State<StatefulWidget> createState() => _InsecticideMainPage();
}

class _InsecticideMainPage extends State<InsecticideMainPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTopContainer = true;

  List<dynamic> _insecticideList = [];
  bool _isLoading = true;
  String? _error;

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

    _fetchInsecticideData();
  }

  Future<void> _fetchInsecticideData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final res = await http.get(Uri.parse("$baseUrl/get-insecticide-data"));

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final data = body['data']['data'];
        setState(() => _insecticideList = data);
      } else {
        setState(() => _error = '❌ Failed to load data');
      }
    } catch (e) {
      setState(() => _error = '❌ Error: $e');
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
        backgroundColor: const Color(0xff006F54),
        toolbarHeight: 5,
      ),
      body: BackgroundContainer(
        child: SafeArea(
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: _showTopContainer ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _showTopContainer ? 300 : 0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xff006F54).withOpacity(0.69),
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
                          buttonColor: const Color(0xff006F54),
                          routeName: '/home',
                          icon: Image.asset(
                            'assets/images/arrow.png',
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
                                    "مبيدات",
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
                          image: 'assets/images/insecticide.png',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Scrollable content area
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff006F54),
                          ),
                        )
                        : _error != null
                        ? Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : _insecticideList.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.grass, size: 40, color: Colors.grey),
                              SizedBox(height: 10),
                              Text(
                                'لا يوجد مبيدات حالياً',
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
                          itemCount: _insecticideList.length,
                          itemBuilder: (context, index) {
                            final item = _insecticideList[index];
                            final name = item['name'];
                            final imageUrl = item['img']['url'];
                            final categoryId = item['_id'];
                            final isEven = index % 2 == 0;

                            final widget =
                                isEven
                                    ? CustomWidget2(
                                      customBorderColor: const Color(
                                        0xff006F54,
                                      ),
                                      customColor: const Color(0xff006F54),
                                      text: name,
                                      image: imageUrl,
                                      routeName: '/insecticide-type',
                                      arguments: {
                                        'categoryId': categoryId,
                                        'categoryName': name,
                                      },
                                    )
                                    : CustomWidget2Reversed(
                                      customBorderColor: const Color(
                                        0xff006F54,
                                      ),
                                      customColor: const Color(0xff006F54),
                                      text: name,
                                      image: imageUrl,
                                      routeName: '/insecticide-type',
                                      arguments: {
                                        'categoryId': categoryId,
                                        'categoryName': name,
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
