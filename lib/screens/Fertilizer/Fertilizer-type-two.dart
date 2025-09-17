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

class FertilizerTypeTwoPage extends StatefulWidget {
  const FertilizerTypeTwoPage({super.key});

  @override
  State<FertilizerTypeTwoPage> createState() => _FertilizerTypeTwoPageState();
}

class _FertilizerTypeTwoPageState extends State<FertilizerTypeTwoPage> {
  List<dynamic> types = [];
  bool _isLoading = true;

  late String categoryId;
  late String typeId;
  late String name;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    categoryId = args['categoryId'];
    typeId = args['typeId'];
    name = args['name'];
    _fetchNestedTypes();
  }

  Future<void> _fetchNestedTypes() async {
    setState(() => _isLoading = true);
    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;

      final response = await http.get(
        Uri.parse('$baseUrl/get-fertilizer-nested-type/$categoryId/$typeId'),
      );
      final data = json.decode(response.body);
      setState(() {
        types = data['data'] ?? [];
      });
    } catch (e) {
      debugPrint("❌ Error fetching nested types: $e");
    } finally {
      setState(() => _isLoading = false);
    }
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
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xff7B970C).withOpacity(0.69),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: CustomButton(
                        buttonColor: const Color(0xff7B970C),
                        routeName: '/fertilizer-type-one',
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
                            child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.85, // expands text width responsively
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 28, // fixed font size
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3, // allow up to 3 lines
                                overflow:
                                    TextOverflow
                                        .ellipsis, // ellipsis if too long
                                softWrap: true,
                              ),
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

              // Body
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff7B970C),
                          ),
                        )
                        : types.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.grass, color: Colors.grey, size: 40),
                              SizedBox(height: 10),
                              Text(
                                'لا توجد أنواع فرعية متاحة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          itemCount: types.length,
                          itemBuilder: (context, index) {
                            final item = types[index];
                            final isEven = index % 2 == 0;

                            final widget =
                                isEven
                                    ? CustomWidget2(
                                      customBorderColor: const Color(
                                        0xff7B970C,
                                      ),
                                      customColor: const Color(0xff7B970C),
                                      text: item['name'],
                                      image: item['img']['url'],
                                      routeName: '/fertilizer-description',
                                      arguments: {
                                        'name': item['name'],
                                        'company': item['company'],
                                        'description': item['description'],
                                        'image': item['img']['url'], // optional
                                      },
                                    )
                                    : CustomWidget2Reversed(
                                      customBorderColor: const Color(
                                        0xff7B970C,
                                      ),
                                      customColor: const Color(0xff7B970C),
                                      text: item['name'],
                                      image: item['img']['url'],
                                      routeName: '/fertilizer-description',
                                      arguments: {
                                        'name': item['name'],
                                        'company': item['company'],
                                        'description': item['description'],
                                        'image': item['img']['url'], // optional
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
