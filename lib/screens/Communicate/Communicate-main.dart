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

class CommunicationPage extends StatefulWidget {
  const CommunicationPage({super.key});

  @override
  State<CommunicationPage> createState() => CommunicationPageState();
}

class CommunicationPageState extends State<CommunicationPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTopContainer = true;
  List<dynamic> communicationData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCommunicationData();

    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && _showTopContainer) {
        setState(() => _showTopContainer = false);
      } else if (_scrollController.offset <= 50 && !_showTopContainer) {
        setState(() => _showTopContainer = true);
      }
    });
  }

  Future<void> _fetchCommunicationData() async {
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/get-communication-data'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          communicationData = jsonData['data']['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load communication data');
      }
    } catch (e) {
      print('Error fetching data: $e');
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
              // Header
              AnimatedOpacity(
                opacity: _showTopContainer ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _showTopContainer ? 300 : 0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xff00793F).withOpacity(0.69),
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
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 70),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "تواصل معنا",
                                style: TextStyle(
                                  fontSize: 38,
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
                      ),
                      const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: RoundedContainer(
                          image: 'assets/images/handShake.jpg',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Body
              Expanded(
                child:
                    isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff006F54),
                          ),
                        )
                        : communicationData.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone, size: 40, color: Colors.grey),
                              SizedBox(height: 10),
                              Text(
                                'لا توجد بيانات حالياً',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
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
                          itemCount: communicationData.length,
                          itemBuilder: (context, index) {
                            final item = communicationData[index];
                            final isEven = index % 2 == 0;

                            final widget =
                                isEven
                                    ? CustomWidget2(
                                      customBorderColor: const Color(
                                        0xff006F54,
                                      ),
                                      customColor: const Color(0xff006F54),
                                      text: item['name'] ?? 'بدون اسم',
                                      image: 'assets/images/location.png',
                                      routeName: '/communicate-eng',
                                      arguments: {'id': item['_id']},
                                    )
                                    : CustomWidget2Reversed(
                                      customBorderColor: const Color(
                                        0xff006F54,
                                      ),
                                      customColor: const Color(0xff006F54),
                                      text: item['name'] ?? 'بدون اسم',
                                      image: 'assets/images/location.png',
                                      routeName: '/communicate-eng',
                                      arguments: {'id': item['_id']},
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
