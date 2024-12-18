import 'package:flutter/material.dart';
import '/constants.dart';
import '../../utilities/screen_size_handler.dart';

class LogoTextAppBar extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const LogoTextAppBar({required this.onTap, super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      centerTitle: true,
      backgroundColor: kBackgroundColor,
      title: Hero(
        tag: 'logo',
        child: Padding(
          padding: EdgeInsets.only(top: ScreenSizeHandler.screenHeight * 0.015),
          child: Image(
            image: const AssetImage('assets/images/logo_white.png'),
            height: ScreenSizeHandler.screenHeight * 0.1,
            width: ScreenSizeHandler.screenWidth * 0.1,
          ),
        ),
      ),
      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: ScreenSizeHandler.screenHeight * 0.015,
            right: ScreenSizeHandler.screenWidth * 0.02,
          ),
          child: Container(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: ScreenSizeHandler.smaller * kAppBarTitleSmallerFontRatio*0.7,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
