import 'package:flutter/material.dart';
import 'package:sand_valley/screens/admin/pages/CommunicationEngPage.dart';
import 'package:sand_valley/screens/admin/pages/FertilizerNestedTypePage.dart';
import 'package:sand_valley/screens/admin/pages/FertilizerTypeAdminPage.dart';
import 'package:sand_valley/screens/admin/pages/communication-admin.dart';
import 'package:sand_valley/screens/admin/pages/fertilizer_main.dart';
import 'package:sand_valley/screens/admin/pages/insecticide-admin.dart';
import 'package:sand_valley/screens/admin/pages/insecticide_type_page.dart';
import 'package:sand_valley/screens/admin/pages/seed-admin.dart';
import 'package:sand_valley/screens/admin/pages/seed-type.dart';
import 'package:sand_valley/screens/admin/pages/seed.description.dart';
import 'package:sand_valley/screens/splash/splash_screen.dart';
import 'package:sand_valley/screens/home/home_screen.dart';

//admin
import 'package:sand_valley/screens/admin/admin_page.dart';
import 'package:sand_valley/screens/admin/master_admin_page.dart';
import 'package:sand_valley/screens/admin/admin_login_screen.dart';
import '../screens/admin/forgot_password_screen.dart';
import 'package:sand_valley/screens/admin/otp_screen.dart';
import 'package:sand_valley/screens/admin/reset_password_screen.dart';

// Communicate
import 'package:sand_valley/screens/Communicate/Communicate-main.dart';
import 'package:sand_valley/screens/Communicate/Communicate-eng.dart';
import 'package:sand_valley/screens/Communicate/Communicate-call.dart';

// Fertilizer
import 'package:sand_valley/screens/Fertilizer/Fertilizer-main.dart';
import 'package:sand_valley/screens/Fertilizer/Fertilizer-type-one.dart';
import 'package:sand_valley/screens/Fertilizer/Fertilizer-type-two.dart';
import 'package:sand_valley/screens/Fertilizer/Fertilizer.description.dart';

// Insecticide
import 'package:sand_valley/screens/Insecticide/Insecticide-main.dart';
import 'package:sand_valley/screens/Insecticide/Insecticide-type.dart';
import 'package:sand_valley/screens/Insecticide/Insecticide.description.dart';

// Seeds
import 'package:sand_valley/screens/seeds/seed-main.dart';
import 'package:sand_valley/screens/seeds/seed-type.dart';
import 'package:sand_valley/screens/seeds/seed-description.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/home': (context) => const HomeScreen(),

    //admin
    '/admin-login': (context) => const AdminLoginScreen(),
    '/admin-master': (context) => const MasterAdminPage(),
    '/admin': (context) => const AdminPage(),
    '/admin-forgot-password': (context) => const ForgotPasswordScreen(),
    '/otp': (context) => const OtpScreen(),
    '/reset-password': (context) => const ResetPasswordScreen(),

    //data entry
    //seed
    '/seed-main-admin': (context) => const SeedAdminPage(),
    '/seed-type-admin': (context) => const SeedTypeAdminPage(),
    '/seed-description-admin': (context) => const SeedDescriptionAdminPage(),
    //communication
    '/communicate-admin': (context) => const CommunicationAdminPage(),
    '/communicate-eng-admin': (context) => const CommunicationEngPage(),
    //insecticide
    '/insecticide-admin': (context) => const InsecticideAdmin(),
    '/insecticide-type-admin': (context) => const InsecticideTypeAdminPage(),
    //fertilizers
    '/fertilizer-admin': (context) => const FertilizerAdminPage(),
    '/fertilizer-type': (context) => const FertilizerTypeAdminPage(),
    '/fertilizer-nestedType': (context) => const FertilizerNestedTypePage(),


    // Communicate
    '/communicate-main': (context) => const CommunicationPage(),
    '/communicate-eng': (context) => const EngineerPage(),
    '/communicate-call': (context) => const CallPage(),

    // Fertilizer
    '/fertilizer-main': (context) => const FertilizerMainPage(),
    '/fertilizer-type-one': (context) => const FertilizerTypeOnePage(),
    '/fertilizer-type-two': (context) => const FertilizerTypeTwoPage(),
    '/fertilizer-description': (context) => const FertilizerDescriptionPage(),

    // Insecticide
    '/insecticide-main': (context) => const InsecticideMainPage(),
    '/insecticide-type': (context) => InsecticideTypePage(),
    '/insecticide-description': (context) => const InsecticideDescriptionPage(),

    // Seeds
    '/seed-main': (context) => const SeedMainPage(),
    '/seed-type': (context) => const SeedType(),
    '/seed-description': (context) => const SeedDescriptionPage(),
  };
}
