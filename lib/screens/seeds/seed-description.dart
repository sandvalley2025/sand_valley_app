import 'package:flutter/material.dart';
import 'package:sand_valley/widgets/background_container.dart';
import 'package:sand_valley/widgets/basicContainer.dart';
import 'package:sand_valley/widgets/circularImageContainer.dart';
import 'package:sand_valley/widgets/customButton.dart';
import 'package:sand_valley/widgets/descriptionContainer.dart';
import 'package:sand_valley/widgets/roundedTopContainer.dart';

class SeedDescriptionPage extends StatelessWidget {
  const SeedDescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String typeName = args['typeName'] ?? 'بدون اسم';
    final String company = args['company'] ?? '';
    final String description = args['description'] ?? '';
    final String image = args['parentImage'] ?? 'assets/images/seeds-img.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B970C),
        toolbarHeight: 5,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            BackgroundContainer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Roundedtopcontainer(
                      color: const Color(0xFF3B970C).withOpacity(0.69),
                      text: typeName.isNotEmpty ? typeName : 'لا توجد بيانات',
                    ),
                    const SizedBox(height: 12),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: circularContainer(image, const Color(0xFF3B970C)),
                    ),
                    const SizedBox(height: 10),
                    Basiccontainer(
                      text: company.isNotEmpty ? company : 'لا توجد بيانات',
                      color: const Color(0xFF3B970C),
                    ),
                    const SizedBox(height: 20),
                    // Only this part scrolls
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Descriptioncontainer(
                          color: Colors.white,
                          text:
                              description.isNotEmpty
                                  ? description
                                  : 'لا توجد بيانات',
                          borderColor: const Color(0xFF3B970C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: CustomButton(
                buttonColor: const Color(0xFF3B970C),
                routeName: '/pesticidesType',
                icon: Image.asset(
                  'assets/images/arrow.png',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
