import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_application_1/Screens/LoginPage.dart';
import 'package:flutter_application_1/Screens/Homescreen.dart';
import 'package:flutter_application_1/State/AppState.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AppState.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
            Color(0xFF0B0F19),
          ],
        ),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Trillion Chats',
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFDC634),
            secondary: Color(0xFFFDC634),
            surface: Colors.transparent,
          ),
        ),
        home: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            return AppState.instance.isLoggedIn
                ? const Homescreen()
                : const LoginPage();
          },
        ),
      ),
    );
  }
}
