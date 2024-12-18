import 'package:flutter/material.dart';
import 'package:google_dogs/Screens/document_manager.dart';
import 'package:google_dogs/services/api_service.dart';
import 'package:google_dogs/utilities/show_snack_bar.dart';
import 'package:google_dogs/utilities/user_id.dart';
import 'package:http/http.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '/screens/login_screen.dart';
import '../components/acknowledgement_text.dart';
import '../utilities/screen_size_handler.dart';
import '../constants.dart';
import '../components/credentials_text_field.dart';
import '../components/continue_button.dart';
import '../components/logo_text_app_bar.dart';
import '../utilities/email_regex.dart';
import 'dart:convert';
import 'package:google_dogs/components/reddit_loading_indicator.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  static const String id = '/signup';

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool isPassObscure = true;
  bool isNameFocused = false;
  bool isPassFocused = false;
  bool isButtonEnabled = false;
  bool isValidEmail = true;
  bool isValidPassword = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const RedditLoadingIndicator(),
      blur: 0,
      opacity: 0,
      offset: Offset( ScreenSizeHandler.screenWidth*0.38,ScreenSizeHandler.screenHeight*0.6),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            LogoTextAppBar(
              key: const Key('signup_screen_logo_text_app_bar_login_button'),
              text: 'Log in',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()));
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
                        'Hi new friend,\nWelcome to Google Dogs!',
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
                          key: const Key('signup_screen_email_text_field'),
                          controller: nameController,
                          isObscure: false,
                          isValid: isValidEmail,
                          text: 'Email',
                          prefixIcon: isValidEmail && isNameFocused
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.green,
                                )
                              : null,
                          suffixIcon: isNameFocused
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                  ),
                                  onPressed: () {
                                    nameController.clear();
                                    setState(() {
                                      isButtonEnabled = false;
                                      isNameFocused = false;
                                      isValidEmail = true;
                                    });
                                  },
                                )
                              : null,
                          isFocused: isNameFocused,
                          onChanged: (value) {
                            setState(() {
                              isValidEmail = isEmailValid(value);
                              isButtonEnabled = isValidEmail &&
                                  isValidPassword &&
                                  isPassFocused &&
                                  isNameFocused;
                              isNameFocused = value.isNotEmpty;
                              if (value.isNotEmpty &&
                                  passController.text.isNotEmpty) {
                                setState(() {});
                              } else {
                                if (value.isEmpty) {
                                  setState(() {
                                    isValidEmail = true;
                                  });
                                }
                                setState(() {});
                              }
                            });
                          },
                        ),
                      ),
                      Visibility(
                        key: const Key('signup_screen_email_error_text'),
                        visible: !isValidEmail,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: ScreenSizeHandler.screenWidth *
                                  kErrorMessageLeftPaddingRatio *
                                  6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Please enter a valid email address',
                              style: TextStyle(
                                color: kErrorColor,
                                fontSize: ScreenSizeHandler.smaller *
                                    kErrorMessageSmallerFontRatio *
                                    0.7,
                              ),
                            ),
                          ),
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
                          key: const Key('signup_screen_password_text_field'),
                          controller: passController,
                          isObscure: isPassObscure,
                          isValid: isValidPassword,
                          text: 'Password',
                          prefixIcon: isValidPassword && isPassFocused
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.green,
                                )
                              : null,
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
                              isValidPassword = value.length >= 8;
                              isPassFocused = value.isNotEmpty;
                              isButtonEnabled = isValidEmail &&
                                  isValidPassword &&
                                  isPassFocused &&
                                  isNameFocused;
                              if (value.isNotEmpty &&
                                  nameController.text.isNotEmpty) {
                                setState(() {});
                              } else {
                                if (value.isEmpty) {
                                  setState(() {
                                    // isValidPassword = true;
                                  });
                                }
                                setState(() {});
                              }
                            });
                          },
                        ),
                      ),
                      Visibility(
                        key: const Key('signup_screen_password_error_text'),
                        visible: !isValidPassword || isPassFocused,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: ScreenSizeHandler.screenWidth *
                                  kErrorMessageLeftPaddingRatio *
                                  6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Password must be at least 8 characters',
                              style: TextStyle(
                                color:
                                    isValidPassword ? Colors.green : kErrorColor,
                                fontSize: ScreenSizeHandler.smaller *
                                    kErrorMessageSmallerFontRatio *
                                    0.7,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ContinueButton(
                        key: const Key('login_screen_continue_button'),
                        text: "Continue",
                        isButtonEnabled: isButtonEnabled,
                        onPress: () async {
                          if (isButtonEnabled) {
                            setState(() {
                              isLoading = true;
                            });
                            ApiService apiService = ApiService();
                            Response response = await apiService.register({
                              'email': nameController.text,
                              'password': passController.text
                            });
                            if (response.statusCode == 200) {
                              UserIdStorage.setUserId(
                                  jsonDecode(response.body)['id'].toString());
                              Navigator.pushNamed(
                                  context, DocumentManagerScreen.id,arguments: {"initialLetter": nameController.text[0]});
                              showSnackBar("Sign up successfull!", context);
                            } else {
                              showSnackBar("Error in signing up!", context);
                            }
                            setState(() {
                              isLoading = false;
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
      ),
    );
  }
}
