import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/LoginPage.dart';
import 'package:flutter_application_1/Screens/Homescreen.dart';
import 'package:flutter_application_1/State/AppState.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trillion Chats',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 98, 0, 255),
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
    );
  }
}
