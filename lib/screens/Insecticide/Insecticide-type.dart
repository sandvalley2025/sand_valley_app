import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sand_valley/providers/app_state.dart';
import 'package:sand_valley/widgets/background_container.dart';
import 'package:sand_valley/widgets/customButton.dart';
import 'package:sand_valley/widgets/customWidget2.dart';
import 'package:sand_valley/widgets/customWidget2Reversed.dart';
import 'package:sand_valley/widgets/roundedTopTextContainer.dart';

class InsecticideTypePage extends StatefulWidget {
  const InsecticideTypePage({super.key});

  @override
  State<StatefulWidget> createState() => _InsecticideTypePage();
}

class _InsecticideTypePage extends State<InsecticideTypePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTopContainer = true;

  List<dynamic> _typeList = [];
  bool _isLoading = true;
  String? _error;
  String categoryName = '';
  String categoryId = '';

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
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args.containsKey('categoryId')) {
      categoryId = args['categoryId'];
      categoryName = args['categoryName'] ?? '';
      _fetchTypes();
    }
  }

  Future<void> _fetchTypes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final baseUrl = Provider.of<AppState>(context, listen: false).baseUrl;
      final url = "$baseUrl/get-insecticide-type/$categoryId";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final data = jsonBody['data'];
        setState(() => _typeList = data);
      } else {
        setState(() => _error = '❌ Failed to load types');
      }
    } catch (e) {
      setState(() => _error = '❌ Error occurred: $e');
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
              // Top header
              AnimatedOpacity(
                opacity: _showTopContainer ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showTopContainer ? 90 : 0,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Roundedtoptextcontainer(
                          text: categoryName.isNotEmpty ? categoryName : "مبيدات",
                          color: const Color(0xff006F54).withOpacity(0.69),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: CustomButton(
                          buttonColor: const Color(0xff006F54),
                          routeName: '/insecticide-main',
                          icon: Image.asset(
                            'assets/images/arrow.png',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Body
              Expanded(
                child: _isLoading
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
                        : _typeList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.grass,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'لا يوجد موبيد حالياً',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
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
                                itemCount: _typeList.length,
                                itemBuilder: (context, index) {
                                  final item = _typeList[index];
                                  final name = item['name'];
                                  final image = item['img']['url'];
                                  final id = item['_id'];
                                  final company = item['company'];
                                  final description = item['description'];
                                  final isEven = index % 2 == 0;

                                  final widget = isEven
                                      ? CustomWidget2(
                                          customBorderColor: const Color(0xff006F54),
                                          customColor: const Color(0xff006F54),
                                          text: name,
                                          image: image,
                                          routeName: '/insecticide-description',
                                          arguments: {
                                            'typeId': id,
                                            'typeName': name,
                                            'typeCompany': company,
                                            'typeImage': image,
                                            'typeDescription': description,
                                          },
                                        )
                                      : CustomWidget2Reversed(
                                          customBorderColor: const Color(0xff006F54),
                                          customColor: const Color(0xff006F54),
                                          text: name,
                                          image: image,
                                          routeName: '/insecticide-description',
                                          arguments: {
                                            'typeId': id,
                                            'typeName': name,
                                            'typeCompany': company,
                                            'typeImage': image,
                                            'typeDescription': description,
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
