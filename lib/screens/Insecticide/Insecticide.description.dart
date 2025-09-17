import 'package:flutter/material.dart';
import 'package:sand_valley/widgets/background_container.dart';
import 'package:sand_valley/widgets/basicContainer.dart';
import 'package:sand_valley/widgets/circularImageContainer.dart';
import 'package:sand_valley/widgets/customButton.dart';
import 'package:sand_valley/widgets/descriptionContainer.dart';
import 'package:sand_valley/widgets/roundedTopContainer.dart';

class InsecticideDescriptionPage extends StatelessWidget {
  const InsecticideDescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Fallbacks in case arguments are missing
    final typeId = args?['typeId'] ?? '';
    final typeName = args?['typeName'] ?? '---';
    final typeCompany = args?['typeCompany'] ?? '---';
    final typeImage = args?['typeImage'] ?? 'assets/images/seeds-img.png';
    final typeDescription =
        args?['typeDescription'] ?? 'لا يوجد وصف متاح حالياً.';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff006F54),
        toolbarHeight: 5,
      ),
      body: Stack(
        children: [
          BackgroundContainer(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Roundedtopcontainer(
                    color: const Color(0xff006F54).withOpacity(0.69),
                    text: typeName,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: circularContainer(typeImage, const Color(0xff006F54)),
                  ),
                  Basiccontainer(
                    text: typeCompany,
                    color: const Color(0xff006F54),
                  ),
                  Transform.translate(
                    offset: const Offset(0, 20),
                    child: Descriptioncontainer(
                      borderColor: const Color(0xff006F54),
                      color: Colors.white,
                      text: typeDescription,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: CustomButton(
              buttonColor: const Color(0xff006F54),
              routeName: '/pesticidesType',
              icon: Image.asset('assets/images/arrow.png', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
