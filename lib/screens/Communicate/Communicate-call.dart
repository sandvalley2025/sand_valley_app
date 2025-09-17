import 'package:flutter/material.dart';
import 'package:sand_valley/widgets/background_container.dart';
import 'package:sand_valley/widgets/circularImageContainer.dart';
import 'package:sand_valley/widgets/customButton.dart';
import 'package:sand_valley/widgets/roundedTopContainer.dart';
import 'package:url_launcher/url_launcher.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  void _launchCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone); 
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch phone call to $phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String name = arguments?['name'] ?? 'مهندس';
    final String image = arguments?['image'] ?? 'assets/images/seeds-img.png';
    final String phone = arguments?['phone'] ?? '';

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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Roundedtopcontainer(
                    color: const Color(0xff006F54).withOpacity(0.69),
                    text: name,
                  ),

                  const SizedBox(height: 20),

                  circularContainer(image,const Color(0xff006F54)),

                  const SizedBox(height: 20),

                  callActionContainer(
                    onTap: () => _launchCall(phone),
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
              routeName: '/communicate-eng',
              icon: Image.asset(
                'assets/images/arrow.png',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget callActionContainer({VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50,
      width: double.infinity,
      color: const Color(0xff006F54),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "اتصل ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(-1.0, 1.0),
            child: const Icon(Icons.call, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
