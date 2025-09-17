import 'package:flutter/material.dart';
import 'package:sand_valley/widgets/background_container.dart';
import 'package:sand_valley/widgets/basicContainer.dart';
import 'package:sand_valley/widgets/circularImageContainer.dart';
import 'package:sand_valley/widgets/customButton.dart';
import 'package:sand_valley/widgets/descriptionContainer.dart';
import 'package:sand_valley/widgets/roundedTopContainer.dart';

class FertilizerDescriptionPage extends StatelessWidget {
  const FertilizerDescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String name = args['name'] ?? 'لا يوجد اسم';
    final String company = args['company'] ?? 'لا يوجد شركة';
    final String description = args['description'] ?? 'لا يوجد وصف';
    final String imageUrl =
        args['image'] ?? 'assets/images/seeds-img.png'; // fallback

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff7B970C),
        toolbarHeight: 5,
      ),
      body: Stack(
        children: [
          BackgroundContainer(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  // Title
                  Roundedtopcontainer(
                    color: const Color(0xff7B970C).withOpacity(0.69),
                    text: name,
                  ),

                  // Image
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: circularContainer(imageUrl, const Color(0xff7B970C)),
                    
                  ),

                  // Company name
                  Basiccontainer(text: company, color: const Color(0xff7B970C)),

                  // Description
                  Transform.translate(
                    offset: const Offset(0, 20),
                    child: Descriptioncontainer(
                      color: Colors.white,
                      text: description,
                      borderColor: const Color(0xff7B970C),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 0,
            left: 0,
            child: CustomButton(
              buttonColor: const Color(0xff7B970C),
              routeName: '/pesticidesType',
              icon: Image.asset('assets/images/arrow.png', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
