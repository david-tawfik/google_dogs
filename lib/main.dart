import 'dart:html';

import 'package:flutter/material.dart';

import 'screens/first_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'utilities/screen_size_handler.dart';
import 'package:google_dogs/Screens/document_manager.dart';
import 'package:google_dogs/utilities/screen_size_handler.dart';


void main() {
  runApp(const GoogleDogs());
}

class GoogleDogs extends StatelessWidget {
  const GoogleDogs({
    super.key,
  });
  @override

  Widget build(BuildContext context) {
    ScreenSizeHandler.initialize(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 500,
        minWidth: 800,
      ),
      child: MaterialApp(
        title: 'Dogs',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        routes: {
          FirstScreen.id: (context) => FirstScreen(),
          SignupScreen.id: (context) => const SignupScreen(),
          LoginScreen.id: (context) => const LoginScreen(),
          DocumentManagerScreen.id: (context) => DocumentManagerScreen(),
        },
        initialRoute: FirstScreen.id//(token==null)?FirstScreen.id: (JwtDecoder.isExpired(token)) ? LoginScreen.id : HomePageScreen.id,
      ),
    );
  }
}
