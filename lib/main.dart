import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sand_valley/routes/app_routes.dart';
import 'package:sand_valley/providers/app_state.dart'; // ✅ Import AppState
import 'package:sand_valley/services/connectivity_service.dart';
import 'package:lottie/lottie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppState(),
        ), // ✅ Global BASE_URL provider
        Provider<FlutterSecureStorage>.value(value: secureStorage),
        Provider<ConnectivityService>(create: (_) => ConnectivityService()),
      ],
      child: const SandValleyApp(),
    ),
  );
}


class SandValleyApp extends StatelessWidget {
  const SandValleyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(
      context,
      listen: false,
    );

    return StreamBuilder<bool>(
      stream: connectivityService.connectionStatusStream,
      initialData: true,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        return MaterialApp(
          title: 'Sand Valley',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Cairo',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF7941D),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            primaryColor: const Color(0xFFF7941D),
            highlightColor: const Color(0xFFF7941D),
            splashColor: const Color(0xFFF7941D),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Color(0xFFF7941D),
              selectionColor: Color(0xFFFFD8B0),
              selectionHandleColor: Color(0xFFF7941D),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7941D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              labelStyle: const TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFF7941D)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFF7941D),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          initialRoute: '/',
          routes: AppRoutes.routes,
          builder: (context, child) {
            if (!isConnected) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lottie animation
                      SizedBox(
                        height: 300,
                        width: 300,
                        child: Lottie.asset(
                          'assets/animations/no_internet.json',
                        ),
                      ),
                      const Text(
                        'no internet connection',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFFF7941D),
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return child ?? const SizedBox();
          },
        );
      },
    );
  }
}
