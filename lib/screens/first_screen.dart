import 'package:flutter/material.dart';
import '/screens/signup_screen.dart';
import '../screens/login_screen.dart';
import '../constants.dart';
import '../components/continue_button.dart';
import '../components/acknowledgement_text.dart';
import '../components/text_link.dart';
import '../utilities/screen_size_handler.dart';
import 'dart:convert';
class FirstScreen extends StatefulWidget {
  const FirstScreen({
    super.key,
  });

  static const String id = 'first_screen';

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: ScreenSizeHandler.screenHeight * 0.02),
                    child: Hero(
                      tag: 'logo',
                      child: Image(
                        key: const Key('first_screen_logo_image'),
                        image: const AssetImage(
                            'assets/images/logo_white.png'),
                        height: ScreenSizeHandler.screenHeight * 0.4,
                        width: ScreenSizeHandler.screenWidth * 0.5,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Welcome to\nGoogle Dogs',
                      style: TextStyle(
                        fontSize: ScreenSizeHandler.smaller * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        // fontFamily: 'Pacifico', 
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: ScreenSizeHandler.screenHeight * 0.1,
                  ),
                  ContinueButton(
                    key: const Key('first_screen_continue_with_email_button'),
                    text: "Signup with Email",
                    icon: const Icon(Icons.email),
                    onPress: () {
                      Navigator.push( context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen())
                      );
                    },
                  ),
                  const AcknowledgementText(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenSizeHandler.screenWidth * kButtonWidthRatio,
                        vertical: ScreenSizeHandler.screenHeight * kButtonHeightRatio),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already a user?',
                          style: TextStyle(
                            fontSize: ScreenSizeHandler.smaller * kButtonSmallerFontRatio,
                            color: Colors.white,
                          ),
                        ),
                        TextLink(
                          key: const Key('first_screen_log_in_text_link'),
                            fontSizeRatio: ScreenSizeHandler.smaller * kButtonSmallerFontRatio,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginScreen()));
                            },
                            text: 'Log in'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
