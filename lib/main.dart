import 'package:flutter/material.dart';
import 'screens/first_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'utilities/screen_size_handler.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

@override
  Widget build(BuildContext context) {
    ScreenSizeHandler.initialize(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    return MaterialApp(
      title: 'HTTP',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routes: {
        FirstScreen.id: (context) => FirstScreen(),
        SignupScreen.id: (context) => const SignupScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
      },
      initialRoute: FirstScreen.id//(token==null)?FirstScreen.id: (JwtDecoder.isExpired(token)) ? LoginScreen.id : HomePageScreen.id,
    );
  }
}
