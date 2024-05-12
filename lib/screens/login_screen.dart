import 'package:flutter/material.dart';
import 'package:google_dogs/services/api_service.dart';
import 'package:google_dogs/utilities/show_snack_bar.dart';
import '/screens/signup_screen.dart';
// import 'package:reddit_bel_ham/services/auth_service.dart';
import '../components/acknowledgement_text.dart';
import '../components/text_link.dart';
import '../utilities/screen_size_handler.dart';
import '../constants.dart';
import '../components/credentials_text_field.dart';
import '../components/continue_button.dart';
import '../components/logo_text_app_bar.dart';
import 'dart:convert';
import '/screens/document_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String id = 'login_screen';

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool isPassObscure = true;
  bool isNameFocused = false;
  bool isPassFocused = false;
  bool isButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          LogoTextAppBar(
            key: const Key('login_screen_logo_text_app_bar'),
            text: 'Sign up',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignupScreen()));
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: ScreenSizeHandler.smaller * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const AcknowledgementText(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenSizeHandler.screenWidth *
                              kButtonWidthRatio *
                              7,
                          vertical: ScreenSizeHandler.screenHeight *
                              kButtonHeightRatio *
                              2),
                      child: CredentialsTextField(
                        key: const Key('login_screen_email_text_field'),
                        controller: nameController,
                        isObscure: false,
                        text: 'Email',
                        suffixIcon: isNameFocused
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  setState(() {
                                    nameController.clear();
                                    isNameFocused = false;
                                    isButtonEnabled = false;
                                  });
                                },
                              )
                            : null,
                        isFocused: isNameFocused,
                        onChanged: (value) {
                          setState(() {
                            isNameFocused = value.isNotEmpty;
                            if (value.isNotEmpty &&
                                passController.text.isNotEmpty) {
                              setState(() {
                                isButtonEnabled = true;
                              });
                            } else {
                              setState(() {
                                isButtonEnabled = false;
                              });
                            }
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenSizeHandler.screenWidth *
                              kButtonWidthRatio *
                              7,
                          vertical: ScreenSizeHandler.screenHeight *
                              kButtonHeightRatio *
                              2),
                      child: CredentialsTextField(
                        key: const Key('login_screen_password_text_field'),
                        controller: passController,
                        isObscure: isPassObscure,
                        text: 'Password',
                        suffixIcon: isPassFocused
                            ? IconButton(
                                icon: const Icon(Icons.visibility_rounded),
                                onPressed: () {
                                  setState(() {
                                    isPassObscure = !isPassObscure;
                                  });
                                },
                              )
                            : null,
                        isFocused: isPassFocused,
                        onChanged: (value) {
                          setState(() {
                            isPassFocused = value.isNotEmpty;
                            if (value.isNotEmpty &&
                                nameController.text.isNotEmpty) {
                              setState(() {
                                isButtonEnabled = true;
                              });
                            } else {
                              setState(() {
                                isButtonEnabled = false;
                              });
                            }
                          });
                        },
                      ),
                    ),
                    ContinueButton(
                      key: const Key('login_screen_continue_button'),
                      text: "Continue",
                      isButtonEnabled: isButtonEnabled,
                      onPress: () async {
                        if (isButtonEnabled) {
                          ApiService apiService = ApiService();
                          apiService.login({
                            'email': nameController.text,
                            'password': passController.text
                          }).then((response) {
                            if (response.statusCode == 200) {
                              if (mounted) {
                                showSnackBar("Login Successfull!", context);
                              }
                              Navigator.pushNamed(
                                  context, DocumentManagerScreen.id,
                                  arguments: {
                                    "initialLetter": nameController.text[0],
                                    "userId": jsonDecode(response.body)['id']
                                  });
                            } else {
                              if (mounted) {
                                showSnackBar("Login Failed!", context);
                              }
                            }
                          });
                        } else {
                          null;
                        }
                      },
                      color: Colors.deepPurple,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
